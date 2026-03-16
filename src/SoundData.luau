-- NOTE: This module will be improved when the input connections are recoded

-- Imports
local Packages = script.Parent:FindFirstChild("Packages")
local Seam = if Packages then require(Packages.Seam) else require(script.Parent.Seam)

-- Variables
local Scope = Seam.Scope(Seam)

return {
   AppearSoundId = Scope:Value("rbxassetid://10066931761"),
   ClickSoundId = Scope:Value("rbxassetid://10128760939"),
   HoldSoundId = Scope:Value("rbxassetid://421058925"),
   TriggerSoundId = Scope:Value("rbxassetid://10128766965"),
   SoundVolume = Scope:Value(0.35),
}