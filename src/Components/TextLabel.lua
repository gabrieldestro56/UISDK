local Component = require("../Primitives/Component")

local TextLabel = {}
TextLabel.__index = TextLabel

setmetatable(TextLabel, {
	__index = Component,
})

function TextLabel.new()
	local self = setmetatable({}, TextLabel)

	return self
end

return TextLabel
