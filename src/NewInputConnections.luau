-- Types
type Properties = {
    prompt: ProximityPrompt,
    ButtonHeldDown: any,
    CurrentBarSize: any,
    CurrentFrameScaleFactor: any,
    PromptTransparency: any,
    InputFrameScaleFactor: any,
}

-- Services
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

-- Imports
local SoundData = require(script.Parent.SoundData)

local function PlaySound(Scope : any, SoundId : string, Properties : {[string]: any}?)
	local Sound = SoundService:FindFirstChild(SoundId.Value)

	if not Sound then
		Sound = Scope:New(Scope:New("Sound", {
			Name = SoundId,
			SoundId = SoundId,
			Volume = SoundData.SoundVolume,
			Parent = SoundService,
		}), Properties or {})
	end

	Sound:Play()
end

local function StopSound(SoundId)
	local Sound = SoundService:FindFirstChild(SoundId.Value)

	if Sound then
		Sound:Stop()
	end
end

return function(Scope : any, Properties : Properties) : {RBXScriptConnection}
    local InputConnections = {}
	local HoldStart = os.clock()

	PlaySound(Scope, SoundData.AppearSoundId)

	if Properties.prompt.HoldDuration > 0 then
		InputConnections[#InputConnections + 1] = RunService.RenderStepped:Connect(function(deltaTime)
			local TimeHeldDown = os.clock() - HoldStart
	
			if Properties.ButtonHeldDown.Value then
				Properties.CurrentBarSize.Value = math.min(Properties.CurrentBarSize.Value + deltaTime / Properties.prompt.HoldDuration, 1)
	
				SoundService:FindFirstChild(SoundData.HoldSoundId.Value).PlaybackSpeed = 0.5 + TimeHeldDown
			else
				Properties.CurrentBarSize.Value = 0
			end
		end)

		InputConnections[#InputConnections + 1] = Properties.prompt.PromptButtonHoldBegan:Connect(function()
			HoldStart = os.clock()
			PlaySound(Scope, SoundData.HoldSoundId, {
				Looped = true,
				Volume = 0.2,
			})
			PlaySound(Scope, SoundData.ClickSoundId)
			Properties.ButtonHeldDown.Value = true
			Properties.CurrentFrameScaleFactor.Value = Properties.InputFrameScaleFactor
		end)

		InputConnections[#InputConnections + 1] = Properties.prompt.PromptButtonHoldEnded:Connect(function()
			StopSound(SoundData.HoldSoundId)
			Properties.ButtonHeldDown.Value = false
			Properties.CurrentFrameScaleFactor.Value = 1
		end)
	end

	InputConnections[#InputConnections + 1] = Properties.prompt.Triggered:Connect(function()
		if Properties.prompt.HoldDuration > 0 then
			PlaySound(Scope, SoundData.TriggerSoundId)
		else
			PlaySound(Scope, SoundData.ClickSoundId)
			Properties.ButtonHeldDown.Value = true

			task.delay(1 / 60, function()
                Properties.ButtonHeldDown.Value = false
			end)
		end
	end)

	InputConnections[#InputConnections + 1] = Properties.prompt.AncestryChanged:Connect(function(_, Parent)
		if not Parent and Properties.ButtonHeldDown.Value then
			StopSound(SoundData.HoldSoundId)
		end
	end)

    return InputConnections
end