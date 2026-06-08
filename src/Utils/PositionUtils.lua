local Runtime = require("UISDK/Runtime")
local PositionUtils = {}

function PositionUtils.getCenterOfScreen(runtime)
	runtime = runtime or Runtime.current()
	assert(type(runtime.GetSize) == "function", "getCenterOfScreen requires a Runtime")

	local x, y = runtime:GetSize()
	return x / 2, y / 2
end

return PositionUtils
