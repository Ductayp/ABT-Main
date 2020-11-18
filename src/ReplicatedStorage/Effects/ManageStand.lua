-- Stand Manager

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

-- Knits and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)

local ManageStand = {}

--// equips a stand for the target player
function ManageStand.EquipStand(initPlayer,standDefs)
	
	-- some setup and definitions
	local initPlayerRoot = initPlayer.Character.HumanoidRootPart
	
	-- define then clear the players stand folder, just in case :)
	local playerStandFolder = workspace.PlayerStands:FindFirstChild(initPlayer.UserId)
	playerStandFolder:ClearAllChildren()

	-- clone the stand and set it up
	local newStand = utils.EasyClone(standDefs.StandModel,{Parent = playerStandFolder})
	powerUtils.TweenCharacterParts(newStand,(0),{Transparency = 1})
	newStand.HumanoidRootPart.CFrame = initPlayerRoot.CFrame:ToWorldSpace(CFrame.new(2,1,2.5))
	utils.EasyWeld(newStand.HumanoidRootPart,initPlayerRoot,newStand)
	
	-- render the stand in with some tweens and particles
	powerUtils.WeldParticles(newStand.HumanoidRootPart.CFrame.Position,initPlayerRoot,effectParticles.GoldBurst,1) -- weld burst particles
	powerUtils.WeldParticles(newStand.Head.CFrame.Position,initPlayerRoot,effectParticles.GoldBurst,1)
	wait(.5)
	powerUtils.TweenCharacterParts(newStand,(.5),{Transparency = 0})

	-- setup animations
	powerUtils.LoadAnimations(newStand)
	powerUtils.PlayAnimation(newStand,"Idle")

	-- setup trails
	powerUtils.TrailSettings(initPlayer,powerDefs.Effects.StandTrails.Default)
	
end

--// removes the stand for the target player
function ManageStand.RemoveStand(initPlayer,params)
	local playerStandFolder = workspace.LocalEffects.PlayerStands[initPlayer.UserId]
	local initPlayerRoot = initPlayer.Character.HumanoidRootPart
	local targetStand = playerStandFolder:FindFirstChildWhichIsA("Model")
	if targetStand then
		targetStand.Trails:Destroy()
		powerUtils.WeldParticles(targetStand.HumanoidRootPart.CFrame.Position,initPlayerRoot,effectParticles.GoldBurst,2) -- weld burst particles
		powerUtils.SelectiveDebris({"Eye"},targetStand.StandParts:GetChildren())
		powerUtils:TweenCharacterParts(targetStand.StandParts,(1),{Transparency = 1,CFrame = initPlayerRoot.CFrame})
		powerUtils:TweenCharacterParts(targetStand,(1),{Transparency = 1,CFrame = initPlayerRoot.CFrame})
		Debris:AddItem(targetStand, 3)
	end
	
end



return ManageStand
