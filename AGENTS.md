# AGENTS.md

Reactive UI library for ComputerCraft / CC: Tweaked. Targets the Lua 5.2 subset available inside ComputerCraft.

## Architecture

```
src/
  Runtime.lua              -- entry point: screen registry, event loop, draw dispatch
  Components/
    Screen.lua             -- root container; owns children, delegates to Runtime for size
    TextLabel.lua          -- single-line text renderer
    Frame.lua              -- filled rectangle with optional multi-layer border, holds children
  Primitives/
    Component.lua          -- base class: reactive _Properties system, layout math
    Vector2.lua            -- 2D value; absolute (integer coords) or scale (0.0–1.0)
  Utils/
    PositionUtils.lua      -- screen geometry helpers
  Debug/                   -- runnable demo programs (not tests)
    Counter.lua
    BouncingFrame.lua
    CenteredLabel.lua
    SwappingScreens.lua
install.lua                -- ComputerCraft one-liner installer; auto-generated section at top
scripts/
  generate-install-deps.ps1  -- regenerates the dependencies table in install.lua
```

## Class / Inheritance Pattern

Every component follows this exact structure:

```lua
local MyComponent = {}
MyComponent.__index = Component.CreateIndex(MyComponent)  -- method lookup walks MyComponent then Component
MyComponent.__newindex = Component.__newindex              -- reactive property writes

setmetatable(MyComponent, { __index = Component })        -- class-level inheritance

function MyComponent.new()
    local self = Component.new()           -- allocate with base defaults
    setmetatable(self, MyComponent)        -- upgrade to derived class
    rawset(self, "_SuppressInvalidation", true)

    -- set defaults here; no reactivity fires during construction
    self.Name = "MyComponent"
    self.Visible = true

    rawset(self, "_SuppressInvalidation", nil)
    return self
end

return MyComponent
```

Rules:
- `Component.new()` is always called first to create the instance; `setmetatable` upgrades it.
- Wrap all constructor property assignments between `_SuppressInvalidation = true/nil` so no redraws fire during init.
- `rawset` for internal bookkeeping fields (`_Properties`, `_LastDrawBounds`, `_SuppressInvalidation`, etc.) — these never go through the reactive system.
- Any key starting with `_` bypasses `__newindex` automatically (see `Component.__newindex`).

## Reactive Property System

`Component.__newindex` stores public properties in `_Properties[key]` and calls `runtime:Invalidate(self)` when the value changes. Reading through `__index` checks `_Properties` first; if the value is a function it calls it (reactive computed props).

### Property vs method name collision — use `getProperty` internally

`Component.__index` (via `Component.CreateIndex`) calls `lookupClassValue` **before** `getProperty`. `lookupClassValue` walks the class table and its metatable chain. If a property name matches a method name on any class in the chain, `self.Key` returns the **method**, not the stored value in `_Properties`.

This was the root cause of a real crash: `Component:GetAbsolutePosition` used `self.Parent` to get the parent reference. Because the old API had a `Screen:Parent(child)` method (since renamed to `AddChild`), `lookupClassValue` found that method first. The code then received a function instead of a component and crashed when it tried to call `.GetSize()` on it.

**Rule:** Inside `Component` and any subclass method that reads a property from `self`, use `getProperty(self, "Key")` directly — never `self.Key` — for any property that could ever share a name with a class method. This applies to `Parent`, `Children`, `Size`, `Position`, and anything else that a subclass might expose as a method.

```lua
-- Wrong — goes through __index, hits lookupClassValue first
local parent = self.Parent

-- Correct — reads _Properties directly, bypasses method lookup
local parent = getProperty(self, "Parent")
```

`getProperty` is a module-local function in `Component.lua`; it is not exposed publicly. All layout methods (`GetAbsolutePosition`, `GetSize` overrides, `IsVisible`, `GetRuntime`) must use it when reading stored properties internally.

Reactive computed property example:

```lua
label.Text = function() return "Count: " .. tostring(getCount()) end
```

The function is evaluated on each draw. This is how `Runtime.state` values bind to display properties.

## Runtime.state

```lua
local getValue, setValue = Runtime.state(initial)
```

Returns a getter and setter. Calling `setValue` triggers `runtime:Invalidate(nil)` (full redraw). Use for shared reactive state that multiple components read.

## Require Paths

Modules load via `require("UISDK/Category/Module")` — no `.lua` extension, forward slashes, `UISDK/` prefix. This matches the paths used inside `install.lua`. Maintain this convention exactly in all new files and in any new `require` calls.

## Naming Conventions

| Thing | Convention | Example |
|---|---|---|
| Public methods and properties | PascalCase | `Frame:GetSize()`, `self.BackgroundColor` |
| Local variables | camelCase | `local colorPalette`, `local startX` |
| `Runtime.create` alias | `e` | `local e = Runtime.create` |
| Internal/private fields | `_PascalCase` | `_Properties`, `_LastDrawBounds` |
| Component constructors | `ClassName.new(...)` | `Frame.new()`, `Screen.new(runtime)` |

## Vector2

Two modes:
- `Vector2.new(x, y)` — absolute integer character coordinates (1-based, matching CC terminals).
- `Vector2.fromScale(x, y)` — fractional 0.0–1.0 relative to parent size. Detected via `size.IsScale`.

`GetAbsolutePosition` and `Frame:GetSize` both check `IsScale` and resolve against the parent.

## Color Constants

ComputerCraft exposes a global `colors` table, which is absent in unit-test or non-CC environments. Guard all color defaults:

```lua
self.BackgroundColor = colors and colors.gray or 8
self.Color = colors and colors.white or 1
```

Hard-coded fallback `32768` (black) is used in drawing code (`target.setBackgroundColor(32768)`).

## Adding a New Component

1. Create `src/Components/MyComponent.lua` following the class pattern above.
2. Add a `require` for it at the top of `src/Runtime.lua`.
3. Register it in `componentRegistry` in `Runtime.lua` so `Runtime.create("MyComponent", ...)` works.
4. Run the installer script to update `install.lua`:
   ```powershell
   .\scripts\generate-install-deps.ps1
   ```
5. Commit `install.lua` alongside the new source file.

**Never hand-edit the `dependencies` table in `install.lua`.** It is fully regenerated by the script.

## Adding a Debug Program

Debug files under `src/Debug/` are factory functions, not modules:

```lua
return function(window)
    local Runtime = require("UISDK/Runtime")
    local rt = Runtime.new(window or term.current())
    -- build UI, then either rt:Run() or a manual loop with sleep()
end
```

They receive an optional `window` so they can be embedded in a windowed environment. After adding one, run `generate-install-deps.ps1` so `install.lua` picks it up.

## Event Loop

`Runtime:Run()` owns the event loop. Hooks registered via `Runtime:AddHook(fn)` receive every event. The loop fires:
- `"tick"` — timer tick at `_Hz` (default 20) fps.
- `"mouse_click"` / `"monitor_touch"` — dispatched to `OnClick` handlers via hit-testing `_LastDrawBounds`.
- All other CC events forwarded raw.

`Runtime:RemoveHook(fn)` removes by reference. Hooks snapshot before iteration, so adding/removing inside a hook is safe.

## Drawing

- `Runtime:Invalidate(source)` triggers a redraw. If `source` is a non-Screen component with `Draw` and `GetDrawBounds`, only that component is redrawn (dirty-rect optimization). Otherwise the full screen redraws.
- Set `runtime.AutoDraw = false` to batch changes and call `Runtime.Draw(runtime)` manually.
- `_LastDrawBounds` caches the last drawn rect for clearing before a redraw. Always set via `CaptureDrawBounds()` or `rawset(component, "_LastDrawBounds", ...)`.
- After every `Draw` call, reset terminal state: `target.setBackgroundColor(32768)` and `target.setTextColor(1)`.

## No Test Framework

There is no test runner. The `src/Debug/` programs are the integration tests — run them inside ComputerCraft to verify behavior. When making a structural change, validate against at least `Counter.lua` (reactivity, click, scale positioning) and `BouncingFrame.lua` (manual draw loop, animation).
