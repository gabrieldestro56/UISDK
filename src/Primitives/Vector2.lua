local Vector2 = {}
Vector2.__index = Vector2

function Vector2.new(x, y)
	local self = setmetatable({}, Vector2)

	self.X = x
	self.Y = y

	return self
end

return Vector2
