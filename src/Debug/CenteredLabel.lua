return function(window)
	local Runtime = require("UISDK/Runtime")
	local Vector2 = require("UISDK/Primitives/Vector2")
	local e = Runtime.create

	local rt = Runtime.new(window or term.current())

	e("Screen", { Visible = true }, {
		Label = e("TextLabel", {
			Text = "Centered!",
			Color = colors and colors.yellow or 1,
			Position = Vector2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
		})
	})

	rt:Run()
end
