local Screen = require("UISDK/Components/Screen")
local TextLabel = require("UISDK/Components/TextLabel")
local Frame = require("UISDK/Components/Frame")

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

local function clearBounds(target, bounds)
	if not bounds then
		return
	end

	if type(target.setCursorPos) ~= "function" or type(target.write) ~= "function" then
		return
	end

	local targetWidth, targetHeight = target.getSize()
	local startX = math.max(1, bounds.X)
	local startY = math.max(1, bounds.Y)
	local endX = math.min(targetWidth, bounds.X + bounds.Width - 1)
	local endY = math.min(targetHeight, bounds.Y + bounds.Height - 1)

	if startX > endX or startY > endY then
		return
	end

	if type(target.setBackgroundColor) == "function" then
		target.setBackgroundColor(32768) -- colors.black
	end

	local blankLine = string.rep(" ", endX - startX + 1)

	for y = startY, endY do
		target.setCursorPos(startX, y)
		target.write(blankLine)
	end
end

local function shouldDrawSourceOnly(source)
	return source
		and source.Name ~= "Screen"
		and type(source.Draw) == "function"
		and type(source.GetDrawBounds) == "function"
end

local function isComponentVisible(component)
	if type(component.IsVisible) == "function" then
		return component:IsVisible()
	end

	return component.Visible
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

local componentRegistry = {
	Screen = Screen,
	TextLabel = TextLabel,
	Frame = Frame,
}

function Runtime.create(componentType, props, children)
	if type(componentType) == "function" then
		return componentType(props, children)
	end

	local class = componentRegistry[componentType]
	assert(class, "Unknown component type: " .. tostring(componentType))

	local instance = class.new()
	rawset(instance, "_SuppressInvalidation", true)

	if props then
		for k, v in pairs(props) do
			instance[k] = v
		end
	end

	if children and type(instance.Parent) == "function" then
		for key, child in pairs(children) do
			if type(key) == "string" then
				local p = rawget(child, "_Properties")
				if p then
					p["Name"] = key
				end
			end
			instance:Parent(child)
		end
	end

	rawset(instance, "_SuppressInvalidation", nil)

	if componentType == "Screen" then
		resolveRuntime():AddScreen(instance)
	end

	return instance
end

function Runtime.Clear(runtime)
	local target = resolveRuntime(runtime).Target

	if type(target.setBackgroundColor) == "function" then
		target.setBackgroundColor(32768) -- colors.black
	end

	if type(target.clear) == "function" then
		target.clear()
	end

	if type(target.setCursorPos) == "function" then
		target.setCursorPos(1, 1)
	end
end

function Runtime:Invalidate(source)
	local runtime = resolveRuntime(self)
	runtime.Dirty = true

	if runtime.AutoDraw == false or runtime._IsDrawing then
		return
	end

	if shouldDrawSourceOnly(source) then
		runtime:DrawComponent(source)
		return
	end

	Runtime.Draw(runtime)
end

function Runtime:DrawComponent(component)
	local runtime = resolveRuntime(self)
	assert(component ~= nil and type(component.Draw) == "function", "Runtime:DrawComponent requires a drawable component")

	runtime._IsDrawing = true

	local success, drawError = pcall(function()
		clearBounds(runtime.Target, rawget(component, "_LastDrawBounds"))
		clearBounds(runtime.Target, component:GetDrawBounds())

		if isComponentVisible(component) then
			component:Draw(runtime.Target)
			if type(component.CaptureDrawBounds) == "function" then
				component:CaptureDrawBounds()
			else
				rawset(component, "_LastDrawBounds", component:GetDrawBounds())
			end
		else
			rawset(component, "_LastDrawBounds", nil)
		end

		runtime.Dirty = false
	end)

	runtime._IsDrawing = false

	if not success then
		error(drawError, 0)
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

function Runtime.state(initial)
	local runtime = resolveRuntime()
	local value = initial

	return function()
		return value
	end, function(newValue)
		if value == newValue then return end
		value = newValue
		runtime:Invalidate(nil)
	end
end

return Runtime
