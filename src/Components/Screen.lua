local Component = require("UISDK/Primitives/Component")
local Vector2 = require("UISDK/Primitives/Vector2")

local Screen = {}
Screen.__index = Component.CreateIndex(Screen)
Screen.__newindex = Component.__newindex

setmetatable(Screen, {
	__index = Component,
})

function Screen:Parent(component)
	table.insert(self.Children, component)
	component.Parent = self
end

function Screen:Unparent(component)
	for i = #self.Children, 1, -1 do
		if self.Children[i].Id == component.Id then
			self.Children[i].Parent = nil
			table.remove(self.Children, i)
		end
	end
end

function Screen:GetSize()
	if self.Runtime then
		local width, height = self.Runtime:GetSize()
		return Vector2.new(width, height)
	end

	return Vector2.new()
end

function Screen:Draw(target)
	if not self.Visible then
		return
	end

	local drawTarget = target
	if not drawTarget and self.Runtime then
		drawTarget = self.Runtime:GetTarget()
	end

	assert(drawTarget ~= nil, "Screen:Draw requires a terminal or monitor target")

	for _, component in ipairs(self.Children) do
		local isVisible = component.Visible
		if type(component.IsVisible) == "function" then
			isVisible = component:IsVisible()
		end

		if isVisible and type(component.Draw) == "function" then
			component:Draw(drawTarget)
			if type(component.CaptureDrawBounds) == "function" then
				component:CaptureDrawBounds()
			end
		end
	end
end

function Screen.new(runtime)
	local self = Component.new()
	setmetatable(self, Screen)
	rawset(self, "_SuppressInvalidation", true)

	self.Name = "Screen"
	self.Visible = true
	self.Position = Vector2.new(0, 0)
	self.Runtime = runtime
	self.Children = {}

	rawset(self, "_SuppressInvalidation", nil)

	return self
end

return Screen
