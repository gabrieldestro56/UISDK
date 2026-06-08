local dependencies = {
	{
		url = "https://raw.githubusercontent.com/gabrieldestro56/UISDK/refs/heads/main/src/Components/Screen.lua",
		path = "UISDK/Components/Screen",
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
