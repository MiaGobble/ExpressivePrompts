-- Constants
local KEYBOARD_BUTTON_IMAGE = require(script.KeyboardButtonImage)
local KEYBOARD_BUTTON_ICON_MAPPING = require(script.KeyboardButtonIconMapping)
local KEYCODE_TO_TEXT_MAPPING = require(script.KeyCodeToTextMapping)

-- Services
local UserInputService = game:GetService("UserInputService")

return function(Scope : any, prompt, Config : {})
    local AddedChildren = {}
	local buttonTextString = UserInputService:GetStringForKeyCode(prompt.KeyboardKeyCode)

	local buttonTextImage = KEYBOARD_BUTTON_IMAGE[prompt.KeyboardKeyCode]
	if buttonTextImage == nil then
		buttonTextImage = KEYBOARD_BUTTON_ICON_MAPPING[buttonTextString]
	end

	if buttonTextImage == nil then
		local keyCodeMappedText = KEYCODE_TO_TEXT_MAPPING[prompt.KeyboardKeyCode]
		if keyCodeMappedText then
			buttonTextString = keyCodeMappedText
		end
	end

	AddedChildren[#AddedChildren + 1] = Scope:New("ImageLabel", {
		Name = "ButtonImage",
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(28, 30),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Image = "rbxasset://textures/ui/Controls/key_single.png",
		ImageColor3 = Config.TextColor,
	})

	if buttonTextImage then
		AddedChildren[#AddedChildren + 1] = Scope:New("ImageLabel", {
			Name = "ButtonImage",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(36, 36),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = buttonTextImage,
			ImageColor3 = Config.TextColor,
		})
	elseif buttonTextString ~= nil and buttonTextString ~= "" then
		AddedChildren[#AddedChildren + 1] = Scope:New("TextLabel", {
			Name = "ButtonText",
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromOffset(0, -1),
			Font = Enum.Font.GothamMedium,
			TextSize = if string.len(buttonTextString) > 2 then 12 else 14,
			BackgroundTransparency = 1,
			TextColor3 = Config.TextColor,
			TextXAlignment = Enum.TextXAlignment.Center,
			Text = buttonTextString,
		})
	else
		error(
			"ProximityPrompt '"
				.. prompt.Name
				.. "' has an unsupported keycode for rendering UI: "
				.. tostring(prompt.KeyboardKeyCode)
		)
	end
    
    return AddedChildren
end