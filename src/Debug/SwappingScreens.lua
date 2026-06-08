return function(window)
	local Runtime = require("UISDK/Runtime")
	local Vector2 = require("UISDK/Primitives/Vector2")

	Runtime.new(window or term.current())

	local screen1 = Runtime.Screen()

	local text1 = Runtime.TextLabel()
	text1.Text = "This is screen 1!"
	text1.Color = colors.magenta
	text1.Position = Vector2.new(1, 1)
	screen1:Parent(text1)

	local screen2 = Runtime.Screen()
	screen2.Visible = false

	local text2 = Runtime.TextLabel()
	text2.Text = "This is screen 2!"
	text2.Color = colors.yellow
	text2.Position = Vector2.new(1, 1)
	screen2:Parent(text2)

	for i = 1, 10 do
		screen1.Visible = true
		screen2.Visible = false
		sleep(1)

		screen1.Visible = false
		screen2.Visible = true
		sleep(1)
	end
end
