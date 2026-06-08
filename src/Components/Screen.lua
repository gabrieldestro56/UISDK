local Screen = {}
Screen.__index = Screen

function Screen:Print()
	print("hello")
end

function Screen.new()
	local self = setmetatable({}, Screen)

	return self
end

return Screen
