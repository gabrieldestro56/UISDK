local Vector2 = require("UISDK/Primitives/Vector2")

local Component = {}

local function lookupClassValue(class, key)
	local value = rawget(class, key)
	if value ~= nil then
		return value
	end

	local classMetatable = getmetatable(class)
	local parentIndex = classMetatable and classMetatable.__index

	if type(parentIndex) == "table" then
		return parentIndex[key]
	end

	if type(parentIndex) == "function" then
		return parentIndex(class, key)
	end

	return nil
end

local function getProperty(self, key)
	local properties = rawget(self, "_Properties")
	if properties and properties[key] ~= nil then
		local value = properties[key]
		if type(value) == "function" then
			return value()
		end
		return value
	end

	return rawget(self, key)
end

local function invalidateRuntime(runtime, source)
	if runtime and type(runtime.Invalidate) == "function" then
		runtime:Invalidate(source)
	end
end

function Component.CreateIndex(class)
	return function(self, key)
		local classValue = lookupClassValue(class, key)
		if classValue ~= nil then
			return classValue
		end

		return getProperty(self, key)
	end
end

Component.__index = Component.CreateIndex(Component)

function Component.__newindex(self, key, value)
	if type(key) == "string" and string.sub(key, 1, 1) == "_" then
		rawset(self, key, value)
		return
	end

	local properties = rawget(self, "_Properties")
	if not properties then
		rawset(self, key, value)
		return
	end

	local oldValue = properties[key]
	if oldValue == value then
		return
	end

	local shouldInvalidate = not rawget(self, "_SuppressInvalidation")
	local oldRuntime = nil
	if shouldInvalidate then
		oldRuntime = self:GetRuntime()
	end

	properties[key] = value

	if shouldInvalidate then
		local newRuntime = self:GetRuntime()
		invalidateRuntime(oldRuntime, self)

		if newRuntime ~= oldRuntime then
			invalidateRuntime(newRuntime, self)
		end
	end
end

function Component:Draw()
	print(self.Name .. " doesn't have 'Draw' method.")
end

function Component:GetSize()
	return Vector2.new()
end

function Component:GetAbsolutePosition()
	local position = self.Position or Vector2.new()
	local anchorPoint = self.AnchorPoint or Vector2.new()
	local size = self:GetSize()
	local parent = getProperty(self, "Parent")

	local resolvedX = position.X
	local resolvedY = position.Y

	if position.IsScale and parent and type(parent.GetSize) == "function" then
		local parentSize = parent:GetSize()
		resolvedX = math.floor(parentSize.X * position.X)
		resolvedY = math.floor(parentSize.Y * position.Y)
	end

	local anchorOffset = Vector2.new(
		math.floor(size.X * anchorPoint.X),
		math.floor(size.Y * anchorPoint.Y)
	)
	local anchoredPosition = Vector2.new(resolvedX - anchorOffset.X, resolvedY - anchorOffset.Y)

	if parent and type(parent.GetAbsolutePosition) == "function" then
		local parentPosition = parent:GetAbsolutePosition()
		return Vector2.new(
			anchoredPosition.X + parentPosition.X,
			anchoredPosition.Y + parentPosition.Y
		)
	end

	return anchoredPosition
end

function Component:GetDrawBounds()
	local position = self:GetAbsolutePosition()
	local size = self:GetSize()

	return {
		X = position.X,
		Y = position.Y,
		Width = size.X,
		Height = size.Y,
	}
end

function Component:GetRuntime()
	local runtime = getProperty(self, "Runtime")
	if runtime then
		return runtime
	end

	local parent = getProperty(self, "Parent")
	if parent and type(parent.GetRuntime) == "function" then
		return parent:GetRuntime()
	end

	return nil
end

function Component:IsVisible()
	if not self.Visible then
		return false
	end

	local parent = getProperty(self, "Parent")
	if parent and type(parent.IsVisible) == "function" then
		return parent:IsVisible()
	end

	return true
end

function Component:CaptureDrawBounds()
	rawset(self, "_LastDrawBounds", self:GetDrawBounds())
end

function Component.new()
	local self = setmetatable({}, Component)
	rawset(self, "_Properties", {})
	rawset(self, "_SuppressInvalidation", true)

	self.Name = "Component"
	self.Visible = false
	self.Position = Vector2.new(1, 1)
	self.AnchorPoint = Vector2.new(0, 0)
	self.Parent = nil
	self.ZIndex = 0
	self.LayoutOrder = 0

	self.Id = math.random(1, 999999999)

	rawset(self, "_SuppressInvalidation", nil)

	return self
end

return Component
