return function(Scope : any, Seam : any, PromptUI, ButtonHeldDown, PromptTransparency, AspectRatioValue, CurrentBarSize, CurrentFrameScaleFactor) : {any}
	local Frame = Scope:New("CanvasGroup", {
		Size = Scope:Spring(Scope:Computed(function(Use)
			return Use(ButtonHeldDown) and UDim2.fromScale(0.5, 1) or UDim2.fromScale(1, 1)
		end), 20, 0.4),

		Rotation = Scope:Spring(Scope:Computed(function(Use)
			if Use(ButtonHeldDown) then
				return -5
			elseif Use(PromptTransparency) < 1 then
				return 0
			else
				return 5
			end
		end), 30, 0.1),
		
		BackgroundTransparency = 0.5,
		GroupTransparency = Scope:Spring(PromptTransparency, 30, 1),
		BackgroundColor3 = Color3.new(0.07, 0.07, 0.07),
		Parent = PromptUI,

		[Seam.Children] = {
			Scope:New("UICorner", {
				CornerRadius = UDim.new(0, 16),
			}),

			Scope:New("UIAspectRatioConstraint", {
				AspectRatio = Scope:Spring(Scope:Computed(function(Use)
					return Use(ButtonHeldDown) and 1 or Use(AspectRatioValue)
				end), 20, 0.4),
			}),

			Scope:New("Frame", {
				Name = "ProgressBar",
				Position = UDim2.fromScale(0, 1),
				AnchorPoint = Vector2.new(0, 1),
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 0.5,
				Size = Scope:Computed(function(Use)
					return UDim2.fromScale(Use(CurrentBarSize), 0.1)
				end),
			}),

			Scope:New("UIGradient", {
				Transparency = NumberSequence.new{
					NumberSequenceKeypoint.new(0, 0),
					--NumberSequenceKeypoint.new(0.2, 0),
					NumberSequenceKeypoint.new(0.5, 0.5),
					--NumberSequenceKeypoint.new(0.8, 0),
					NumberSequenceKeypoint.new(1, 0),
				},

				Rotation = 45,
				Offset = Scope:Spring(Scope:Computed(function(Use)
					return Use(PromptTransparency) < 1 and Vector2.new(1, 0) or Vector2.new(-1, 0)
				end), 8, 1),
			}),
		},
	})

	local InputFrame = Scope:New("Frame", {
		Name = "InputFrame",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Parent = Frame,
	})

	local ResizeableInputFrame = Scope:New("Frame", {
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Parent = InputFrame,

		[Seam.Children] = {
			Scope:New("UIScale", {
				Scale = Scope:Spring(CurrentFrameScaleFactor, 20, 0.7),
			}),

			Scope:New("Frame", {
				Name = "RoundFrame",
				Size = UDim2.fromOffset(48, 48),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
		
				[Seam.Children] = {
					Scope:New("UICorner", {
						CornerRadius = UDim.new(0.5, 0),
					}),
				}
			})
		}
	})

	return {Frame, ResizeableInputFrame}
end