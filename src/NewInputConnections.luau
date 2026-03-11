-- Types
type Properties = {
    prompt: ProximityPrompt,
    ButtonHeldDown: any,
    CurrentBarSize: any,
    CurrentFrameScaleFactor: any,
    PromptTransparency: any,
    InputFrameScaleFactor: any,
}

-- Constants
local APPEAR_SOUND = "rbxassetid://10066931761"
local CLICK_SOUND = "rbxassetid://10128760939"
local HOLD_SOUND = "rbxassetid://421058925"
local TRIGGER_SOUND = "rbxassetid://10128766965"

-- Services
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local function PlaySound(Scope : any, SoundId : string, Properties : {[string]: any}?)
	local Sound = SoundService:FindFirstChild(SoundId)

	if not Sound then
		Sound = Scope:New(Scope:New("Sound", {
			Name = SoundId,
			SoundId = SoundId,
			Volume = 0.35,
			Parent = SoundService,
		}), Properties or {})
	end

	Sound:Play()
end

local function StopSound(SoundId)
	local Sound = SoundService:FindFirstChild(SoundId)

	if Sound then
		Sound:Stop()
	end
end

return function(Scope : any, Properties : Properties) : {RBXScriptConnection}
    local InputConnections = {}
	local HoldStart = os.clock()

	PlaySound(Scope, APPEAR_SOUND)

	if Properties.prompt.HoldDuration > 0 then
		InputConnections[#InputConnections + 1] = RunService.RenderStepped:Connect(function(deltaTime)
			local TimeHeldDown = os.clock() - HoldStart
	
			if Properties.ButtonHeldDown.Value then
				Properties.CurrentBarSize.Value = math.min(Properties.CurrentBarSize.Value + deltaTime / Properties.prompt.HoldDuration, 1)
	
				SoundService:FindFirstChild(HOLD_SOUND).PlaybackSpeed = 0.5 + TimeHeldDown
			else
				Properties.CurrentBarSize.Value = 0
			end
		end)

		InputConnections[#InputConnections + 1] = Properties.prompt.PromptButtonHoldBegan:Connect(function()
			HoldStart = os.clock()
			PlaySound(Scope, HOLD_SOUND, {
				Looped = true,
				Volume = 0.2,
			})
			PlaySound(Scope, CLICK_SOUND)
			Properties.ButtonHeldDown.Value = true
			Properties.CurrentFrameScaleFactor.Value = Properties.InputFrameScaleFactor
		end)

		InputConnections[#InputConnections + 1] = Properties.prompt.PromptButtonHoldEnded:Connect(function()
			StopSound(HOLD_SOUND)
			Properties.ButtonHeldDown.Value = false
			Properties.CurrentFrameScaleFactor.Value = 1
		end)
	end

	InputConnections[#InputConnections + 1] = Properties.prompt.Triggered:Connect(function()
		if Properties.prompt.HoldDuration > 0 then
			PlaySound(Scope, TRIGGER_SOUND)
		else
			PlaySound(Scope, CLICK_SOUND)
			Properties.ButtonHeldDown.Value = true

			task.delay(1 / 60, function()
                Properties.ButtonHeldDown.Value = false
			end)
		end
	end)

    return InputConnections
end