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

local function downloadIfMissing(url, path)
	print("[UISDK]" .. path .. " is being downloaded...")

	local response = http.get(url)
	if not response then
		error("Failed to download " .. path)
	end

	local content = response.readAll()
	response.close()

	local dir = fs.getDir(path)
	if dir ~= "" and not fs.exists(dir) then
		fs.makeDir(dir)
	end

	local file = fs.open(path, "w")
	file.write(content)
	file.close()

	print("[UISDK] Downloaded " .. path .. " successfully.")
end

for _, dep in ipairs(dependencies) do
	downloadIfMissing(dep.url, dep.path)
end

print("[UISDK] Latest version installed")
fs.delete(shell.getRunningProgram())
