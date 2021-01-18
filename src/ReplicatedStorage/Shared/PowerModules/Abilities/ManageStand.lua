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
anchors.Idle = CFrame.new(-2, -1.75, -3)
anchors.Front = CFrame.new(0, 0, 4)
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
	newStand.HumanoidRootPart.CFrame = initPlayerRoot.CFrame --initPlayerRoot.CFrame:ToWorldSpace(CFrame.new(2,1,2.5))

	local newWeld = Instance.new("Weld")
	newWeld.Name = "StandWeld"
	newWeld.C1 =  CFrame.new(0, 0, 0)
	newWeld.Part0 = initPlayerRoot
	newWeld.Part1 = newStand.HumanoidRootPart
	newWeld.Parent = newStand.HumanoidRootPart

	-- do the auras
	ManageStand.Aura_On(initPlayer)
	wait(.5)
	spawn(function()
		wait(5)
		ManageStand.Aura_Off(initPlayer)
	end)

	local spawnTween = TweenService:Create(newWeld,TweenInfo.new(.5),{C1 = anchors.Idle})
	spawnTween:Play()

	-- tween character transparency
	for i, v in pairs (newStand:GetChildren()) do
		if v:IsA("BasePart") then
			if v.Name ~= "HumanoidRootPart" then
				local thisTween = TweenService:Create(v,TweenInfo.new(.5),{Transparency = 0})
				thisTween:Play()
			end
		end
	end

	-- tween stand parts transparency
	for i, v in pairs (newStand.StandParts:GetDescendants()) do
		if v:IsA("BasePart") then
			local thisTween = TweenService:Create(v,TweenInfo.new(.2),{Transparency = 0})
			thisTween:Play()
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

	-- run the idle animation
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

end

--// removes the stand for the target player
function ManageStand.RemoveStand(initPlayer,params)
	local playerStandFolder = workspace.PlayerStands:FindFirstChild(initPlayer.UserId)
	local initPlayerRoot = initPlayer.Character.HumanoidRootPart
	local targetStand = playerStandFolder:FindFirstChildWhichIsA("Model")

	-- do the auras
	ManageStand.Aura_On(initPlayer,params)
	wait(.2)
	spawn(function()
		wait(1)
		ManageStand.Aura_Off(initPlayer,params)
	end)

	-- if theres a stand, get rid of it
	if targetStand then
		
		local noTweenFolder = targetStand:FindFirstChild("NoTween")
		if noTweenFolder then
			for i,v in pairs (noTweenFolder:GetChildren()) do 
				v:Destroy()
			end
		end

		-- weld tween
		local thisWeld = targetStand:FindFirstChild("StandWeld", true)
		local spawnTween = TweenService:Create(thisWeld,TweenInfo.new(.5),{C1 = CFrame.new(0,0,0)})
		spawnTween:Play()
		
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

--// Aura_On
function ManageStand.Aura_On(initPlayer,params)

	local playerStandFolder = workspace.PlayerStands:FindFirstChild(initPlayer.UserId)
	local targetStand = playerStandFolder:FindFirstChildWhichIsA("Model")

	if targetStand then
		for _,emitter in pairs(targetStand.Aura:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end
	end
end

--// Aura_Off
function ManageStand.Aura_Off(initPlayer,params)

	local playerStandFolder = workspace.PlayerStands:FindFirstChild(initPlayer.UserId)
	local targetStand = playerStandFolder:FindFirstChildWhichIsA("Model")

	if targetStand then
		for _,emitter in pairs(targetStand.Aura:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
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
	local standWeld = targetStand:FindFirstChild("StandWeld", true)

	-- if the stand or weld is gone, for example from death, just return
	if not targetStand or not standWeld then
		return
	end

	-- move it
	local spawnTween = TweenService:Create(standWeld,TweenInfo.new(.175),{C1 = anchors[params.AnchorName]})
	spawnTween:Play()

end



return ManageStand
