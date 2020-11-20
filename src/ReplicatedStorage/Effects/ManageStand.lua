-- Stand Manager

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knits and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)

local ManageStand = {}

--// equips a stand for the target player
function ManageStand.EquipStand(initPlayer,standModel)
	
	-- some setup and definitions
	local initPlayerRoot = initPlayer.Character.HumanoidRootPart
	
	-- define then clear the players stand folder, just in case :)
	local playerStandFolder = workspace.PlayerStands:FindFirstChild(initPlayer.UserId)
	playerStandFolder:ClearAllChildren()

	-- clone the stand
	local newStand = utils.EasyClone(standModel,{Parent = playerStandFolder})

	-- make it all invisible
	for i,v in pairs (newStand:GetDescendants()) do 
		if v:IsA("BasePart") then
			v.Transparency = 1
		end
	end

	-- cframe and weld
	newStand.HumanoidRootPart.CFrame = initPlayerRoot.CFrame:ToWorldSpace(CFrame.new(2,1,2.5))
	utils.EasyWeld(newStand.HumanoidRootPart,initPlayerRoot,newStand)
	
	-- pop some particles
	powerUtils.WeldParticles(newStand.HumanoidRootPart.CFrame.Position,initPlayerRoot,newStand.Particles.EquipStand,1) -- weld burst particles
	powerUtils.WeldParticles(newStand.Head.CFrame.Position,initPlayerRoot,newStand.Particles.EquipStand,1)
	wait(.5)

	-- Tween transparency
	local tweenDuration = .5
	for i,v in pairs(newStand:GetDescendants()) do
		if v:IsA("BasePart") then
			if v.Name == "HumanoidRootPart" then
				--print("nope")
			elseif v.Parent.Name == "NoTween" then
				--print("nope")
			else
				local thisTween = TweenService:Create(v,TweenInfo.new(tweenDuration),{Transparency = 0})
				thisTween:Play()
			end
		end
	end

	-- for parts in the "NoTween" folder, just make them visible once its all done
	local noTweenFolder = newStand.StandParts:FindFirstChild("NoTween")
	if noTweenFolder then
		spawn(function()
			wait(tweenDuration)
			for i,v in pairs (noTweenFolder:GetChildren()) do
				v.Transparency = 0
			end
		end)
	end

	-- run the idles animation
	local animationController = newStand:FindFirstChild("AnimationController")
	if animationController then
		local idleAnimation = animationController:FindFirstChild("Idle")
		if idleAnimation then
			local newTrack = animationController:LoadAnimation(idleAnimation)
			newTrack:Play()
		end
	end

	-- setup trails
	for i,v in pairs (newStand.Trails.Idle:GetChildren()) do 
		v.Enabled = true
	end
end

--// removes the stand for the target player
function ManageStand.RemoveStand(initPlayer,params)
	local playerStandFolder = workspace.PlayerStands:FindFirstChild(initPlayer.UserId)
	local initPlayerRoot = initPlayer.Character.HumanoidRootPart
	local targetStand = playerStandFolder:FindFirstChildWhichIsA("Model")

	-- if theres a stand, get rid of it
	if targetStand then
		targetStand.Trails:Destroy()
		powerUtils.WeldParticles(targetStand.HumanoidRootPart.CFrame.Position,initPlayerRoot,targetStand.Particles.EquipStand,1) -- weld burst particles

		local noTweenFolder = targetStand:FindFirstChild("NoTween")
		if noTweenFolder then
			for i,v in pairs (noTweenFolder:GetChildren()) do 
				v:Destroy()
			end
		end
		
		-- Tween transparency
		local tweenDuration = .5
		for i,v in pairs(targetStand:GetDescendants()) do
			if v:IsA("BasePart") then
				if v.Name == "HumanoidRootPart" then
					--print("nope")
				elseif v.Parent.Name == "NoTween" then
					--print("nope")
				else
					local thisTween = TweenService:Create(v,TweenInfo.new(tweenDuration),{Transparency = 1})
					thisTween:Play()
				end
			end
		end

		-- for parts in the "NoTween" folder, just make them visible once its all done
		local noTweenFolder = targetStand.StandParts:FindFirstChild("NoTween")
		if noTweenFolder then
			for i,v in pairs (noTweenFolder:GetChildren()) do
				v.Transparency = 1
			end
		end

		spawn(function()
			wait(tweenDuration + 1)
			playerStandFolder:ClearAllChildren()
		end)

	end
end



return ManageStand
