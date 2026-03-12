return function(Scope : any, Seam : any, Config : {}, PromptUI, ButtonHeldDown, PromptTransparency, AspectRatioValue, CurrentBarSize, CurrentFrameScaleFactor) : {any}
	local Frame = Scope:New("CanvasGroup", {
		Size = Scope:Spring(Scope:Computed(function(Use)
			return Use(ButtonHeldDown) and UDim2.fromScale(0.5, 1) or UDim2.fromScale(1, 1)
		end), Config.MainSizeSpringSpeed, Config.MainSizeSpringDampening),

		Rotation = Scope:Spring(Scope:Computed(function(Use)
			local RotationStrength = Use(Config.MainRotationStrength)

			if Use(ButtonHeldDown) then
				return -RotationStrength
			elseif Use(PromptTransparency) < 1 then
				return 0
			else
				return RotationStrength
			end
		end), Config.MainRotationSpringSpeed, Config.MainRotationSpringDampening),
		
		BackgroundTransparency = Config.BackgroundTransparency,
		GroupTransparency = Scope:Spring(PromptTransparency, 30, 1),
		BackgroundColor3 = Config.BackgroundColor,
		Parent = PromptUI,

		[Seam.Children] = {
			Scope:New("UICorner", {
				CornerRadius = Scope:Computed(function(Use)
					return UDim.new(0, Use(Config.CornerRadius))
				end),
			}),

			Scope:New("UIAspectRatioConstraint", {
				AspectRatio = Scope:Spring(Scope:Computed(function(Use)
					return Use(ButtonHeldDown) and 1 or Use(AspectRatioValue)
				end), Config.AspectRatioSpringSpeed, Config.AspectRatioSpringDampening),
			}),

			Scope:New("Frame", {
				Name = "ProgressBar",
				Position = UDim2.fromScale(0, 1),
				AnchorPoint = Vector2.new(0, 1),
				BorderSizePixel = 0,
				BackgroundColor3 = Config.ProgressBarColor,
				BackgroundTransparency = Config.ProgressBarTransparency,
				Size = Scope:Computed(function(Use)
					return UDim2.fromScale(Use(CurrentBarSize), Use(Config.ProgressBarYScale))
				end),
			}),

			Scope:New("UIGradient", {
				Rotation = 45,
				Enabled = Config.ShowShimmer,

				Transparency = NumberSequence.new{
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.5, 0.5),
					NumberSequenceKeypoint.new(1, 0),
				},

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