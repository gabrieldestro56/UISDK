return function(window)
	local Runtime = require("UISDK/Runtime")
	local Vector2 = require("UISDK/Primitives/Vector2")
	local e = Runtime.create

	Runtime.new(window or term.current())

	local screen1 = e("Screen", { Visible = true }, {
		Text = e("TextLabel", {
			Text = "This is screen 1!",
			Color = colors.magenta,
			Position = Vector2.new(1, 1),
		})
	})

	local screen2 = e("Screen", { Visible = false }, {
		Text = e("TextLabel", {
			Text = "This is screen 2!",
			Color = colors.yellow,
			Position = Vector2.new(1, 1),
		})
	})

	for i = 1, 10 do
		screen1.Visible = true
		screen2.Visible = false
		sleep(1)

		screen1.Visible = false
		screen2.Visible = true
		sleep(1)
	end
end
