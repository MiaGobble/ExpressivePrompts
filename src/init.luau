--[=[
	Customizable UI that replaces the default for ProximityPrompt instances.

	Below are the config entries:
	
	```
	-- Since v1.0.0
	Config.BackgroundTransparency number -- The background transparency
	Config.BackgroundColor Color3 -- The background color
	Config.TextColor Color3 -- The text and icon color
	Config.SubTextColor Color3 -- The sub text color
	Config.CornerRadius number -- The corner radius on the main background
	Config.MainSizeSpringSpeed number -- The spring speed for the main size animation
	Config.MainSizeSpringDampening number -- The spring dampening for the main size animation
	Config.MainRotationSpringSpeed number -- The spring speed for the main rotation animation
	Config.MainRotationSpringDampening number -- The spring dampening for the main rotation animation
	Config.MainRotationStrength number -- How far the main frame can rotate
	Config.AspectRatioSpringSpeed number -- The spring speed for the aspect ratio animation
	Config.AspectRatioSpringDampening number -- The spring dampening for the aspect ratio animation
	Config.ProgressBarYScale number -- The Y scale (0-1) of the progress bar size
	Config.ProgressBarColor -- The color of the progress bar
	Config.ProgressBarTransparency number -- The transparency of the progress bar
	Config.ShowShimmer boolean -- Whether the shimmer effect plays when the prompt appears
	Config.GuiOffsetSpringSpeed number -- The spring speed for the BillboardGui animation
	Config.GuiOffsetSpringDampening number -- The spring dampening for the BillboardGui animation

	-- Since v1.1.0
	Config.PromptHeight number -- The offset height for the prompt
	Config.PromptWidth number -- The offset width for the prompt
	Config.TextPaddingLeft number -- The offset padding left to the text
	Config.ActionTextSize number -- The text size of the action text
	Config.ObjectTextSize number -- The text size of the object text
	Config.ActionTextFont Enum.Font -- The text font of the action text
	Config.ObjectTextFont Enum.Font -- The text font of the object text
	Config.ActionTextYOffset number -- The Y offset separating the text labels
	Config.MiddlePadding number -- The middle padding offset between elements
	```

	@class ExpressivePrompts
]=]

local ExpressivePrompts = {}

-- Services
local ProximityPromptService = game:GetService("ProximityPromptService")
local PlayersService = game:GetService("Players")
local TextService = game:GetService("TextService")

if not game:IsLoaded() then -- Useful for when loading this from a script in ReplicatedFirst
	game.Loaded:Wait()
end

-- Imports
local Packages = script:FindFirstChild("Packages")
local Seam = if Packages then require(Packages.Seam) else require(script.Parent.Seam)
local NewInputLabel = require(script.NewInputLabel)
local NewInputConnections = require(script.NewInputConnections)
local BuildFrames = require(script.BuildFrames)

-- Variables
local Scope = Seam.Scope(Seam)
local Player = PlayersService.LocalPlayer
local Gui = nil

-- Config
ExpressivePrompts.Config = {
	-- Since v1.0.0
	BackgroundTransparency = Scope:Value(0.5),
	BackgroundColor = Scope:Value(Color3.new(0.07, 0.07, 0.07)),
	TextColor = Scope:Value(Color3.new(1, 1, 1)),
	SubTextColor = Scope:Value(Color3.new(0.7, 0.7, 0.7)),
	CornerRadius = Scope:Value(16),
	MainSizeSpringSpeed = Scope:Value(20),
	MainSizeSpringDampening = Scope:Value(0.4),
	MainRotationSpringSpeed = Scope:Value(30),
	MainRotationSpringDampening = Scope:Value(0.1),
	MainRotationStrength = Scope:Value(5),
	AspectRatioSpringSpeed = Scope:Value(20),
	AspectRatioSpringDampening = Scope:Value(0.4),
	ProgressBarYScale = Scope:Value(0.1),
	ProgressBarColor = Scope:Value(Color3.new(1, 1, 1)),
	ProgressBarTransparency = Scope:Value(0.5),
	ShowShimmer = Scope:Value(true),
	GuiOffsetSpringSpeed = Scope:Value(15),
	GuiOffsetSpringDampening = Scope:Value(0.5),

	-- Since v1.1.0
	PromptHeight = Scope:Value(72),
	PromptWidth = Scope:Value(72),
	TextPaddingLeft = Scope:Value(72),
	ActionTextSize = Scope:Value(19),
	ObjectTextSize = Scope:Value(14),
	ActionTextFont = Scope:Value(Enum.Font.GothamMedium),
	ObjectTextFont = Scope:Value(Enum.Font.GothamMedium),
	ActionTextYOffset = Scope:Value(9),
	MiddlePadding = Scope:Value(24),
}

local function CreatePrompt(Prompt : ProximityPrompt, InputType : Enum.ProximityPromptInputType)
	local PromptScope = Scope:InnerScope()
	local InputFrameScaleFactor = InputType == Enum.ProximityPromptInputType.Touch and 1.6 or 1.33
	local CurrentFrameScaleFactor = PromptScope:Value(1)
	local PromptTransparency = PromptScope:Value(1)
	local ButtonHeldDown = PromptScope:Value(false)
	local CurrentBarSize = PromptScope:Value(0)

	-- Create reactive values
	local ActionTextSize = PromptScope:Computed(function(Use)
		return TextService:GetTextSize(
			Prompt.ActionText,
			Use(ExpressivePrompts.Config.ActionTextSize),
			Use(ExpressivePrompts.Config.ActionTextFont),
			Vector2.new(1000, 1000)
		)
	end)

	local ObjectTextSize = PromptScope:Computed(function(Use)
		return TextService:GetTextSize(
			Prompt.ObjectText,
			Use(ExpressivePrompts.Config.ObjectTextSize),
			Use(ExpressivePrompts.Config.ObjectTextFont),
			Vector2.new(1000, 1000)
		)
	end)

	local MaxTextWidth = PromptScope:Computed(function(Use)
		return math.max(Use(ActionTextSize).X, Use(ObjectTextSize).X)
	end)

	local PromptWidth = PromptScope:Computed(function(Use)
		local BaseWidth = Use(ExpressivePrompts.Config.PromptWidth)
		local ModifiedWidth = Use(MaxTextWidth) + Use(ExpressivePrompts.Config.TextPaddingLeft) + Use(ExpressivePrompts.Config.MiddlePadding)

		if (Prompt.ActionText ~= nil and Prompt.ActionText ~= "") or (Prompt.ObjectText ~= nil and Prompt.ObjectText ~= "") then
			return ModifiedWidth
		else
			return BaseWidth
		end
	end)

	local ActionTextYOffset = PromptScope:Computed(function(Use)
		local TargetOffset = Use(ExpressivePrompts.Config.ActionTextYOffset)

		if Prompt.ObjectText ~= nil and Prompt.ObjectText ~= "" then
			return TargetOffset
		else
			return 0
		end
	end)

	local UISize = PromptScope:Computed(function(Use)
		return UDim2.fromOffset(Use(PromptWidth), Use(ExpressivePrompts.Config.PromptHeight))
	end)

	local AspectRatioValue = PromptScope:Computed(function(Use)
		return Use(PromptWidth) / Use(ExpressivePrompts.Config.PromptHeight)
	end)

	-- Hook connections (which also control sounds)
	local InputConnections : {RBXScriptConnection} = NewInputConnections(Scope, {
		prompt = Prompt,
		ButtonHeldDown = ButtonHeldDown,
		CurrentBarSize = CurrentBarSize,
		CurrentFrameScaleFactor = CurrentFrameScaleFactor,
		PromptTransparency = PromptTransparency,
		InputFrameScaleFactor = InputFrameScaleFactor,
	})

	-- Make the billboard gui and main frame
	local PromptUI : BillboardGui = PromptScope:New("BillboardGui", {
		Name = `Prompt_{Prompt:GetFullName()}`,
		AlwaysOnTop = true,
		Parent = Gui,
		Adornee = Prompt.Parent,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Size = UISize,

		SizeOffset = PromptScope:Computed(function(Use)
			return Vector2.new(
				Prompt.UIOffset.X / Use(UISize).Width.Offset,
				Prompt.UIOffset.Y / Use(UISize).Height.Offset
			)
		end),

		StudsOffset = PromptScope:Spring(PromptScope:Computed(function(Use)
			return Use(PromptTransparency) < 1 and Vector3.new(0, 0, 0) or Vector3.new(-1, 0, 0)
		end), ExpressivePrompts.Config.GuiOffsetSpringSpeed, ExpressivePrompts.Config.GuiOffsetSpringDampening)
	})

	local Frame : CanvasGroup, ResizeableInputFrame : Frame = unpack(BuildFrames(
		PromptScope,
		Seam,
		ExpressivePrompts.Config,
		PromptUI,
		ButtonHeldDown,
		PromptTransparency,
		AspectRatioValue,
		CurrentBarSize,
		CurrentFrameScaleFactor
	))

	-- Make the text labels
	local ActionText = PromptScope:New("TextLabel", {
		Name = "ActionText",
		Size = UDim2.fromScale(1, 1),
		Font = ExpressivePrompts.Config.ActionTextFont,
		TextSize = ExpressivePrompts.Config.ActionTextSize,
		BackgroundTransparency = 1,
		TextColor3 = ExpressivePrompts.Config.TextColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = Frame,
		Text = Prompt.ActionText,
        AutoLocalize = Prompt.AutoLocalize,
        RootLocalizationTable = Prompt.RootLocalizationTable,

		Position = PromptScope:Computed(function(Use)
			return UDim2.new(0.5, Use(ExpressivePrompts.Config.TextPaddingLeft) - Use(PromptWidth) / 2, 0, Use(ActionTextYOffset))
		end),

		TextTransparency = PromptScope:Spring(PromptScope:Computed(function(Use)
			return Use(ButtonHeldDown) and 1 or 0
		end), 30, 1)
	})

	local ObjectText = PromptScope:New("TextLabel", {
		Name = "ObjectText",
		Size = UDim2.fromScale(1, 1),
		Font = ExpressivePrompts.Config.ObjectTextFont,
		TextSize = ExpressivePrompts.Config.ObjectTextSize,
		BackgroundTransparency = 1,
		TextColor3 = ExpressivePrompts.Config.SubTextColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = Frame,
		Text = Prompt.ObjectText,
        AutoLocalize = Prompt.AutoLocalize,
        RootLocalizationTable = Prompt.RootLocalizationTable,

		Position = PromptScope:Computed(function(Use)
			return UDim2.new(0.5, Use(ExpressivePrompts.Config.TextPaddingLeft) - Use(PromptWidth) / 2, 0, -10)
		end),

		TextTransparency = PromptScope:Spring(PromptScope:Computed(function(Use)
			return Use(ButtonHeldDown) and 1 or 0
		end), 30, 1)
	})

	-- Create the input label
	PromptScope:New(ResizeableInputFrame, {
		[Seam.Children] = NewInputLabel(PromptScope, InputType, Prompt, ExpressivePrompts.Config)
	})

	-- If the user is on mobile or the prompt is clickable, create click detection
	if InputType == Enum.ProximityPromptInputType.Touch or Prompt.ClickablePrompt then
		local IsButtonDown = false

		PromptScope:New(PromptUI, {
			Active = true,

			[Seam.Children] = {
				PromptScope:New("TextButton", {
					BackgroundTransparency = 1,
					TextTransparency = 1,
					Size = UDim2.fromScale(1, 1),
		
					[PromptScope:OnEvent "InputBegan"] = function(input)
						if
							(
								input.UserInputType == Enum.UserInputType.Touch
								or input.UserInputType == Enum.UserInputType.MouseButton1
							) and input.UserInputState ~= Enum.UserInputState.Change
						then
							Prompt:InputHoldBegin()
							IsButtonDown = true
						end
					end,
		
					[PromptScope:OnEvent "InputEnded"] = function(input)
						if
							input.UserInputType == Enum.UserInputType.Touch
							or input.UserInputType == Enum.UserInputType.MouseButton1
						then
							if IsButtonDown then
								IsButtonDown = false
								Prompt:InputHoldEnd()
							end
						end
					end,
				})
			}
		})
	end

	-- Finish setup
	PromptTransparency.Value = 0
	
	for _, Connection in InputConnections do
		PromptScope:AddObject(Connection)
	end

	-- Return cleanup function for when prompt is destroyed or player walks out of range
	return function()
		ButtonHeldDown.Value = false
		PromptTransparency.Value = 1

		task.delay(2, function()
			PromptScope:Destroy()
		end)
	end
end

--[=[
	Initializes ExpressivePrompts. Call only one time.
]=]

function ExpressivePrompts.Init()
	if Gui then
		warn("Attempted to call ExpressivePrompts.Init(); already initialized by another script")
		return
	end

	-- All prompts are kept in a single GUI
	Gui = Scope:New("ScreenGui", {
		Name = "ExpressivePromptsGui",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		Parent = Player:WaitForChild("PlayerGui"),
	})

	-- When a prompt is shown, create the prompt UI
	ProximityPromptService.PromptShown:Connect(function(Prompt : ProximityPrompt, InputType : Enum.ProximityPromptInputType)
		-- We refresh proximity prompts with default style so that we don't show overlapping UI
		if Prompt.Style == Enum.ProximityPromptStyle.Default then
			local LastParent = Prompt.Parent

			Prompt.Style = Enum.ProximityPromptStyle.Custom
			Prompt.Parent = nil

			task.defer(function()
				Prompt.Parent = LastParent
			end)

			return
		end

		-- If it's a custom prompt style, create the prompt UI and hook it up
		local CleanupFunction = CreatePrompt(Prompt, InputType)
		Prompt.PromptHidden:Once(CleanupFunction)
	end)
end

return ExpressivePrompts