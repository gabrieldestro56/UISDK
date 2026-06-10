return function(window)
	local Runtime = require("UISDK/Runtime")
	local Vector2 = require("UISDK/Primitives/Vector2")
	local e = Runtime.create

	local rt = Runtime.new(window or term.current())
	rt.AutoDraw = false

	local FRAME_W = 16
	local FRAME_H = 5

	local bounces, setBounces = Runtime.state(0)

	local colorPalette = {
		colors.red, colors.green, colors.blue, colors.yellow,
		colors.cyan, colors.magenta, colors.orange, colors.lime,
		colors.purple, colors.pink, colors.lightBlue,
	}

	-- Fixed centered position inside frame (accounts for 1-wide border)
	local labelX = math.floor(FRAME_W / 2) - 3
	local labelY = math.ceil(FRAME_H / 2)

	local label = e("TextLabel", {
		Text = function() return "Bounces: " .. tostring(bounces()) end,
		Color = colors.white,
		Position = Vector2.new(labelX, labelY),
	})

	local frame = e("Frame", {
		Size = Vector2.new(FRAME_W, FRAME_H),
		Position = Vector2.new(1, 1),
		BackgroundColor = colors.gray,
		BorderRadius = 1,
		BorderColor = colors.white,
		Visible = true,
	})

	frame:AddChild(label)

	local screen = e("Screen", { Visible = true })
	screen:AddChild(frame)

	local w, h = Runtime.GetSize()
	local x, y = 1, 1
	local dx, dy = 1, 1

	while true do
		x = x + dx
		y = y + dy

		local bounced = false

		if x < 1 then
			x = 1
			dx = 1
			bounced = true
		elseif x + FRAME_W - 1 > w then
			x = w - FRAME_W + 1
			dx = -1
			bounced = true
		end

		if y < 1 then
			y = 1
			dy = 1
			bounced = true
		elseif y + FRAME_H - 1 > h then
			y = h - FRAME_H + 1
			dy = -1
			bounced = true
		end

		frame.Position = Vector2.new(x, y)

		if bounced then
			frame.BackgroundColor = colorPalette[math.random(1, #colorPalette)]
			setBounces(bounces() + 1)
		end

		Runtime.Draw(rt)
		sleep(0.05)
	end
end
