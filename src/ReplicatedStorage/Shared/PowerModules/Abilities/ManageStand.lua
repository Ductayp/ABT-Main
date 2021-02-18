-- Stand Manager

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knits and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local AbilityToggle = require(Knit.PowerUtils.AbilityToggle)
local Cooldown = require(Knit.PowerUtils.Cooldown)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)

-- Default Stand Anchor Offsets
local anchors = {}
anchors.Idle = CFrame.new(-2, -1.75, -3)
anchors.Front = CFrame.new(0, 0, 4)
anchors.StandJump = CFrame.new(0, -1.25, -3)

local ManageStand = {}

--// --------------------------------------------------------------------
--// Handler Functions
--// --------------------------------------------------------------------

--// Initialize
function ManageStand.Initialize(params, abilityDefs)

	-- check KeyState
	if params.KeyState == "InputBegan" then
		params.CanRun = true
	else
		params.CanRun = false
		return
	end

	-- check cooldown
	if not Cooldown.Client_IsCooled(params) then
		params.CanRun = false
		print("not cooled down")
		return
	end

	-- check the stands toggle and render effects
	if AbilityToggle.GetToggleValue(params.InitUserId, "StandEquipped") == true then
		spawn(function()
			ManageStand.RemoveStand(params, abilityDefs)
		end)
	else
		spawn(function()
			ManageStand.EquipStand(params, abilityDefs)
		end)
	end

end

--// Activate
function ManageStand.Activate(params, abilityDefs)

	--print("ManageStand.Activate(params, abilityDefs)", params, abilityDefs)

	-- definitions
	local playerStandFolder = workspace.PlayerStands:FindFirstChild(params.InitUserId)
	local powerStatusFolder = ReplicatedStorage.PowerStatus[params.InitUserId]
	local equippedStand = powerStatusFolder:FindFirstChild("EquippedStand") -- this is a pointer to the un-cloned model in Replicated

	if params.ForceRemoveStand then
		AbilityToggle.SetToggle(params.InitUserId, "StandEquipped", false)
		--if equippedStand then
			--equippedStand:Destroy()
		--end
		params.CanRun = true
		return
	end

	-- check KeyState
	if params.KeyState == "InputBegan" then
		params.CanRun = true
	else
		params.CanRun = false
		return
	end

	-- check cooldown
	if not Cooldown.Client_IsCooled(params) then
		params.CanRun = false
		return
	end

	-- set the toggles and StandTracker
	if AbilityToggle.GetToggleValue(params.InitUserId, "StandEquipped") == true then
		AbilityToggle.SetToggle(params.InitUserId, "StandEquipped", false)
		if equippedStand then
			equippedStand:Destroy()
		end
	else
		AbilityToggle.SetToggle(params.InitUserId, "StandEquipped", true)
		local thisStand = abilityDefs.StandModels[params.PowerRarity]
		utils.EasyInstance("ObjectValue",{Name = "EquippedStand",Parent = powerStatusFolder, Value = thisStand}) -- this is a pointer to the un-cloned model in Replicated
	end

	-- set cooldown
	Cooldown.SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)

end

--// Execute
function ManageStand.Execute(params, abilityDefs)

	if params.ForceRemoveStand then
		spawn(function()
			ManageStand.RemoveStand(params, abilityDefs)
		end)
		return
	end

	if Players.LocalPlayer.UserId == params.InitUserId then
		--print("Players.LocalPlayer == initPlayer: DO NOT RENDER")
		return
	end

	-- check the stands toggle and render effects
	if AbilityToggle.GetToggleValue(params.InitUserId, "StandEquipped") == true then
		spawn(function()
			ManageStand.EquipStand(params, abilityDefs)
		end)
	else
		spawn(function()
			ManageStand.RemoveStand(params, abilityDefs)
		end)
	end

end


--// --------------------------------------------------------------------
--// Ability Functions
--// --------------------------------------------------------------------

--// equips a stand for the target player
function ManageStand.EquipStand(params, abilityDefs)

	-- some setup and definitions
	local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
	local initPlayerRoot = initPlayer.Character.HumanoidRootPart
	
	-- define then clear the players stand folder, just in case :)
	local playerStandFolder = workspace.PlayerStands:FindFirstChild(initPlayer.UserId)
	playerStandFolder:ClearAllChildren()

	-- clone the stand
	local thisStand = abilityDefs.StandModels[params.PowerRarity]
	local newStand = utils.EasyClone(thisStand, {Parent = playerStandFolder})

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
	ManageStand.Aura_On(params)
	wait(.5)
	spawn(function()
		wait(5)
		ManageStand.Aura_Off(params)
	end)

	-- tween the move
	local spawnTween = TweenService:Create(newWeld,TweenInfo.new(.5),{C1 = anchors.Idle})
	spawnTween:Play()

	-- play the sound
	WeldedSound.NewSound(initPlayer.Character.HumanoidRootPart, abilityDefs.Sounds.Equip)

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
function ManageStand.RemoveStand(params, abilityDefs)

	--print("ManageStand.RemoveStand(params, abilityDefs)", params, abilityDefs)

	local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
	local playerStandFolder = workspace.PlayerStands:FindFirstChild(initPlayer.UserId)
	local initPlayerRoot = initPlayer.Character.HumanoidRootPart
	local targetStand = playerStandFolder:FindFirstChildWhichIsA("Model")
	if not targetStand then
		return
	end

	-- do the auras
	ManageStand.Aura_On(params)
	wait(.2)
	spawn(function()
		wait(1)
		ManageStand.Aura_Off(params)
	end)

	-- if theres a stand, get rid of it
	if targetStand then
		
		local noTweenFolder = targetStand:FindFirstChild("NoTween")
		if noTweenFolder then
			for i,v in pairs (noTweenFolder:GetChildren()) do 
				v:Destroy()
			end
		end

		-- play the sound
		WeldedSound.NewSound(initPlayer.Character.HumanoidRootPart, abilityDefs.Sounds.Remove)

		-- weld tween
		local thisWeld = targetStand:FindFirstChild("StandWeld", true)
		if thisWeld then
			local spawnTween = TweenService:Create(thisWeld,TweenInfo.new(.5),{C1 = CFrame.new(0,0,0)})
			spawnTween:Play()
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

--// QuickRender this is an emergency render, there are no animatons it just renders the stand as quickly as possible. I also returns the stand
function ManageStand.QuickRender(params)

	-- be sure the player has an equipped stand, if not then just return
	local powerStatusFolder = ReplicatedStorage.PowerStatus[params.InitUserId]
	local equippedStand = powerStatusFolder:FindFirstChild("EquippedStand")
	if not equippedStand then
		return
	end

	-- some setup and definitions
	local initPlayer = utils.GetPlayerByUserId(tonumber(params.InitUserId))
	print("initPlayer", initPlayer)
	local initPlayerRoot = initPlayer.Character.HumanoidRootPart

	-- define then clear the players stand folder, just in case :)
	local playerStandFolder = workspace.PlayerStands:FindFirstChild(params.InitUserId)
	playerStandFolder:ClearAllChildren()

	-- clone the stand
	local thisStand = nil
	if params.StandModel then
		thisStand = params.StandModel
	else
		thisStand = ReplicatedStorage.EffectParts.StandModels:FindFirstChild(params.PowerID .. "_" .. params.PowerRarity)
	end

	print("thisStand", thisStand)

	local newStand = utils.EasyClone(thisStand, {Parent = playerStandFolder})
	newStand.Parent = playerStandFolder

	-- cframe and weld
	newStand.HumanoidRootPart.CFrame = initPlayerRoot.CFrame --initPlayerRoot.CFrame:ToWorldSpace(CFrame.new(2,1,2.5))

	local newWeld = Instance.new("Weld")
	newWeld.Name = "StandWeld"
	newWeld.C1 =  anchors.Idle
	newWeld.Part0 = initPlayerRoot
	newWeld.Part1 = newStand.HumanoidRootPart
	newWeld.Parent = newStand.HumanoidRootPart

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

	ManageStand.Aura_Off(params)

	return newStand

end

-- PlayAnimation
function ManageStand.PlayAnimation(params, animationName)

	local animationTime

	local playerStandFolder = workspace.PlayerStands:FindFirstChild(params.InitUserId)
	local targetStand = playerStandFolder:FindFirstChildWhichIsA("Model")
	
	-- run the animation
	local animationController = targetStand:FindFirstChild("AnimationController")
	if animationController then
		local thisAnimation = ReplicatedStorage.StandAnimations:FindFirstChild(animationName)
		if thisAnimation then
			local newTrack = animationController:LoadAnimation(thisAnimation)
			newTrack:Play()
			animationTime = newTrack.Length
		end
		thisAnimation = nil
	end

	return animationTime
end

-- StopAnimation
function ManageStand.StopAnimation(params, animationName)

	local playerStandFolder = workspace.PlayerStands:FindFirstChild(params.InitUserId)
	local targetStand = playerStandFolder:FindFirstChildWhichIsA("Model")
	if not targetStand then
		return
	end

	local animationController = targetStand:FindFirstChild("AnimationController")
	if animationController then
		local tracks = animationController:GetPlayingAnimationTracks()
		for i,v in pairs (tracks) do
			if v.Name == animationName then
				v:Stop()
			end
		end
	end
end

--// Aura_On
function ManageStand.Aura_On(params, duration)

	local playerStandFolder = workspace.PlayerStands:FindFirstChild(params.InitUserId)
	local targetStand = playerStandFolder:FindFirstChildWhichIsA("Model")

	if targetStand then
		for _,emitter in pairs(targetStand.Aura:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
				if duration then
					spawn(function()
						wait(duration)
						emitter.Enabled = false
					end)
				end
			end
		end
	end
end

--// Aura_Off
function ManageStand.Aura_Off(params)

	local playerStandFolder = workspace.PlayerStands:FindFirstChild(params.InitUserId)
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
function ManageStand.MoveStand(params, anchorName)

	local moveTime = .175
	if params.MoveTime ~= nil then
		moveTime = params.MoveTime
	end

	-- some definitions
	local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
	local playerStandFolder = workspace.PlayerStands:FindFirstChild(params.InitUserId)
	local targetStand = playerStandFolder:FindFirstChildWhichIsA("Model")
	local initPlayerRoot = initPlayer.Character.HumanoidRootPart
	local standWeld = targetStand:FindFirstChild("StandWeld", true)

	-- if the stand or weld is gone, for example from death, just return
	if not targetStand or not standWeld then
		return
	end

	-- move it
	local spawnTween = TweenService:Create(standWeld,TweenInfo.new(moveTime),{C1 = anchors[anchorName]})
	spawnTween:Play()

	return moveTime

end



return ManageStand
