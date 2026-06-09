return function(window)
	local Runtime = require("UISDK/Runtime")
	local e = Runtime.create

	Runtime.new(window or term.current())

	local count, setCount = Runtime.state(0)

	local screen = e("Screen", {
		Visible = true,
	}, {
		Text = e("TextLabel", {
			Text = function() return "Current count is " .. count() end,
		}),
	})

	for i = 1, 10 do
		setCount(count() + 1)
		sleep(1)
	end
end
