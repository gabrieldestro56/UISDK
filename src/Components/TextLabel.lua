local Component = require("UISDK/Primitives/Component")
local Vector2 = require("UISDK/Primitives/Vector2")

local TextLabel = {}
TextLabel.__index = TextLabel

setmetatable(TextLabel, {
	__index = Component,
})

function TextLabel:Draw(target)
	if not self.Visible then
		return
	end

	if not self.Parent then
		return
	end

	local parentPosition = self.Parent.Position

	-- Offset position so its relative to parent
	local goalX, goalY = self.Position.X + parentPosition.X, self.Position.Y + parentPosition.Y

	assert(target ~= nil, "TextLabel:Draw requires a terminal or monitor target")

	target.setCursorPos(goalX, goalY)
	target.setTextColor(self.Color)
	target.write(tostring(self.Text))
end

function TextLabel.new()
	local self = Component.new()
	setmetatable(self, TextLabel)

	self.Name = "TextLabel"
	self.Visible = true
	self.Text = "Text"

	self.Position = Vector2.new(1, 1)
	self.Color = colors and colors.white or 1

	self.Parent = nil

	return self
end

return TextLabel
