return function(window)
	local Runtime = require("UISDK/Runtime")
	local Vector2 = require("UISDK/Primitives/Vector2")
	local e = Runtime.create

	local rt = Runtime.new(window or term.current())
	local getCount, setCount = Runtime.state(0)

	e("Screen", { Visible = true }, {
		Minus = e("Frame", {
			Size = Vector2.new(5, 3),
			Position = Vector2.fromScale(0.35, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor = colors.red,
			BorderRadius = 0,
			BorderColor = colors.orange,
			OnClick = function() setCount(getCount() - 1) end,
		}, {
			Label = e("TextLabel", {
				Text = " - ",
				Color = colors.white,
				Position = Vector2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
			}),
		}),
		Count = e("TextLabel", {
			Text = function() return tostring(getCount()) end,
			Color = colors.white,
			Position = Vector2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
		}),
		Plus = e("Frame", {
			Size = Vector2.new(5, 3),
			Position = Vector2.fromScale(0.65, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor = colors.green,
			BorderRadius = 0,
			BorderColor = colors.lime,
			OnClick = function() setCount(getCount() + 1) end,
		}, {
			Label = e("TextLabel", {
				Text = " + ",
				Color = colors.white,
				Position = Vector2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
			}),
		}),
	})

	rt:Run()
end
