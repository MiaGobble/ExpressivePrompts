--[=[
    Customizable UI that replaces the default for ProximityPrompt instances.

    @class ExpressivePrompts
]=]

local ExpressivePrompts = {}

-- Services
local ProximityPromptService = game:GetService("ProximityPromptService")
local PlayersService = game:GetService("Players")

-- Imports
local Packages = script:FindFirstChild("Packages")
local Seam = if Packages then require(Packages.Seam) else require(script.Parent.Seam)
local NewInputLabel = require(script.NewInputLabel)
local NewInputConnections = require(script.NewInputConnections)
local BuildTextLabels = require(script.BuildTextLabels)
local BuildFrames = require(script.BuildFrames)
local UpdateUIFromPrompt = require(script.UpdateUIFromPrompt)

-- Variables
local Scope = Seam.Scope(Seam)
local Player = PlayersService.LocalPlayer
local Gui = nil

local function GetUpdateCallback(...)
	local Args = {...}

	return function()
		UpdateUIFromPrompt(unpack(Args))
	end
end

local function CreatePrompt(Prompt : ProximityPrompt, InputType : Enum.ProximityPromptInputType)
	local PromptScope = Scope:InnerScope()
	local InputFrameScaleFactor = InputType == Enum.ProximityPromptInputType.Touch and 1.6 or 1.33
	local CurrentFrameScaleFactor = PromptScope:Value(1)
	local PromptTransparency = PromptScope:Value(1)
	local ButtonHeldDown = PromptScope:Value(false)
	local AspectRatioValue = PromptScope:Value(1)
	local CurrentBarSize = PromptScope:Value(0)

	local InputConnections : {RBXScriptConnection} = NewInputConnections(PromptScope, {
		prompt = Prompt,
		ButtonHeldDown = ButtonHeldDown,
		CurrentBarSize = CurrentBarSize,
		CurrentFrameScaleFactor = CurrentFrameScaleFactor,
		PromptTransparency = PromptTransparency,
		InputFrameScaleFactor = InputFrameScaleFactor,
	})

	local PromptUI : BillboardGui = PromptScope:New("BillboardGui", {
		Name = `Prompt_{Prompt:GetFullName()}`,
		AlwaysOnTop = true,
		Parent = Gui,
		Adornee = Prompt.Parent,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

		StudsOffset = PromptScope:Spring(PromptScope:Computed(function(Use)
			return Use(PromptTransparency) < 1 and Vector3.new(0, 0, 0) or Vector3.new(-1, 0, 0)
		end), 15, 0.5)
	})

	local Frame : CanvasGroup, ResizeableInputFrame : Frame = unpack(BuildFrames(
        PromptScope,
        Seam,
		PromptUI,
		ButtonHeldDown,
		PromptTransparency,
		AspectRatioValue,
		CurrentBarSize,
		CurrentFrameScaleFactor
	))

	local ActionText : TextLabel, ObjectText : TextLabel = unpack(BuildTextLabels(
        PromptScope,
		Frame,
		ButtonHeldDown
	))

	PromptScope:New(ResizeableInputFrame, {
		[Seam.Children] = NewInputLabel(PromptScope, InputType, Prompt)
	})

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

	local UpdateCallback = GetUpdateCallback(
        PromptScope,
		Prompt,
		PromptUI,
		AspectRatioValue,
		ActionText,
		ObjectText
	)

	InputConnections[# InputConnections+1] = Prompt.Changed:Connect(UpdateCallback)
	UpdateCallback()
	PromptTransparency.Value = 0
    
    for _, Connection in InputConnections do
        PromptScope:AddObject(Connection)
    end

	return function()
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

    Gui = Scope:New("ScreenGui", {
		Name = "ExpressivePromptsGui",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		Parent = Player:WaitForChild("PlayerGui"),
	})

    ProximityPromptService.PromptShown:Connect(function(Prompt : ProximityPrompt, InputType : Enum.ProximityPromptInputType)
        if Prompt.Style == Enum.ProximityPromptStyle.Default then
            local LastParent = Prompt.Parent

			Prompt.Style = Enum.ProximityPromptStyle.Custom
            Prompt.Parent = nil

            -- We refresh proximity prompts with default style so that we don't show overlapping UI
            task.defer(function()
                Prompt.Parent = LastParent
            end)

            return
		end

		local CleanupFunction = CreatePrompt(Prompt, InputType)

		Prompt.PromptHidden:Once(CleanupFunction)
    end)
end

return ExpressivePrompts