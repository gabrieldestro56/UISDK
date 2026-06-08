local Screen = require("UISDK/Components/Screen")
local TextLabel = require("UISDK/Components/TextLabel")

local Runtime = {}
Runtime.__index = Runtime

local currentRuntime = nil
local runtimesByTarget = setmetatable({}, { __mode = "k" })

local function validateTarget(target)
	assert(target ~= nil, "Runtime.new requires a terminal or monitor target")
	assert(type(target.getSize) == "function", "Runtime target must implement getSize")
end

local function resolveRuntime(runtime)
	if getmetatable(runtime) == Runtime then
		return runtime
	end

	assert(currentRuntime ~= nil, "Runtime has not been created yet")
	return currentRuntime
end

function Runtime.new(target)
	validateTarget(target)

	if runtimesByTarget[target] then
		currentRuntime = runtimesByTarget[target]
		return currentRuntime
	end

	local self = setmetatable({}, Runtime)

	self.Target = target
	self.Screens = {}
	self.AutoDraw = true
	self.Dirty = false
	self._IsDrawing = false

	runtimesByTarget[target] = self
	currentRuntime = self

	return self
end

function Runtime.current()
	return resolveRuntime()
end

function Runtime.GetTarget(runtime)
	return resolveRuntime(runtime).Target
end

function Runtime.GetSize(runtime)
	return resolveRuntime(runtime).Target.getSize()
end

function Runtime:AddScreen(screen)
	assert(screen ~= nil and type(screen.Draw) == "function", "Runtime:AddScreen requires a drawable screen")

	table.insert(self.Screens, screen)
	screen.Runtime = self
	self:Invalidate(screen)

	return screen
end

function Runtime.Screen(runtime)
	local runtimeInstance = resolveRuntime(runtime)
	return runtimeInstance:AddScreen(Screen.new(runtimeInstance))
end

function Runtime.TextLabel()
	return TextLabel.new()
end

function Runtime.Clear(runtime)
	local target = resolveRuntime(runtime).Target

	if type(target.clear) == "function" then
		target.clear()
	end

	if type(target.setCursorPos) == "function" then
		target.setCursorPos(1, 1)
	end
end

function Runtime:Invalidate()
	local runtime = resolveRuntime(self)
	runtime.Dirty = true

	if runtime.AutoDraw == false or runtime._IsDrawing then
		return
	end

	Runtime.Draw(runtime)
end

function Runtime.Draw(runtimeOrScreen, maybeScreen)
	local isRuntimeCall = getmetatable(runtimeOrScreen) == Runtime or runtimeOrScreen == Runtime
	local runtime = nil
	local screen = maybeScreen

	if isRuntimeCall then
		runtime = resolveRuntime(runtimeOrScreen)
	else
		screen = runtimeOrScreen
		runtime = screen and screen.Runtime or resolveRuntime()
	end

	runtime._IsDrawing = true

	local success, drawError = pcall(function()
		Runtime.Clear(runtime)

		if screen then
			assert(type(screen.Draw) == "function", "Runtime:Draw requires a drawable screen")
			screen:Draw(runtime.Target)
		else
			for _, visibleScreen in ipairs(runtime.Screens) do
				if visibleScreen.Visible and type(visibleScreen.Draw) == "function" then
					visibleScreen:Draw(runtime.Target)
				end
			end
		end

		runtime.Dirty = false
	end)

	runtime._IsDrawing = false

	if not success then
		error(drawError, 0)
	end
end

return Runtime
