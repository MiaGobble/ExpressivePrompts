return function(Scope : any, ParentFrame : Instance, ButtonHeldDown : any) : {any}
    local ActionText = Scope:New("TextLabel", {
		Name = "ActionText",
		Size = UDim2.fromScale(1, 1),
		Font = Enum.Font.GothamMedium,
		TextSize = 19,
		BackgroundTransparency = 1,
		TextColor3 = Color3.new(1, 1, 1),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = ParentFrame,

		TextTransparency = Scope:Spring(Scope:Computed(function(Use)
			return Use(ButtonHeldDown) and 1 or 0
		end), 30, 1)
	})

	local ObjectText = Scope:New("TextLabel", {
		Name = "ObjectText",
		Size = UDim2.fromScale(1, 1),
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		BackgroundTransparency = 1,
		TextColor3 = Color3.new(0.7, 0.7, 0.7),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = ParentFrame,

		TextTransparency = Scope:Spring(Scope:Computed(function(Use)
			return Use(ButtonHeldDown) and 1 or 0
		end), 30, 1)
	})

    return {ActionText, ObjectText}
end