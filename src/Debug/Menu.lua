package.path = "/?.lua;" .. package.path

local Runtime = require("UISDK/Runtime")
local Vector2 = require("UISDK/Primitives/Vector2")
local e = Runtime.create

local target = term.current()
local rt = Runtime.new(target)

local SCENARIOS = {
	{
		name = "Counter",
		lines = {
			"Click +/- to change",
			"a reactive counter.",
			"",
			"",
			"Shows: state(),",
			"OnClick, scale pos.",
		},
		module = "UISDK/Debug/Counter",
	},
	{
		name = "BouncingFrame",
		lines = {
			"Frame bounces around",
			"terminal, changing",
			"color and counting",
			"wall hits.",
			"",
			"Shows: tick, AutoDraw.",
		},
		module = "UISDK/Debug/BouncingFrame",
	},
	{
		name = "CenteredLabel",
		lines = {
			"Text label centered",
			"via fromScale.",
			"",
			"",
			"Shows: AnchorPoint,",
			"fromScale pos.",
		},
		module = "UISDK/Debug/CenteredLabel",
	},
	{
		name = "ListLayout",
		lines = {
			"LayoutOrder sorts",
			"children A,B,C.",
			"ZIndex controls",
			"draw order/overlap.",
			"",
			"Shows: UIListLayout.",
		},
		module = "UISDK/Debug/ListLayout",
	},
	{
		name = "SwappingScreens",
		lines = {
			"Two screens swap",
			"visibility each",
			"second via tick.",
			"",
			"Shows: multi-Screen,",
			"Visible toggle.",
		},
		module = "UISDK/Debug/SwappingScreens",
	},
}

local getSelected, setSelected = Runtime.state(1)
local selectedToRun = nil

local w, h = target.getSize()
local LEFT_W = 22
local RIGHT_START = 24
local RIGHT_W = w - RIGHT_START + 1

-- Left panel background (cols 1-22, full height)
local leftPanel = e("Frame", {
	Size = Vector2.new(LEFT_W, h),
	Position = Vector2.new(1, 1),
	BackgroundColor = colors and colors.gray or 8,
})

-- Title
leftPanel:AddChild(e("TextLabel", {
	Text = "Debug Menu",
	Color = colors and colors.yellow or 1,
	Position = Vector2.new(0, 0),
}))

-- One row frame per scenario
for i, scenario in ipairs(SCENARIOS) do
	local idx = i
	local rowFrame = e("Frame", {
		Size = Vector2.new(LEFT_W, 1),
		Position = Vector2.new(0, i),
		BackgroundColor = function()
			return (getSelected() == idx) and (colors and colors.lightBlue or 3) or (colors and colors.gray or 8)
		end,
	})
	rowFrame:AddChild(e("TextLabel", {
		Text = function()
			return (getSelected() == idx and "> " or "  ") .. scenario.name
		end,
		Color = function()
			return (getSelected() == idx) and (colors and colors.white or 1) or (colors and colors.lightGray or 7)
		end,
		Position = Vector2.new(1, 0),
	}))
	leftPanel:AddChild(rowFrame)
end

-- Footer hint
leftPanel:AddChild(e("TextLabel", {
	Text = "W/S or up/dn  Enter=run",
	Color = colors and colors.lightGray or 7,
	Position = Vector2.new(0, h - 1),
}))

-- Divider (col 23, full height)
local divider = e("Frame", {
	Size = Vector2.new(1, h),
	Position = Vector2.new(23, 1),
	BackgroundColor = colors and colors.lightGray or 7,
})

-- Right panel (col 24 to w, full height)
local rightPanel = e("Frame", {
	Size = Vector2.new(RIGHT_W, h),
	Position = Vector2.new(RIGHT_START, 1),
	BackgroundColor = colors and colors.gray or 8,
})

-- Scenario name
rightPanel:AddChild(e("TextLabel", {
	Text = function()
		return SCENARIOS[getSelected()].name
	end,
	Color = colors and colors.yellow or 1,
	Position = Vector2.new(1, 1),
}))

-- Description lines (6 lines, starting 2 rows below title)
for i = 1, 6 do
	local lineIdx = i
	rightPanel:AddChild(e("TextLabel", {
		Text = function()
			return SCENARIOS[getSelected()].lines[lineIdx] or ""
		end,
		Color = colors and colors.white or 1,
		Position = Vector2.new(1, 2 + lineIdx),
	}))
end

local mainScreen = e("Screen", { Visible = true })
mainScreen:AddChild(leftPanel)
mainScreen:AddChild(divider)
mainScreen:AddChild(rightPanel)

local function onKey(event, p1)
	if event ~= "key" then
		return
	end
	if p1 == keys.s or p1 == keys.down then
		setSelected(math.min(getSelected() + 1, #SCENARIOS))
	end
	if p1 == keys.w or p1 == keys.up then
		setSelected(math.max(getSelected() - 1, 1))
	end
	if p1 == keys.enter then
		selectedToRun = getSelected()
		rt:Stop()
	end
end

while true do
	selectedToRun = nil
	Runtime.Draw(rt)
	rt:AddHook(onKey)
	rt:Run()
	rt:RemoveHook(onKey)

	if not selectedToRun then
		break
	end

	local sw, sh = target.getSize()
	local scenarioWin = window.create(target, 1, 1, sw, sh, true)
	local ok, factory = pcall(require, SCENARIOS[selectedToRun].module)
		if ok then
			pcall(factory, scenarioWin)
		end
end
