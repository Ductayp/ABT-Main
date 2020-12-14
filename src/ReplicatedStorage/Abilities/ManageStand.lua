-- Stand Manager

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knits and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)

-- Default Stand Anchor Offsets
local anchors = {}
anchors.Idle = CFrame.new(2,1,2.5)
anchors.Front = CFrame.new(0,0,-2)
anchors.StandJump = CFrame.new(0,1.2,2)

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
	powerUtils.WeldParticles(newStand.HumanoidRootPart.CFrame.Position,initPlayerRoot,newStand.Particles.MoveStand,1) -- weld burst particles
	powerUtils.WeldParticles(newStand.Head.CFrame.Position,initPlayerRoot,newStand.Particles.MoveStand,1)
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
		else
			print("cant find animation")
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
		powerUtils.WeldParticles(targetStand.HumanoidRootPart.CFrame.Position,initPlayerRoot,targetStand.Particles.MoveStand,1) -- weld burst particles

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

-- ToggleTrails = turn all trails off then turns on the ones we want
function ManageStand.ToggleTrails(initPlayer,params,trailName)

	local playerStandFolder = workspace.PlayerStands:FindFirstChild(initPlayer.UserId)
	local targetStand = playerStandFolder:FindFirstChildWhichIsA("Model")

	if targetStand then

		-- disable all trails
		for i,v in pairs(targetStand.Trails:GetDescendants()) do
			if v:IsA("Trail") then
				v.Enabled = false
			end
		end

		-- enable the ones we want
		local trailFolder = targetStand.Trails:FindFirstChild(trailName)
		if trailFolder then
			for i,v in pairs(trailFolder:GetDescendants()) do
				v.Enabled = true
			end
		end
	end
end

-- SetTrails - just turns on the trails we want
function ManageStand.SetTrails(initPlayer,params,trailName)

	local playerStandFolder = workspace.PlayerStands:FindFirstChild(initPlayer.UserId)
	local targetStand = playerStandFolder:FindFirstChildWhichIsA("Model")

	if targetStand then
		-- enable the ones we want
		local trailFolder = targetStand.Trails:FindFirstChild(trailName)
		if trailFolder then
			for i,v in pairs(trailFolder:GetDescendants()) do
				v.Enabled = true
			end
		end
	end
end

-- PlayAnimation
function ManageStand.PlayAnimation(initPlayer,params,animationName)

	local playerStandFolder = workspace.PlayerStands:FindFirstChild(initPlayer.UserId)
	local targetStand = playerStandFolder:FindFirstChildWhichIsA("Model")
	-- run the animation
	local animationController = targetStand:FindFirstChild("AnimationController")
	if animationController then
		local thisAnimation = ReplicatedStorage.Animations:FindFirstChild(animationName)
		if thisAnimation then
			local newTrack = animationController:LoadAnimation(thisAnimation)
			newTrack:Play()
		end
	end
end

-- StopAnimation
-- required params: params.AnimationName
function ManageStand.StopAnimation(initPlayer,params)

	local playerStandFolder = workspace.PlayerStands:FindFirstChild(initPlayer.UserId)
	local targetStand = playerStandFolder:FindFirstChildWhichIsA("Model")

	local animationController = targetStand:FindFirstChild("AnimationController")
	if animationController then
		local tracks = animationController:GetPlayingAnimationTracks()
		for i,v in pairs (tracks) do
			if v.Name == params.AnimationName then
				v:Stop()
			end
		end
	end
end

-- Move Stand
-- required params: params.AnchorName
function ManageStand.MoveStand(initPlayer,params)

	-- some definitions
	local playerStandFolder = workspace.PlayerStands:FindFirstChild(initPlayer.UserId)
	local targetStand = playerStandFolder:FindFirstChildWhichIsA("Model")
	local initPlayerRoot = initPlayer.Character.HumanoidRootPart
	local standWeld = targetStand:FindFirstChild("WeldConstraint")

	-- active effects
	ManageStand.ToggleTrails(initPlayer,params,"Active")
	wait(.1)
	powerUtils.WeldParticles(targetStand.HumanoidRootPart.CFrame.Position,initPlayer.Character.HumanoidRootPart,targetStand.Particles.MoveStand,.5) -- weld burst particles

	-- move it
	standWeld.Enabled = false
	targetStand.HumanoidRootPart.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(anchors[params.AnchorName]) -- move
	standWeld.Enabled = true

	-- idle effects
	spawn(function()
		wait(.1)
		ManageStand.ToggleTrails(initPlayer,params,"Idle")
	end)

end



return ManageStand
