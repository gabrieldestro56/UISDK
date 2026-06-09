local Vector2 = {}
Vector2.__index = Vector2

function Vector2.new(x, y)
	local self = setmetatable({}, Vector2)

	self.X = x or 0
	self.Y = y or 0

	return self
end

function Vector2.fromScale(x, y)
	local self = setmetatable({}, Vector2)

	self.X = x or 0
	self.Y = y or 0
	self.IsScale = true

	return self
end

return Vector2
