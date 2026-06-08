local Component = require("../Primitives/Component")
local Vector2 = require("../Primitives/Vector2")

local Screen = {}
Screen.__index = Screen

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
		if component.Visible and type(component.Draw) == "function" then
			component:Draw(drawTarget)
		end
	end
end

function Screen.new(runtime)
	local self = Component.new()
	setmetatable(self, Screen)

	self.Name = "Screen"
	self.Visible = true
	self.Position = Vector2.new(0, 0)
	self.Runtime = runtime
	self.Children = {}

	return self
end

return Screen
