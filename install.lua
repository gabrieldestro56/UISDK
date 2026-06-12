local dependencies = {
	-- Primitives
	{
		url = "https://raw.githubusercontent.com/gabrieldestro56/UISDK/refs/heads/main/src/Primitives/Component.lua",
		path = "UISDK/Primitives/Component",
	},
	{
		url = "https://raw.githubusercontent.com/gabrieldestro56/UISDK/refs/heads/main/src/Primitives/Vector2.lua",
		path = "UISDK/Primitives/Vector2",
	},

	-- Components
	{
		url = "https://raw.githubusercontent.com/gabrieldestro56/UISDK/refs/heads/main/src/Components/Frame.lua",
		path = "UISDK/Components/Frame",
	},
	{
		url = "https://raw.githubusercontent.com/gabrieldestro56/UISDK/refs/heads/main/src/Components/Screen.lua",
		path = "UISDK/Components/Screen",
	},
	{
		url = "https://raw.githubusercontent.com/gabrieldestro56/UISDK/refs/heads/main/src/Components/TextLabel.lua",
		path = "UISDK/Components/TextLabel",
	},
	{
		url = "https://raw.githubusercontent.com/gabrieldestro56/UISDK/refs/heads/main/src/Components/UIListLayout.lua",
		path = "UISDK/Components/UIListLayout",
	},

	-- Debug
	{
		url = "https://raw.githubusercontent.com/gabrieldestro56/UISDK/refs/heads/main/src/Debug/BouncingFrame.lua",
		path = "UISDK/Debug/BouncingFrame",
	},
	{
		url = "https://raw.githubusercontent.com/gabrieldestro56/UISDK/refs/heads/main/src/Debug/CenteredLabel.lua",
		path = "UISDK/Debug/CenteredLabel",
	},
	{
		url = "https://raw.githubusercontent.com/gabrieldestro56/UISDK/refs/heads/main/src/Debug/Counter.lua",
		path = "UISDK/Debug/Counter",
	},
	{
		url = "https://raw.githubusercontent.com/gabrieldestro56/UISDK/refs/heads/main/src/Debug/ListLayout.lua",
		path = "UISDK/Debug/ListLayout",
	},
	{
		url = "https://raw.githubusercontent.com/gabrieldestro56/UISDK/refs/heads/main/src/Debug/Menu.lua",
		path = "UISDK/Debug/Menu",
	},
	{
		url = "https://raw.githubusercontent.com/gabrieldestro56/UISDK/refs/heads/main/src/Debug/SwappingScreens.lua",
		path = "UISDK/Debug/SwappingScreens",
	},

	-- Runtime.lua
	{
		url = "https://raw.githubusercontent.com/gabrieldestro56/UISDK/refs/heads/main/src/Runtime.lua",
		path = "UISDK/Runtime",
	},

	-- Utils
	{
		url = "https://raw.githubusercontent.com/gabrieldestro56/UISDK/refs/heads/main/src/Utils/PositionUtils.lua",
		path = "UISDK/Utils/PositionUtils",
	},
}

-- Setup wizard drawn with the raw term API: UISDK cannot be used to install itself.

local screenWidth, screenHeight = term.getSize()
local isColor = term.isColor()

-- Standard computers only render the grayscale palette reliably, so every
-- accent color carries a grayscale-safe fallback.
local function pick(advanced, basic)
	if isColor then
		return advanced
	end
	return basic
end

local theme = {
	bg = colors.black,
	fg = colors.white,
	dim = colors.lightGray,
	titleBg = pick(colors.blue, colors.lightGray),
	titleFg = pick(colors.white, colors.black),
	accent = pick(colors.lightBlue, colors.white),
	good = pick(colors.lime, colors.white),
	bad = pick(colors.red, colors.white),
	barTrack = colors.gray,
	barFill = pick(colors.lime, colors.white),
	buttonBg = colors.gray,
	buttonFg = colors.white,
	buttonSelBg = pick(colors.blue, colors.white),
	buttonSelFg = pick(colors.white, colors.black),
}

local function fill(x, y, width, height, bg)
	term.setBackgroundColor(bg)
	local line = string.rep(" ", width)

	for row = y, y + height - 1 do
		term.setCursorPos(x, row)
		term.write(line)
	end
end

local function writeAt(x, y, text, fg, bg)
	term.setCursorPos(x, y)
	term.setTextColor(fg)
	term.setBackgroundColor(bg)
	term.write(text)
end

local function centerText(y, text, fg, bg)
	local x = math.max(1, math.floor((screenWidth - #text) / 2) + 1)
	writeAt(x, y, text, fg, bg)
end

-- Keeps the tail of long module paths visible on narrow (pocket) screens.
local function truncate(text, max)
	if #text <= max then
		return text
	end
	return "..." .. text:sub(#text - max + 4)
end

local function wrap(text, max)
	local lines = {}
	local current = ""

	local function push()
		if current ~= "" then
			lines[#lines + 1] = current
			current = ""
		end
	end

	for word in tostring(text):gmatch("%S+") do
		while #word > max do
			push()
			lines[#lines + 1] = word:sub(1, max)
			word = word:sub(max + 1)
		end

		if current == "" then
			current = word
		elseif #current + 1 + #word <= max then
			current = current .. " " .. word
		else
			push()
			current = word
		end
	end

	push()
	return lines
end

local function centerWrapped(y, text, fg)
	for _, line in ipairs(wrap(text, screenWidth - 4)) do
		centerText(y, line, fg, theme.bg)
		y = y + 1
	end
	return y
end

local function drawChrome()
	fill(1, 1, screenWidth, screenHeight, theme.bg)
	fill(1, 1, screenWidth, 1, theme.titleBg)
	writeAt(2, 1, "UISDK Setup", theme.titleFg, theme.titleBg)
end

local function layoutButtons(y, labels)
	local gap = 3
	local totalWidth = gap * (#labels - 1)

	for _, label in ipairs(labels) do
		totalWidth = totalWidth + #label + 2
	end

	local x = math.max(1, math.floor((screenWidth - totalWidth) / 2) + 1)
	local buttons = {}

	for _, label in ipairs(labels) do
		local width = #label + 2
		buttons[#buttons + 1] = { label = label, x = x, y = y, width = width }
		x = x + width + gap
	end

	return buttons
end

local function drawButtons(buttons, selected)
	for index, button in ipairs(buttons) do
		local isSelected = index == selected
		writeAt(
			button.x,
			button.y,
			" " .. button.label .. " ",
			isSelected and theme.buttonSelFg or theme.buttonFg,
			isSelected and theme.buttonSelBg or theme.buttonBg
		)
	end
end

-- Arrows/tab move, enter/space confirm, Q jumps to the last (cancel) button.
-- Mouse clicks only fire on advanced computers; keys cover the rest.
local function chooseButton(buttons)
	local selected = 1
	drawButtons(buttons, selected)

	while true do
		local event, p1, p2, p3 = os.pullEvent()

		if event == "key" then
			if p1 == keys.left or p1 == keys.up then
				selected = selected > 1 and selected - 1 or #buttons
				drawButtons(buttons, selected)
			elseif p1 == keys.right or p1 == keys.down or p1 == keys.tab then
				selected = selected < #buttons and selected + 1 or 1
				drawButtons(buttons, selected)
			elseif p1 == keys.enter or p1 == keys.numPadEnter or p1 == keys.space then
				return selected
			elseif p1 == keys.q then
				return #buttons
			end
		elseif event == "mouse_click" then
			for index, button in ipairs(buttons) do
				if p3 == button.y and p2 >= button.x and p2 < button.x + button.width then
					return index
				end
			end
		end
	end
end

local function showWelcome()
	drawChrome()

	local y = 3
	y = centerWrapped(y, "Welcome to the UISDK Setup Wizard.", theme.accent)
	y = y + 1
	y = centerWrapped(y, "This wizard will download " .. #dependencies .. " files and install them to /UISDK.", theme.fg)

	local buttons = layoutButtons(screenHeight - 1, { "Install", "Cancel" })
	return chooseButton(buttons) == 1
end

local function drawProgress(index, total, path)
	drawChrome()

	local barWidth = screenWidth - 4
	local y = math.floor(screenHeight / 2) - 1

	centerText(y - 2, "Installing UISDK...", theme.accent, theme.bg)
	writeAt(3, y, truncate(path, barWidth), theme.dim, theme.bg)

	local filled = math.floor(barWidth * (index - 1) / total)
	fill(3, y + 2, barWidth, 1, theme.barTrack)
	if filled > 0 then
		fill(3, y + 2, filled, 1, theme.barFill)
	end

	centerText(y + 4, index .. " / " .. total, theme.fg, theme.bg)
end

local function showDone(total)
	drawChrome()

	local y = math.floor(screenHeight / 2) - 2
	centerText(y, "Installation complete!", theme.good, theme.bg)
	centerWrapped(y + 2, total .. " files installed to /UISDK.", theme.dim)
	centerText(screenHeight - 1, "Press any key to exit", theme.fg, theme.bg)

	os.pullEvent("key")
end

local function showError(message, canRetry)
	drawChrome()

	centerText(3, "Install failed", theme.bad, theme.bg)
	centerWrapped(5, message, theme.dim)

	local labels = canRetry and { "Retry", "Quit" } or { "Quit" }
	local buttons = layoutButtons(screenHeight - 1, labels)
	local choice = chooseButton(buttons)
	return canRetry and choice == 1
end

local function download(dep)
	local response, err = http.get(dep.url)
	if not response then
		error("Failed to download " .. dep.path .. (err and (": " .. err) or ""), 0)
	end

	local content = response.readAll()
	response.close()

	local dir = fs.getDir(dep.path)
	if dir ~= "" and not fs.exists(dir) then
		fs.makeDir(dir)
	end

	-- Older installs wrote extensionless files require() can't find; clean them up.
	if fs.exists(dep.path) and not fs.isDir(dep.path) then
		fs.delete(dep.path)
	end

	local file = fs.open(dep.path .. ".lua", "w")
	file.write(content)
	file.close()
end

local function run()
	if not http then
		showError("The HTTP API is disabled. Enable it in the ComputerCraft config, then run the installer again.", false)
		return false, "[UISDK] Install failed: HTTP API disabled"
	end

	if not showWelcome() then
		return false, "[UISDK] Install cancelled"
	end

	local index = 1
	while index <= #dependencies do
		drawProgress(index, #dependencies, dependencies[index].path)

		local ok, err = pcall(download, dependencies[index])
		if ok then
			index = index + 1
		elseif not showError(tostring(err), true) then
			return false, "[UISDK] Install did not finish"
		end
	end

	showDone(#dependencies)
	return true, "[UISDK] Latest version installed"
end

term.setCursorBlink(false)
local installed, message = run()

term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1, 1)
print(message)

if installed then
	fs.delete(shell.getRunningProgram())
end
