-- ShakeTools
-- PDab
-- 12-8-2020

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

--modules
local utils = require(Knit.Shared.Utils)

local ShakeTools = {}

function ShakeTools.RadiusShake(origin, presetName)

	local camera = Workspace.CurrentCamera
    
	local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCf)
		camera.CFrame = camera.CFrame * shakeCf
	end)

	camShake:Start()

	-- shake settings:
	camShake:Shake(CameraShaker.Presets.Damage)
	--camShake:ShakeOnce(3, 1, 0.2, 1.5)
end



return ShakeTools