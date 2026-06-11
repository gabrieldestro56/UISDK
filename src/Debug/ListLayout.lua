---@diagnostic disable: undefined-global
return function(window)
	local Runtime = require("UISDK/Runtime")
	local Vector2 = require("UISDK/Primitives/Vector2")
	local e = Runtime.create

	local rt = Runtime.new(window or term.current())

	-- LayoutOrder: children defined as C,A,B but LayoutOrder sorts them A,B,C
	-- ZIndex: two overlapping frames — blue(0) drawn first, red(1) drawn on top

	e("Screen", { Visible = true }, {
		LOTitle = e("TextLabel", {
			Text = "LayoutOrder",
			Color = colors.yellow,
			Position = Vector2.new(2, 1),
		}),
		LOSubtitle = e("TextLabel", {
			Text = "defined C,A,B -> renders A,B,C",
			Color = colors.lightGray,
			Position = Vector2.new(2, 2),
		}),
		LOFrame = e("Frame", {
			Size = Vector2.new(22, 10),
			Position = Vector2.new(2, 3),
			BackgroundColor = colors.gray,
		}, {
			Layout = e("UIListLayout", { LayoutDirection = "Vertical", Padding = 1 }),
			-- defined out of order; LayoutOrder determines position
			ItemC = e("Frame", {
				Size = Vector2.new(20, 2),
				BackgroundColor = colors.blue,
				LayoutOrder = 3,
			}, {
				Label = e("TextLabel", { Text = "C  LayoutOrder=3", Color = colors.white, Position = Vector2.new(2, 1) }),
			}),
			ItemA = e("Frame", {
				Size = Vector2.new(20, 2),
				BackgroundColor = colors.red,
				LayoutOrder = 1,
			}, {
				Label = e("TextLabel", { Text = "A  LayoutOrder=1", Color = colors.white, Position = Vector2.new(2, 1) }),
			}),
			ItemB = e("Frame", {
				Size = Vector2.new(20, 2),
				BackgroundColor = colors.green,
				LayoutOrder = 2,
			}, {
				Label = e("TextLabel", { Text = "B  LayoutOrder=2", Color = colors.white, Position = Vector2.new(2, 1) }),
			}),
		}),

		ZITitle = e("TextLabel", {
			Text = "ZIndex",
			Color = colors.yellow,
			Position = Vector2.new(27, 1),
		}),
		ZISubtitle = e("TextLabel", {
			Text = "ZIndex=0 under ZIndex=1",
			Color = colors.lightGray,
			Position = Vector2.new(27, 2),
		}),
		-- blue drawn first (ZIndex=0), red overlaps on top (ZIndex=1)
		ZIBlue = e("Frame", {
			Size = Vector2.new(14, 7),
			Position = Vector2.new(27, 3),
			BackgroundColor = colors.blue,
			ZIndex = 0,
		}, {
			Label = e("TextLabel", { Text = "ZIndex=0", Color = colors.white, Position = Vector2.new(2, 1) }),
		}),
		ZIRed = e("Frame", {
			Size = Vector2.new(14, 7),
			Position = Vector2.new(32, 6),
			BackgroundColor = colors.red,
			ZIndex = 1,
		}, {
			Label = e("TextLabel", { Text = "ZIndex=1", Color = colors.white, Position = Vector2.new(2, 1) }),
		}),
	})

	rt:Run()
end
