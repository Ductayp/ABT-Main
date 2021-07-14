-- CamShakeTools
-- PDab
-- 12-8-2020

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local CameraShaker = require(Knit.Shared.CameraShaker)

--modules
local utils = require(Knit.Shared.Utils)

local CamShakeTools = {}

function CamShakeTools.Client_PresetShake(presetName)

	local character = Players.LocalPlayer.Character
	if not character then return end

	local HRP = character:FindFirstChild("HumanoidRootPart")
	if not HRP then return end

	local camera = Workspace.CurrentCamera
    
	local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCf)
		camera.CFrame = camera.CFrame * shakeCf
	end)

	camShake:Start()
	camShake:Shake(CameraShaker.Presets[presetName])

end

function CamShakeTools.Client_PresetRadiusShake(origin, radius, presetName)

	local character = Players.LocalPlayer.Character
	if not character then return end

	local HRP = character:FindFirstChild("HumanoidRootPart")
	if not HRP then return end

	local distance = (HRP.Position - origin).magnitude
	if distance > radius then return end

	local camera = Workspace.CurrentCamera
    
	local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCf)
		camera.CFrame = camera.CFrame * shakeCf
	end)

	camShake:Start()
	camShake:Shake(CameraShaker.Presets[presetName])

end



return CamShakeTools