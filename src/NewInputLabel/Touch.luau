return function(Scope : any)
    return {
        Scope:New("ImageLabel", {
            Name = "ButtonImage",
            BackgroundTransparency = 1,
            ImageTransparency = 1,
            Size = UDim2.fromOffset(25, 31),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Image = "rbxasset://textures/ui/Controls/TouchTapIcon.png",
        })
    }
end