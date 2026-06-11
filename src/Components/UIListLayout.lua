local Component = require("UISDK/Primitives/Component")
local Vector2 = require("UISDK/Primitives/Vector2")

local UIListLayout = {}
UIListLayout.__index = Component.CreateIndex(UIListLayout)
UIListLayout.__newindex = Component.__newindex

setmetatable(UIListLayout, { __index = Component })

function UIListLayout:ApplyLayout(frame)
	local frameProps = rawget(frame, "_Properties")
	local children = frameProps and frameProps["Children"] or {}
	local padding = self.Padding or 0
	local direction = self.LayoutDirection or "Vertical"
	local cursor = 1

	local sorted = {}
	for i, child in ipairs(children) do
		if type(child.ApplyLayout) ~= "function" then
			sorted[#sorted + 1] = { child = child, i = i }
		end
	end
	table.sort(sorted, function(a, b)
		local ao = a.child.LayoutOrder or 0
		local bo = b.child.LayoutOrder or 0
		if ao ~= bo then return ao < bo end
		return a.i < b.i
	end)

	for _, entry in ipairs(sorted) do
		local child = entry.child
		local props = rawget(child, "_Properties")
		if props then
			if direction == "Horizontal" then
				props["Position"] = Vector2.new(cursor, 1)
				local size = child:GetSize()
				cursor = cursor + size.X + padding
			else
				props["Position"] = Vector2.new(1, cursor)
				local size = child:GetSize()
				cursor = cursor + size.Y + padding
			end
		end
	end
end

function UIListLayout:Draw()
end

function UIListLayout:GetSize()
	return Vector2.new(0, 0)
end

function UIListLayout.new()
	local self = Component.new()
	setmetatable(self, UIListLayout)
	rawset(self, "_SuppressInvalidation", true)

	self.Name = "UIListLayout"
	self.Visible = false
	self.LayoutDirection = "Vertical"
	self.Padding = 0

	rawset(self, "_SuppressInvalidation", nil)
	return self
end

return UIListLayout
