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
local powerUtils = require(Knit.Shared.PowerUtils)
local ManageStand = require(Knit.Abilities.ManageStand)

-- default values
local defaultVelocityX = 7000 
local defaultVelocityZ = 7000 
local defaultVelocityY = 1800 
local defaultDuration = 0.3
local forceDelay = .2
local animationDelay = 0


local StandJump = {}

function StandJump.Activate(initPlayer,params)

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
    velocityX = lookVector.X * defaultVelocityX --params.StandJump.Velocity_XZ
    velocityZ = lookVector.Z * defaultVelocityZ --params.StandJump.Velocity_XZ
    velocityY = defaultVelocityY --params.StandJump.Velocity_Y
    duration = defaultDuration

    --[[
    -- body mover settings, set if params exist, otherwise use defaults
    if params.StandJump.Velocity_XZ then
        velocityX = lookVector.X * params.StandJump.Velocity_XZ
        velocityZ = lookVector.Z * params.StandJump.Velocity_XZ
    else
        velocityX = lookVector.X * defaultVelocityX
        velocityZ = lookVector.Z * defaultVelocityZ
    end
    if params.StandJump.Velocity_Y then
        velocityY = params.StandJump.Velocity_Y
    else
        velocityY = lookVector.Y * defaultVelocityY
    end
    if params.StandJump.Duration then
        duration = params.StandJump.Duration
    else
        duration = defaultDuration
    end
    ]]--

    spawn(function()

        spawn(function()
            initPlayer.Character.Humanoid.WalkSpeed = 0
            wait(1)
            local totalWalkSpeed = require(Knit..WalkSpeed).GetModifiedValue(initPlayer)
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

function StandJump.Execute(initPlayer,params)

    -- setup the stand, if its not there then dont run return
	local targetStand = workspace.PlayerStands[initPlayer.UserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		return
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

        -- player jump animation
        local anim = initPlayer.Character.Humanoid:LoadAnimation(ReplicatedStorage.Animations.PlayerJump)
        anim:Play()

        ManageStand.PlayAnimation(initPlayer,params,"StandJump")
        ManageStand.MoveStand(initPlayer,{AnchorName = "StandJump"})

        wait(.7)

        ManageStand.StopAnimation(initPlayer,{AnimationName = "StandJump"})
        ManageStand.MoveStand(initPlayer,{AnchorName = "Idle"})
        anim:Stop()

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


