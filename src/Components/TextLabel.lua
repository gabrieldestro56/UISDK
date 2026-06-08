local Component = require("UISDK/Primitives/Component")
local Vector2 = require("UISDK/Primitives/Vector2")

local TextLabel = {}
TextLabel.__index = Component.CreateIndex(TextLabel)
TextLabel.__newindex = Component.__newindex

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

	local position = self:GetAbsolutePosition()

	assert(target ~= nil, "TextLabel:Draw requires a terminal or monitor target")

	target.setCursorPos(position.X, position.Y)
	target.setTextColor(self.Color)
	target.write(tostring(self.Text))
end

function TextLabel:GetSize()
	return Vector2.new(#tostring(self.Text), 1)
end

function TextLabel.new()
	local self = Component.new()
	setmetatable(self, TextLabel)
	rawset(self, "_SuppressInvalidation", true)

	self.Name = "TextLabel"
	self.Visible = true
	self.Text = "Text"

	self.Color = colors and colors.white or 1

	self.Parent = nil

	rawset(self, "_SuppressInvalidation", nil)

	return self
end

return TextLabel
