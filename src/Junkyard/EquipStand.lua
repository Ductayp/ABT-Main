-- Equip Stand Script

local replicatedStorage = game:GetService("ReplicatedStorage")
local debris = game:GetService("Debris")
local utils = require(replicatedStorage.SRC.Modules.Utilities)
local powerUtils = require(replicatedStorage.SRC.Modules.PowersShared.PowerUtils)

local effectParticles = replicatedStorage.Effects.Powers.EffectParticles

local module = {}

--// equips a stand for the target player
function module.EquipStand(targetPlayer,dictionary)
	
	local playerStandFolder = workspace.LocalEffects.PlayerStands:FindFirstChild(targetPlayer.UserId)
	if not playerStandFolder then
		playerStandFolder = utils.EasyInstance("Folder",{Name = targetPlayer.UserId,Parent = workspace.LocalEffects.PlayerStands})
	end
	local playerRoot = targetPlayer.Character.HumanoidRootPart
	local powerDefs = require(replicatedStorage.SRC.Definitions.PowerDefs:FindFirstChild(dictionary.PowerID))
	--local standModel = replicatedStorage.StandModels:WaitForChild(dictionary.PowerID)
	
	playerStandFolder:ClearAllChildren()
	local newStand = utils.EasyClone(powerDefs.StandModel,{Parent = playerStandFolder})
	powerUtils:TweenCharacterParts(newStand,(0),{Transparency = 1})
	
	newStand.HumanoidRootPart.CFrame = playerRoot.CFrame:ToWorldSpace(CFrame.new(2,1,2.5))
	utils.EasyWeld(newStand.HumanoidRootPart,playerRoot,newStand)
	
	powerUtils.WeldParticles(newStand.HumanoidRootPart.CFrame.Position,playerRoot,effectParticles.GoldBurst,1) -- weld burst particles
	powerUtils.WeldParticles(newStand.Head.CFrame.Position,playerRoot,effectParticles.GoldBurst,1)

	wait(.5)
	powerUtils:TweenCharacterParts(newStand,(.5),{Transparency = 0})
	powerUtils.LoadAnimations(newStand)
	powerUtils.PlayAnimation(newStand,"Idle")
	powerUtils.TrailSettings(targetPlayer,powerDefs.Effects.StandTrails.Default)
	
end

--// removes the stand for the target player
function module.RemoveStand(targetPlayer,dictionary)
	local playerStandFolder = workspace.LocalEffects.PlayerStands[targetPlayer.UserId]
	local playerRoot = targetPlayer.Character.HumanoidRootPart
	local targetStand = playerStandFolder:FindFirstChildWhichIsA("Model")
	if targetStand then
		targetStand.Trails:Destroy()
		powerUtils.WeldParticles(targetStand.HumanoidRootPart.CFrame.Position,playerRoot,effectParticles.GoldBurst,2) -- weld burst particles
		powerUtils.SelectiveDebris({"Eye"},targetStand.StandParts:GetChildren())
		powerUtils:TweenCharacterParts(targetStand.StandParts,(1),{Transparency = 1,CFrame = playerRoot.CFrame})
		powerUtils:TweenCharacterParts(targetStand,(1),{Transparency = 1,CFrame = playerRoot.CFrame})
		debris:AddItem(targetStand, 3)
	end
	
end

--// renders all stands active for the target player
function module.EquipAllStands()
	
end


return module
