local Component = require("../Primitives/Component")

local Screen = {}
Screen.__index = Screen

setmetatable(Screen, {
	__index = Component,
})

function Screen:Parent(component)
	table.insert(self.Children, component)
end

function Screen:Unparent(component)
	for i = #self.Children, 1, -1 do
		if self.Children[i].Id == component.Id then
			table.remove(self.Children, i)
		end
	end
end

function Screen:Draw()
	for _, component in self.Children do
		component:Draw()
	end
end

function Screen.new()
	local self = setmetatable({}, Screen)

	self.Children = {}

	return self
end

return Screen
