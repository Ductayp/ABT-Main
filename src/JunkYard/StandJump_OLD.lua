-- Bullet Kick Ability
-- PDab
-- 12-1-2020

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local AbilityToggle = require(Knit.PowerUtils.AbilityToggle)
local ManageStand = require(Knit.Abilities.ManageStand)
local Cooldown = require(Knit.PowerUtils.Cooldown)

-- default values
local defaultVelocityX = 7000 
local defaultVelocityZ = 7000 
local defaultVelocityY = 1800 
local defaultDuration = 0.3
local forceDelay = .2

local StandJump = {}


--// --------------------------------------------------------------------
--// Handler Functions
--// --------------------------------------------------------------------

--// Initialize
function StandJump.Initialize(params, abilityDefs)

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
    
    -- tween effects
    spawn(function()
        StandJump.Run_Effects(params, abilityDefs)
    end)
	
end

--// Activate
function StandJump.Activate(params, abilityDefs)

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
    

    if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
        params.CanRun = false
        return params
    end

     -- require toggles to be inactive, excluding "Q"
     if not AbilityToggle.RequireOff(params.InitUserId, abilityDefs.RequireToggle_Off) then
        params.CanRun = false
        return params
    end

	-- set cooldown
    Cooldown.SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)

    -- set toggle
    AbilityToggle.QuickToggle(params.InitUserId, params.InputId, true)

    -- tween hitbox
    spawn(function()
        StandJump.Run_Server(params, abilityDefs)
    end)
    
end

--// Execute
function StandJump.Execute(params, abilityDefs)

	if Players.LocalPlayer.UserId == params.InitUserId then
		print("Players.LocalPlayer == initPlayer: DO NOT RENDER")
		return
	end

    -- tween effects
	StandJump.Run_Effects(params, abilityDefs)

end


--// --------------------------------------------------------------------
--// Ability Functions
--// --------------------------------------------------------------------

function StandJump.Run_Server(params, abilityDefs)

    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

    -- be sure the player cant use this ability if they are in freefall
    if initPlayer.Character.Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
        params.CanRun = false
        return params
    else
        params.CanRun = true
    end

    -- declare here for use everywhere
    local velocityX
    local velocityZ
    local velocityY
    local duration

    -- grab the LookVector before we do anything else
    local lookVector = initPlayer.Character.HumanoidRootPart.CFrame.LookVector
    velocityX = lookVector.X * defaultVelocityX 
    velocityZ = lookVector.Z * defaultVelocityZ 
    velocityY = defaultVelocityY 
    duration = defaultDuration

    spawn(function()

        spawn(function()
            initPlayer.Character.Humanoid.WalkSpeed = 0
            wait(1)
            local totalWalkSpeed = require(Knit.StateModules.WalkSpeed).GetModifiedValue(initPlayer)
            initPlayer.Character.Humanoid.WalkSpeed = totalWalkSpeed
        end)

        wait(forceDelay) -- a short delay to make time for animations
        
        initPlayer.Character.Humanoid.Jump = true
       
        local positiveBodyForce = Instance.new("BodyForce")
        positiveBodyForce.Force =  Vector3.new(velocityX,velocityY,velocityZ)
        positiveBodyForce.Parent = initPlayer.Character.HumanoidRootPart
        Debris:AddItem(positiveBodyForce,duration)

        wait(.3)
        local negativeBodyForce = Instance.new("BodyForce")
        negativeBodyForce.Force =  Vector3.new(-velocityX,0,-velocityZ)
        negativeBodyForce.Parent = initPlayer.Character.HumanoidRootPart
        Debris:AddItem(negativeBodyForce,(duration - 0.3))

    end)
end

function StandJump.Run_Effects(params, abilityDefs)

    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

    -- setup the stand, if its not there then dont run return
	local targetStand = workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		targetStand = ManageStand.QuickRender(params)
    end

    wait(animationDelay) -- a small delay to wait for animations

    -- apply depth of field effect for the initPlayer
    if initPlayer == Players.LocalPlayer then

        -- depth of field effect
        local newDepthOfField = ReplicatedStorage.EffectParts.Effects.DepthOfField.Default:Clone()
        newDepthOfField.Name = "newDepthOfField"
        newDepthOfField.Parent = game:GetService("Lighting")
        Debris:AddItem(newDepthOfField,1)
    end

    --move the stand and do animations
    spawn(function()

        Knit.Services.PlayerUtilityService.PlayerAnimations[initPlayer.UserId].Punch_2:Play()

        -- player jump animation
        --local anim = initPlayer.Character.Humanoid:LoadAnimation(ReplicatedStorage.Animations.PlayerJump)
        --anim:Play()

        ManageStand.PlayAnimation(params, "StandJump")
        ManageStand.MoveStand(params, "StandJump")

        wait(.7)

        ManageStand.StopAnimation(params, "StandJump")
        ManageStand.MoveStand(params, "Idle")
        --anim:Stop()
        Knit.Services.PlayerUtilityService.PlayerAnimations[initPlayer.UserId].Punch_2:Stop()

    end)

    -- pop the part effects
    local groundShock = ReplicatedStorage.EffectParts.Abilities.StandJump.GroundShock:Clone()
    groundShock.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,-2.5,0))
    groundShock.Parent = workspace.RenderedEffects

    local sizeTween = TweenService:Create(groundShock,TweenInfo.new(1.5),{Size = (groundShock.Size + Vector3.new(1,2,1))})
    local fadeTween = TweenService:Create(groundShock,TweenInfo.new(2),{Transparency = 1})

    fadeTween.Completed:Connect(function(playbackState)
        if playbackState == Enum.PlaybackState.Completed then
            groundShock:Destroy()
        end
    end)

    sizeTween:Play()
    fadeTween:Play()


    -- add some trails
    local locations = {"Head","UpperTorso","LeftLowerLeg","RightLowerLeg","LeftHand","RightHand"}
    for count = 1, 6 do
        local newTrail = ReplicatedStorage.EffectParts.Abilities.StandJump.StandJumpTrail:Clone()
        local thisLocation = locations[count]
        newTrail.CFrame = initPlayer.Character[thisLocation].CFrame
        newTrail.Parent = initPlayer.Character[thisLocation]
        utils.EasyWeld(newTrail,initPlayer.Character[thisLocation],newTrail)
        spawn(function()
            wait(.1)
            newTrail.Trail.MaxLength = 0
            wait(1)
            newTrail:Destroy()
        end)
    end

end

return StandJump

