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

function Runtime.Screen(runtime)
	return Screen.new(resolveRuntime(runtime))
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

	assert(screen ~= nil and type(screen.Draw) == "function", "Runtime:Draw requires a drawable screen")
	Runtime.Clear(runtime)
	screen:Draw(runtime.Target)
end

return Runtime
