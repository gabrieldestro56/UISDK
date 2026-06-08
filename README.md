# UISDK

UISDK is a small UI library for ComputerCraft / CC: Tweaked projects.

## Install

Run this on a ComputerCraft computer with HTTP enabled:

```lua
wget run https://raw.githubusercontent.com/gabrieldestro56/UISDK/refs/heads/main/install.lua
```

The installer downloads the SDK files into a local `UISDK` folder. Install paths omit the `.lua` extension so modules can be loaded with ComputerCraft-style `require` paths.

## Usage

Create a runtime once with the terminal or monitor that the SDK should draw into:

```lua
local Runtime = require("UISDK/Runtime")

Runtime.new(term.current())

local screen = Runtime.Screen()

local label = Runtime.TextLabel()
label.Text = "Hello!"
screen:Parent(label)
```

For a monitor, pass the wrapped peripheral instead:

```lua
Runtime.new(peripheral.wrap("left"))
```

Screens and components redraw automatically when reactive properties change:

```lua
screen.Visible = false
screen.Visible = true
label.Text = "Updated!"
```

Screen changes redraw every visible screen. Component changes, like `label.Text` or `label.Visible`, repaint just that component.

If automatic redraw is disabled with `runtime.AutoDraw = false`, call `Runtime.Draw()` to redraw every visible screen.

## Regenerate Installer Dependencies

`install.lua` starts with a `dependencies` table that should mirror every `.lua` file under `src`. After adding, moving, or deleting source files, regenerate that table from the repository root:

```powershell
.\scripts\generate-install-deps.ps1
```

The script scans `src`, groups modules by their top-level folder, and replaces only the dependency table at the top of `install.lua`.

If you are generating dependencies for a fork or another branch, pass the raw GitHub target explicitly:

```powershell
.\scripts\generate-install-deps.ps1 -Repository "your-user/UISDK" -Branch "main"
```

Commit the regenerated `install.lua` together with the source changes so the one-line installer stays current.
