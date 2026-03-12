-- Constants
local GAMEPAD_BUTTON_IMAGE = require(script.GamepadButtonImage)

return function(Scope : any, prompt, Config : {})
    if not GAMEPAD_BUTTON_IMAGE[prompt.GamepadKeyCode] then
        return
    end

    return {
        Scope:New("ImageLabel", {
            Name = "ButtonImage",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.fromOffset(24, 24),
            Position = UDim2.fromScale(0.5, 0.5),
            BackgroundTransparency = 1,
            ImageTransparency = 1,
            Image = GAMEPAD_BUTTON_IMAGE[prompt.GamepadKeyCode],
            ImageColor3 = Config.TextColor,
        })
    }
end