-- Stand Manager

--Roblox Services
local Workspace = game:GetService("Workspace")
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
anchors.IdleHigh = CFrame.new(-2, -5, -3)

local ManageStand = {}

--// --------------------------------------------------------------------
--// Handler Functions
--// --------------------------------------------------------------------

--// Initialize
function ManageStand.Initialize(params, abilityDefs)

	params.RenderRange = 999999 -- force it!

	-- checks
	if params.KeyState == "InputBegan" then params.CanRun = true end
    if params.KeyState == "InputEnded" then params.CanRun = false return end
    if not Cooldown.Client_IsCooled(params) then params.CanRun = false return end
    if not Cooldown.Server_IsCooled(params) then params.CanRun = false return end
    if abilityDefs.RequireToggle_On then
        if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then params.CanRun = false return end
    end

    Cooldown.Client_SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)
end

--// Activate
function ManageStand.Activate(params, abilityDefs)

	--print("ManageStand.Activate(params, abilityDefs)", params, abilityDefs)

	-- checks
	if params.KeyState == "InputBegan" then params.CanRun = true end
	if params.KeyState == "InputEnded" then params.CanRun = false return end
	if not Cooldown.Server_IsCooled(params) then params.CanRun = false return end

	-- definitions
	local playerStandFolder = workspace.PlayerStands:FindFirstChild(params.InitUserId)
	local powerStatusFolder = ReplicatedStorage.PowerStatus[params.InitUserId]
	local equippedStand = powerStatusFolder:FindFirstChild("EquippedStand") -- this is a pointer to the un-cloned model in Replicated

	if params.ForceRemoveStand then
		if AbilityToggle.GetToggleValue(params.InitUserId, params.InputId) == true then
			AbilityToggle.SetToggle(params.InitUserId, params.InputId, false)
			Cooldown.Server_SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)
			if equippedStand then
				equippedStand:Destroy()
			end
			params.CanRun = true
			params.EquipStand = false
			return params
		else
			params.CanRun = false
			return params
		end
	end
    
	-- set the toggles and StandTracker
	if AbilityToggle.GetToggleValue(params.InitUserId, params.InputId) == true then
		AbilityToggle.SetToggle(params.InitUserId, params.InputId, false)
		if equippedStand then
			equippedStand:Destroy()
			params.EquipStand = false
		end
	else
		AbilityToggle.SetToggle(params.InitUserId, params.InputId, true)
		local thisStand = abilityDefs.StandModels[params.PowerRank]
		utils.EasyInstance("ObjectValue",{Name = "EquippedStand",Parent = powerStatusFolder, Value = thisStand}) -- this is a pointer to the un-cloned model in Replicated
		params.EquipStand = true
	end

	-- set cooldown
	Cooldown.Server_SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)

end

--// Execute
function ManageStand.Execute(params, abilityDefs)

	if params.ForceRemoveStand then
		ManageStand.RemoveStand(params, abilityDefs)
		return
	end

	if params.EquipStand then
		ManageStand.EquipStand(params, abilityDefs)
	else
		ManageStand.RemoveStand(params, abilityDefs)
	end

	--[[
	-- check the stands toggle and render effects
	if AbilityToggle.GetToggleValue(params.InitUserId, params.InputId) == true then
		ManageStand.EquipStand(params, abilityDefs)
	else
		ManageStand.RemoveStand(params, abilityDefs)
	end
	]]--
end


--// --------------------------------------------------------------------
--// Ability Functions
--// --------------------------------------------------------------------

--// equips a stand for the target player
function ManageStand.EquipStand(params, abilityDefs)

	--print("EquipStand", params, abilityDefs)

	-- some setup and definitions
	local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
	local initPlayerRoot = initPlayer.Character.HumanoidRootPart
	
	-- define then clear the players stand folder, just in case :)
	local playerStandFolder = workspace.PlayerStands:FindFirstChild(initPlayer.UserId)
	playerStandFolder:ClearAllChildren()

	-- clone the stand
	local thisStand = abilityDefs.StandModels[params.PowerRank]
	local newStand = utils.EasyClone(thisStand, {Parent = playerStandFolder})

	-- make it all invisible
	for i,v in pairs (newStand:GetDescendants()) do 
		if v:IsA("BasePart") then
			v.Transparency = 1
		end
	end

	-- cframe and weld
	newStand.HumanoidRootPart.CFrame = initPlayerRoot.CFrame
	local newWeld = Instance.new("Weld")
	newWeld.Name = "StandWeld"
	newWeld.C1 =  CFrame.new(0, 0, 0)
	newWeld.Part0 = initPlayerRoot
	newWeld.Part1 = newStand.HumanoidRootPart
	newWeld.Parent = newStand.HumanoidRootPart

	--[[
			local newWeld = Instance.new("Weld")
	newWeld.Name = "StandWeld"
	newWeld.C1 =  anchors.Idle
	newWeld.Part0 = initPlayerRoot
	newWeld.Part1 = newStand.HumanoidRootPart
	newWeld.Parent = newStand.HumanoidRootPart
	]]--

	-- do the auras
	spawn(function()
		ManageStand.Aura_On(params)
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
		end
	end

end

--// removes the stand for the target player
function ManageStand.RemoveStand(params, abilityDefs)

	local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
	local playerStandFolder = workspace.PlayerStands:FindFirstChild(initPlayer.UserId)
	local targetStand = playerStandFolder:FindFirstChildWhichIsA("Model")

	if targetStand then

		local initPlayerRoot = initPlayer.Character.HumanoidRootPart

		-- do the auras
		spawn(function()
			ManageStand.Aura_On(params)
			wait(1)
			ManageStand.Aura_Off(params)
		end)
		
		local noTweenFolder = targetStand:FindFirstChild("NoTween")
		if noTweenFolder then
			for i,v in pairs (noTweenFolder:GetChildren()) do 
				v:Destroy()
			end
		end

		-- play the sound
		WeldedSound.NewSound(initPlayerRoot, abilityDefs.Sounds.Remove)

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
		if targetStand.StandParts then
			local noTweenFolder = targetStand.StandParts:FindFirstChild("NoTween")
			if noTweenFolder then
				for i,v in pairs (noTweenFolder:GetChildren()) do
					v.Transparency = 1
				end
			end
		end
		
		spawn(function()
			wait(tweenDuration + 1)
			playerStandFolder:ClearAllChildren()
		end)

	end
end

--// QuickRender this is an emergency render, there are no animatons it just renders the stand as quickly as possible. It also returns the stand
function ManageStand.QuickRender(params)

	-- be sure the player has an equipped stand, if not then just return
	local powerStatusFolder = ReplicatedStorage.PowerStatus[params.InitUserId]
	local equippedStand = powerStatusFolder:FindFirstChild("EquippedStand")
	if not equippedStand then
		return
	end

	-- some setup and definitions
	local initPlayer = utils.GetPlayerByUserId(tonumber(params.InitUserId))
	local initPlayerRoot = initPlayer.Character.HumanoidRootPart

	-- define then clear the players stand folder, just in case :)
	local playerStandFolder = workspace.PlayerStands:FindFirstChild(params.InitUserId)
	playerStandFolder:ClearAllChildren()

	-- clone the stand
	local thisStand = nil
	if params.StandModel then
		thisStand = params.StandModel
	else
		thisStand = ReplicatedStorage.EffectParts.StandModels:FindFirstChild(params.PowerID .. "_" .. params.PowerRank)
	end

	local newStand = utils.EasyClone(thisStand, {Parent = playerStandFolder})
	newStand.Parent = playerStandFolder

	-- cframe and weld
	newStand.HumanoidRootPart.CFrame = initPlayerRoot.CFrame --initPlayerRoot.CFrame:ToWorldSpace(CFrame.new(2,1,2.5))

	local newWeld = Instance.new("Weld")
	newWeld.Name = "StandWeld"
	newWeld.C1 =  CFrame.new(0, 0, 0)
	newWeld.Part0 = initPlayerRoot
	newWeld.Part1 = newStand.HumanoidRootPart
	newWeld.Parent = newStand.HumanoidRootPart

	-- tween the move
	local spawnTween = TweenService:Create(newWeld,TweenInfo.new(.01),{C1 = anchors.Idle})
	spawnTween:Play()

	--ManageStand.MoveStand(params, "Idle")

	-- run the idle animation
	local animationController = newStand:FindFirstChild("AnimationController")
	if animationController then
		local idleAnimation = animationController:FindFirstChild("Idle")
		if idleAnimation then
			local newTrack = animationController:LoadAnimation(idleAnimation)
			newTrack:Play()
		end
	end

	ManageStand.Aura_Off(params)

	return newStand

end

-- PlayAnimation
function ManageStand.PlayAnimation(params, animationName, animationSpeed)

	--print("PLAY", params, animationName, animationSpeed)

	local playerStandFolder = Workspace.PlayerStands:FindFirstChild(params.InitUserId)
	local targetStand = playerStandFolder:FindFirstChildWhichIsA("Model")
	if not targetStand then return end


	
	-- run the animation
	local animationLength
	local animationController = targetStand:FindFirstChild("AnimationController")
	if animationController then

		local thisAnimation = ReplicatedStorage.StandAnimations:FindFirstChild(animationName)
		if thisAnimation then
			local newTrack = animationController:LoadAnimation(thisAnimation)

			newTrack:Play()
			--print("newTrack",newTrack)
			if animationSpeed then
				newTrack:AdjustSpeed(animationSpeed)
				--print("newTrack.Speed",newTrack.Speed)
			end
			animationTime = newTrack.Length
		end
	end

	return animationLength
end

-- StopAnimation
function ManageStand.StopAnimation(params, animationName)

	local playerStandFolder = workspace.PlayerStands:FindFirstChild(params.InitUserId)
	if not playerStandFolder then return end
	
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
	if not playerStandFolder then
		return
	end

	local targetStand = playerStandFolder:FindFirstChildWhichIsA("Model")
	if not targetStand then
		return
	end

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

	local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
	if not initPlayer then return end
	local initPlayerRoot = initPlayer.Character.HumanoidRootPart

	local playerStandFolder = workspace.PlayerStands:FindFirstChild(params.InitUserId)
	local targetStand = playerStandFolder:FindFirstChildWhichIsA("Model")
	if not targetStand then return end


	local moveTime = .175
	if params.MoveTime ~= nil then
		moveTime = params.MoveTime
	end
	
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
