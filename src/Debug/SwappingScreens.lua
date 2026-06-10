return function(window)
	local Runtime = require("UISDK/Runtime")
	local Vector2 = require("UISDK/Primitives/Vector2")
	local e = Runtime.create

	local rt = Runtime.new(window or term.current())

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

	local tickCount = 0
	rt:AddHook(function(event)
		if event ~= "tick" then
			return
		end
		tickCount = tickCount + 1
		if tickCount >= rt._Hz then
			tickCount = 0
			screen1.Visible = not screen1.Visible
			screen2.Visible = not screen2.Visible
		end
	end)

	rt:SetHz(20)
	rt:Run()
end
