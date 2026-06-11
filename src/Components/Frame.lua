local Component = require("UISDK/Primitives/Component")
local Vector2 = require("UISDK/Primitives/Vector2")

local Frame = {}
Frame.__index = Component.CreateIndex(Frame)
Frame.__newindex = Component.__newindex

setmetatable(Frame, {
	__index = Component,
})

local function fillRect(target, x1, y1, x2, y2, color)
	target.setBackgroundColor(color)
	local row = string.rep(" ", x2 - x1 + 1)
	for y = y1, y2 do
		target.setCursorPos(x1, y)
		target.write(row)
	end
end

local function drawOutline(target, x1, y1, x2, y2, color)
	target.setBackgroundColor(color)
	local row = string.rep(" ", x2 - x1 + 1)
	target.setCursorPos(x1, y1)
	target.write(row)
	if y2 ~= y1 then
		target.setCursorPos(x1, y2)
		target.write(row)
	end
	for y = y1 + 1, y2 - 1 do
		target.setCursorPos(x1, y)
		target.write(" ")
		if x2 ~= x1 then
			target.setCursorPos(x2, y)
			target.write(" ")
		end
	end
end

function Frame:GetSize()
	local size = self.Size or Vector2.new(0, 0)
	if size.IsScale then
		local parent = self.Parent
		if parent and type(parent.GetSize) == "function" then
			local parentSize = parent:GetSize()
			return Vector2.new(
				math.floor(parentSize.X * size.X),
				math.floor(parentSize.Y * size.Y)
			)
		end
	end
	return size
end

function Frame:AddChild(component)
	table.insert(self.Children, component)
	component.Parent = self
end

function Frame:RemoveChild(component)
	for i = #self.Children, 1, -1 do
		if self.Children[i].Id == component.Id then
			self.Children[i].Parent = nil
			table.remove(self.Children, i)
		end
	end
end

function Frame:Draw(target)
	if not self:IsVisible() then
		return
	end

	local pos = self:GetAbsolutePosition()
	local size = self:GetSize()

	local x1 = pos.X
	local y1 = pos.Y
	local x2 = pos.X + size.X - 1
	local y2 = pos.Y + size.Y - 1

	if self.BackgroundEnabled then
		fillRect(target, x1, y1, x2, y2, self.BackgroundColor)
	end

	local border = self.BorderRadius
	if self.BorderEnabled and border > 0 then
		for i = 0, border - 1 do
			drawOutline(target, x1 + i, y1 + i, x2 - i, y2 - i, self.BorderColor)
		end
	end

	for _, child in ipairs(self.Children) do
		if type(child.ApplyLayout) == "function" then
			child:ApplyLayout(self)
			break
		end
	end

	local sorted = {}
	for i, child in ipairs(self.Children) do
		sorted[i] = { child = child, i = i }
	end
	table.sort(sorted, function(a, b)
		local az = a.child.ZIndex or 0
		local bz = b.child.ZIndex or 0
		if az ~= bz then return az < bz end
		return a.i < b.i
	end)

	for _, entry in ipairs(sorted) do
		local child = entry.child
		local isVisible = child.Visible
		if type(child.IsVisible) == "function" then
			isVisible = child:IsVisible()
		end
		if isVisible and type(child.Draw) == "function" then
			if self.BackgroundEnabled then
				target.setBackgroundColor(self.BackgroundColor)
			else
				target.setBackgroundColor(32768)
			end
			child:Draw(target)
			if type(child.CaptureDrawBounds) == "function" then
				child:CaptureDrawBounds()
			end
		end
	end

	target.setBackgroundColor(32768)
	target.setTextColor(1)
end

function Frame.new()
	local self = Component.new()
	setmetatable(self, Frame)
	rawset(self, "_SuppressInvalidation", true)

	self.Name = "Frame"
	self.Visible = true
	self.Size = Vector2.new(10, 5)
	self.Position = Vector2.new(1, 1)
	self.AnchorPoint = Vector2.new(0, 0)

	self.BorderEnabled = false
	self.BorderRadius = 0
	self.BorderColor = colors and colors.white or 1
	self.BackgroundEnabled = true
	self.BackgroundColor = colors and colors.gray or 8

	self.Children = {}

	rawset(self, "_SuppressInvalidation", nil)

	return self
end

return Frame
