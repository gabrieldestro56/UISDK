local dependencies = {
	{
		url = "https://example.com/shop/inventory.lua",
		path = "shop/inventory.lua",
	},
}

local function downloadIfMissing(url, path)
	if fs.exists(path) then
		return
	end

	print("Missing " .. path .. ", downloading...")

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
end

for _, dep in ipairs(dependencies) do
	downloadIfMissing(dep.url, dep.path)
end
