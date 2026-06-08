local Component = {}
Component.__index = Component

function Component:Draw()
	print(self.Name .. " doesn't have 'Draw' method.")
end

function Component.new()
	local self = setmetatable({}, Component)

	self.Name = "Component"
	self.Visible = false
	self.Parent = nil

	self.Id = math.random(1, 999999999)

	return self
end

return Component
