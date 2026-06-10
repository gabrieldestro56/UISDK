# UISDK

Reactive UI library for ComputerCraft / CC: Tweaked. Components redraw automatically when properties change.

## Install

Run on a ComputerCraft computer with HTTP enabled:

```lua
wget run https://raw.githubusercontent.com/gabrieldestro56/UISDK/refs/heads/main/install.lua
```

Downloads SDK files into a local `UISDK/` folder. Modules load without the `.lua` extension via ComputerCraft `require`.

## Quick Start

```lua
local Runtime = require("UISDK/Runtime")

Runtime.new(term.current())

local screen = Runtime.Screen()

local label = Runtime.TextLabel()
label.Text = "Hello!"
label.Position = Vector2.new(1, 1)
screen:Parent(label)
```

For a monitor:

```lua
Runtime.new(peripheral.wrap("left"))
```

## Core Concepts

### Runtime

One runtime per target (terminal or monitor). `Runtime.new` returns the same instance if called again with the same target.

```lua
local runtime = Runtime.new(term.current())
```

| Function | Description |
|---|---|
| `Runtime.new(target)` | Create or retrieve runtime for a target |
| `Runtime.current()` | Get the active runtime |
| `Runtime.Screen()` | Create a screen and register it with the runtime |
| `Runtime.TextLabel()` | Create a TextLabel |
| `Runtime.Draw()` | Manually redraw all visible screens |
| `Runtime.Clear()` | Clear the terminal/monitor |
| `Runtime.GetSize()` | Return width, height of the target |

### Screens

Screens are root containers. A runtime can hold multiple screens; visibility controls which one is shown.

```lua
local screen = Runtime.Screen()
screen.Visible = false  -- hide
screen.Visible = true   -- show — redraws automatically
```

Add/remove children:

```lua
screen:Parent(label)
screen:Unparent(label)
```

### Components

#### TextLabel

Renders a single line of text.

| Property | Type | Default | Description |
|---|---|---|---|
| `Text` | string | `"Text"` | Text to display |
| `Color` | color | `colors.white` | Text color |
| `Position` | Vector2 | `(1,1)` | Position relative to parent |
| `AnchorPoint` | Vector2 | `(0,0)` | Pivot (0–1 scale) |
| `Visible` | bool | `true` | Whether to render |

```lua
local label = Runtime.TextLabel()
label.Text = "Score: 0"
label.Color = colors.yellow
label.Position = Vector2.new(5, 3)
screen:Parent(label)
```

#### Frame

Filled rectangle with optional border. Can contain children.

| Property | Type | Default | Description |
|---|---|---|---|
| `Size` | Vector2 | `(10, 5)` | Width and height in characters |
| `Position` | Vector2 | `(1, 1)` | Position relative to parent |
| `AnchorPoint` | Vector2 | `(0, 0)` | Pivot (0–1 scale) |
| `BackgroundColor` | color | `colors.gray` | Fill color |
| `BackgroundEnabled` | bool | `true` | Whether to draw the background fill |
| `BorderRadius` | number | `0` | Border thickness in characters |
| `BorderColor` | color | `colors.white` | Border color |
| `Visible` | bool | `true` | Whether to render |

```lua
local frame = Runtime.create("Frame", {
    Size = Vector2.new(20, 10),
    Position = Vector2.new(2, 2),
    BackgroundColor = colors.blue,
    BorderRadius = 1,
    BorderColor = colors.cyan,
})
screen:Parent(frame)
frame:Parent(label)  -- label positioned relative to frame
```

### Positioning

`Position` is absolute character coordinates by default (1-based, matching ComputerCraft terminals).

Use `Vector2.fromScale(x, y)` for positions relative to parent size (0.0–1.0):

```lua
label.Position = Vector2.fromScale(0.5, 0.5)  -- center of parent
```

`AnchorPoint` shifts the component's own origin. `(0.5, 0.5)` centers the component on its position:

```lua
label.AnchorPoint = Vector2.new(0.5, 0.5)
label.Position = Vector2.fromScale(0.5, 0.5)  -- truly centered
```

### Reactivity

Setting any property on a component automatically triggers a redraw. No manual draw calls needed.

```lua
label.Text = "Updated!"   -- redraws just the label
screen.Visible = false    -- redraws all visible screens
```

Setting `Runtime.AutoDraw = false` disables automatic redraw. Call `Runtime.Draw()` to redraw manually.

```lua
local runtime = Runtime.current()
runtime.AutoDraw = false

label.Text = "A"
label.Color = colors.red
-- nothing drawn yet

Runtime.Draw()  -- draw once with both changes applied
```

### Runtime.create (declarative syntax)

`Runtime.create` builds component trees without intermediate variables. It mirrors JSX-style component composition.

```lua
local e = Runtime.create

local screen = e("Screen", { Visible = true }, {
    Header = e("TextLabel", {
        Text = "My App",
        Color = colors.cyan,
        Position = Vector2.new(1, 1),
    }),
    Panel = e("Frame", {
        Size = Vector2.new(30, 10),
        Position = Vector2.new(1, 3),
        BackgroundColor = colors.gray,
    }, {
        Info = e("TextLabel", {
            Text = "Hello from panel",
            Position = Vector2.new(1, 1),
        }),
    }),
})
```

String keys in the children table become the component's `Name`.

Custom component functions also work:

```lua
local function MyButton(props)
    return e("Frame", props)
end

e(MyButton, { Size = Vector2.new(10, 3) })
```

### Runtime.state

`Runtime.state` creates a reactive value. Changing it invalidates and redraws the active screen.

```lua
local getScore, setScore = Runtime.state(0)

label.Text = "Score: " .. getScore()

-- later:
setScore(getScore() + 1)  -- triggers redraw automatically
```

### Utilities

**PositionUtils** — screen geometry helpers:

```lua
local PositionUtils = require("UISDK/Utils/PositionUtils")

local cx, cy = PositionUtils.getCenterOfScreen()
```

## Project Structure

```
src/
  Runtime.lua              -- entry point, manages screens and drawing
  Components/
    Screen.lua             -- root container
    TextLabel.lua          -- single-line text
    Frame.lua              -- filled rectangle with optional border
  Primitives/
    Component.lua          -- base class, reactive property system
    Vector2.lua            -- 2D vector, absolute and scale modes
  Utils/
    PositionUtils.lua      -- screen geometry helpers
  Debug/                   -- runnable examples
    Counter.lua
    BouncingFrame.lua
    CenteredLabel.lua
    SwappingScreens.lua
```

## Regenerate Installer Dependencies

`install.lua` has a `dependencies` table that mirrors every `.lua` file under `src/`. After adding, moving, or deleting source files, regenerate it from the repo root:

```powershell
.\scripts\generate-install-deps.ps1
```

For a fork or another branch:

```powershell
.\scripts\generate-install-deps.ps1 -Repository "your-user/UISDK" -Branch "main"
```

Commit the regenerated `install.lua` alongside source changes so the one-line installer stays current.
