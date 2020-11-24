-- Barrage Effect Script

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

-- knite and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)
local ManageStand = require(Knit.Effects.ManageStand)

-- local variables
local spawnRate = .05
local debrisTime = .15

local module = {}

--// Shoot Arm 
function module.shootArm(thisEffect,thisArm)

	-- clone a single arm and parent it, add it to the Debris
	local newArm = thisEffect[thisArm]:Clone()
	newArm.Parent = thisEffect
	Debris:AddItem(newArm,debrisTime)

	-- destroy the TempWelds
	for i,v in pairs(newArm:GetChildren()) do
		if v.Name == "TempWeld" then
			v:Destroy()
		end
	end


	-- set transparencies
	for i,v in pairs(newArm:GetChildren()) do
		if v.Name == "Root" then
			v.Transparency = 1
			v.Anchored = false
		elseif v.Name == "Part" then
			v.Transparency = .5
			v.Anchored = false
		end
	end

	-- enable trails
	newArm.Root.Trail.Enabled  = true
	
	-- set up random position and set the goals
	local posX = math.random(-1,1)
	local posY = 0.5 * math.random(-3,3)
	newArm.Root.CFrame = newArm.Root.CFrame * CFrame.new(posX,posY,1)
	local armGoal = newArm.Root.CFrame:ToWorldSpace(CFrame.new(0,0,-3.5))

	-- add in the body movers and let it go!
	newArm.Root.BodyPosition.Position = armGoal.Position
	newArm.Root.BodyPosition.D = 300
	newArm.Root.BodyPosition.P = 20000
	newArm.Root.BodyPosition.MaxForce = Vector3.new(2000,2000,2000)
end

--// Run Effect
function module.RunEffect(initPlayer,params)

	-- setup the stand, if its not there then dont run return
	local targetStand = workspace.PlayerStands[initPlayer.UserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		return
	end

	-- create a folder inside the stand to hold the effect
	local barrageFolder = targetStand:FindFirstChild("BarrageFolder")
	if not barrageFolder then
		barrageFolder = utils.EasyInstance("Folder",{Parent = targetStand,Name = "BarrageFolder"})
	end

	-- clone the effect parts in
	local thisEffect = ReplicatedStorage.EffectParts.Barrage[params.PowerID]:Clone()
	thisEffect.Name = "Barrage"
	thisEffect.Parent = barrageFolder
	thisEffect.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,1,-2))
	utils.EasyWeld(thisEffect,initPlayer.Character.HumanoidRootPart,thisEffect)
	
	-- setup the base parts transparencies and manage some trails
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
	
	ManageStand.ToggleTrails(initPlayer,params,"Active")
	wait(.1)
	powerUtils.WeldParticles(targetStand.HumanoidRootPart.CFrame.Position,initPlayer.Character.HumanoidRootPart,targetStand.Particles.EquipStand,.5) -- weld burst particles
	ManageStand.PlayAnimation(initPlayer,params,"Barrage")
	targetStand.WeldConstraint.Enabled = false
	targetStand.HumanoidRootPart.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-2)) -- move
	targetStand.WeldConstraint.Enabled = true
	spawn(function()
		wait(.1)
		ManageStand.ToggleTrails(initPlayer,params,"Idle")
	end)
	
	
	-- setup coroutine and run it while the toggle is on
	local thisToggle = powerUtils.GetToggle(initPlayer,params.InputId) -- we need the toggle to know when to shut off the spawner
	local newThread = coroutine.create(function()
		while wait(spawnRate) do
			if thisToggle.Value then
				module.shootArm(thisEffect,"LeftArm")
				module.shootArm(thisEffect,"RightArm")
			else
				coroutine.yield()
			end
		end
	end)
	
	coroutine.resume(newThread)
end

--// End Effect
function module.EndEffect(initPlayer,params)
	local targetStand = workspace.PlayerStands[initPlayer.UserId]:FindFirstChildWhichIsA("Model")
	local barrageFolder = targetStand:FindFirstChild("BarrageFolder")
	if barrageFolder then
		barrageFolder:Destroy()
	end

	ManageStand.ToggleTrails(initPlayer,params,"Active")
	wait(.1)
	powerUtils.WeldParticles(targetStand.HumanoidRootPart.CFrame.Position,initPlayer.Character.HumanoidRootPart,targetStand.Particles.EquipStand,.5) -- weld burst particles
	ManageStand.StopAnimation(initPlayer,params,"Barrage")
	targetStand.WeldConstraint.Enabled = false
	targetStand.HumanoidRootPart.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(2,1,2.5))
	targetStand.WeldConstraint.Enabled = true

	spawn(function()
		wait(.1)
		ManageStand.ToggleTrails(initPlayer,params,"Idle")
	end)
	
	
end


return module
