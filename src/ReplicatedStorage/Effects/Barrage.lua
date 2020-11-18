-- Barrage Effect Script

local replicatedStorage = game:GetService("ReplicatedStorage")
local debris = game:GetService("Debris")
local utils = require(replicatedStorage.SRC.Modules.Utilities)
local powerUtils = require(replicatedStorage.SRC.Modules.PowersShared.PowerUtils)
local effectParticles = replicatedStorage.Effects.Powers.EffectParticles
local powerDefs = replicatedStorage.SRC.Definitions.PowerDefs

local spawnRate = .05
local debrisTime = .15


local module = {}

--// Shoot Arm 
function module.shootArm(thisEffect,thisArm)
	local newArm = thisEffect[thisArm]:Clone()
	local player = game:GetService("Players").LocalPlayer
	for i,v in pairs(newArm:GetChildren()) do
		if v.Name == "TempWeld" then
			v:Destroy()
		end
	end
	newArm.Parent = thisEffect
	for i,v in pairs(newArm:GetChildren()) do
		if v.Name == "Root" then
			v.Transparency = 1
			v.Anchored = false
		elseif v.Name == "Part" then
			v.Transparency = .5
			v.Anchored = false
		end
	end
	newArm.Root.Trail.Enabled  = true
	debris:AddItem(newArm,debrisTime)
	
	local posX = math.random(-1,1)
	local posY = 0.5 * math.random(-3,3)
	newArm.Root.CFrame = newArm.Root.CFrame:ToWorldSpace(CFrame.new(posX,posY,1))
	local armGoal = newArm.Root.CFrame:ToWorldSpace(CFrame.new(0,0,-3.5))

	newArm.Root.BodyPosition.Position = armGoal.Position
	newArm.Root.BodyPosition.D = 300
	newArm.Root.BodyPosition.P = 20000
	newArm.Root.BodyPosition.MaxForce = Vector3.new(2000,2000,2000)
end

--// Run Effect
function module.RunEffect(targetPlayer,dictionary)
	local thisEffect = replicatedStorage.Effects.Powers.Barrage[dictionary.PowerID]:Clone()
	local thisPowerDef = require(powerDefs[dictionary.PowerID])
	local playerRoot = targetPlayer.Character.HumanoidRootPart
	local targetStand = workspace.LocalEffects.PlayerStands[targetPlayer.UserId]:FindFirstChildWhichIsA("Model")
	
	-- clone the effect parts in
	local targetFolder = workspace.LocalEffects:FindFirstChild(targetPlayer.UserId)
	if not targetFolder then
		targetFolder = utils.EasyInstance("Folder",{Parent = workspace.LocalEffects,Name = targetPlayer.UserId})
	end
	thisEffect.Name = "Barrage"
	thisEffect.Parent = targetFolder
	thisEffect.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,1,-4))
	utils.EasyWeld(thisEffect,targetPlayer.Character.HumanoidRootPart,thisEffect)
	
	-- setup the base parts trasnparencies
	thisEffect.Transparency = 1
	for i,v in pairs(thisEffect:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Transparency = 1
			v.Anchored = false
			if v.Name == "Root" then
				v.Trail.Enabled  = false 
			end
		end
	end
	
	powerUtils.TrailSettings(targetPlayer,thisPowerDef.Effects.StandTrails.Active)
	powerUtils.WeldParticles(targetStand.HumanoidRootPart.CFrame.Position,playerRoot,effectParticles.GoldBurst,.4)
	powerUtils.PlayAnimation(targetStand,"Barrage")
	targetStand.WeldConstraint.Enabled = false
	targetStand.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-4)) -- move
	targetStand.WeldConstraint.Enabled = true
	wait(.1)
	powerUtils.TrailSettings(targetPlayer,thisPowerDef.Effects.StandTrails.Default)
	
	-- setup coroutine and run it while the toggle is on
	local newThread = coroutine.create(function()
		while wait(spawnRate) do
			local abilityToggle = replicatedStorage.PowerStatus.AbilityToggle[targetPlayer.UserId][dictionary.AbilityID].Value
			if abilityToggle then
				module.shootArm(thisEffect,"LeftArm")
				module.shootArm(thisEffect,"RightArm")
			else
				thisEffect:Destroy()
				coroutine.yield()
			end
		end
	end)
	
	coroutine.resume(newThread)
end

--// End Effect
function module.EndEffect(targetPlayer,dictionary)
	local thisPowerDef = require(powerDefs[dictionary.PowerID])
	local targetStand = workspace.LocalEffects.PlayerStands[targetPlayer.UserId]:FindFirstChildWhichIsA("Model")
	local playerRoot = targetPlayer.Character.HumanoidRootPart
	
	powerUtils.TrailSettings(targetPlayer,thisPowerDef.Effects.StandTrails.Active)
	powerUtils.WeldParticles(targetStand.HumanoidRootPart.CFrame.Position,playerRoot,effectParticles.GoldBurst,.4)
	powerUtils.StopAnimation(targetStand,"Barrage")
	local barrageEffect = targetStand:FindFirstChild("BarrageEffect")
	targetStand.WeldConstraint.Enabled = false
	targetStand.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(2,1,2.5))
	targetStand.WeldConstraint.Enabled = true
	wait(.1)
	powerUtils.TrailSettings(targetPlayer,thisPowerDef.Effects.StandTrails.Default)
end


return module
