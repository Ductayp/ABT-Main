-- BlackHole

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)
local ManageStand = require(Knit.Abilities.ManageStand)
local TargetByZone = require(Knit.PowerUtils.TargetByZone)


local module = {}

-- MobilityLock params
module.MobilityLockParams = {}
module.MobilityLockParams.Duration = 1
module.MobilityLockParams.ShiftLock_NoSpin = true
module.MobilityLockParams.AnchorCharacter = true

--local PULL_DURATION = 5
local TICK_COUNT = 10
local TICK_DURATION = .5
local RANGE = 40
local HIT_DELAY = .4
local BLACKHOLE_OFFSET = CFrame.new(0, 0, -6)

--// Server_Setup
function module.Server_Setup(params, abilityDefs, initPlayer)

end

--// Server_Run
function module.Server_Run(params, abilityDefs, initPlayer)

    wait(HIT_DELAY)

    local duration = TICK_COUNT * TICK_DURATION
    for count = 1, TICK_COUNT do

        abilityDefs.HitEffects = {
            Damage = {Damage = 1},
            Pull = {Position = params.BlackHoleCFrame.Position, Force = 3000, Duration = duration, Name = "BlackHole"},
        }

        local hitCharacters = TargetByZone.GetAllInRange(initPlayer, params.BlackHoleCFrame.Position, RANGE, true)
        for _, character in pairs(hitCharacters) do
            Knit.Services.PowersService:RegisterHit(initPlayer, character, abilityDefs)
        end

        wait(TICK_DURATION)
        duration = duration - TICK_DURATION

    end

end

function module.Client_Initialize(params, abilityDefs, delayOffset)

    local character = Players.LocalPlayer.Character
    if not character and character.HumanoidRootPart then return end

    spawn(function()

        Knit.Controllers.PlayerUtilityController.PlayerAnimations.Point:Play()
        wait(module.MobilityLockParams.Duration)
        Knit.Controllers.PlayerUtilityController.PlayerAnimations.Point:Stop()

    end)

    params.BlackHoleCFrame = character.HumanoidRootPart.CFrame:ToWorldSpace(BLACKHOLE_OFFSET)
end


--// Client_Stage_1
function module.Client_Stage_1(params, abilityDefs, delayOffset)

    local targetStand = Workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
    if not targetStand then
        targetStand = ManageStand.QuickRender(params)
    end

    WeldedSound.NewSound(targetStand.HumanoidRootPart, ReplicatedStorage.Audio.General.GenericWhoosh_Fast)

    -- black hole animations
    spawn(function()

        ManageStand.Aura_On(params)
        ManageStand.MoveStand(params, "IdleHigh")
        ManageStand.PlayAnimation(params, "HandSwipe")

        wait(HIT_DELAY)

        local swipeBall = ReplicatedStorage.EffectParts.Abilities.BasicAttack.BlackHole.SwipeBall:Clone()
        swipeBall.CFrame = targetStand.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(3, 3, 1))
        swipeBall.Parent = Workspace.RenderedEffects
        Debris:AddItem(swipeBall, 1)

        local swipeTween = TweenService:Create(swipeBall,TweenInfo.new(.1), {CFrame = params.BlackHoleCFrame})
        swipeTween:Play()
        swipeTween:Destroy()

        -- setup black hole parts
        local blackHoleParts = {
            newBlackBall = ReplicatedStorage.EffectParts.Abilities.BasicAttack.BlackHole.BlackBall:Clone(),
            newWhisps = ReplicatedStorage.EffectParts.Abilities.BasicAttack.BlackHole.Whisps:Clone(),
            newParticle = ReplicatedStorage.EffectParts.Abilities.BasicAttack.BlackHole.Particle:Clone(),
        }
        blackHoleParts.newWhisps.BodyPosition.Position = params.BlackHoleCFrame.Position

        wait(.1)

        local newBurst = ReplicatedStorage.EffectParts.Abilities.BasicAttack.BlackHole.Burst:Clone()
        newBurst.CFrame = params.BlackHoleCFrame
        newBurst.Parent = Workspace.RenderedEffects
        newBurst.Pop:Emit(50)

        -- render black hole parts
        for i,v in pairs (blackHoleParts) do
            v.CFrame = params.BlackHoleCFrame
            v.Parent = Workspace.RenderedEffects
        end

        spawn(function()
            wait(TICK_COUNT * TICK_DURATION)
            blackHoleParts.newBlackBall:Destroy()
            blackHoleParts.newWhisps:Destroy()
            newBurst:Destroy()
            blackHoleParts.newParticle.ParticleEmitter.Enabled = false
            Debris:AddItem(blackHoleParts.newParticle, 3)
        end)

        if delayOffset then wait(delayOffset) end

        ManageStand.MoveStand(params, "Idle")
        ManageStand.Aura_Off(params)

    end)
 
end

--// Client_Stage_2
function module.Client_Stage_2(params, abilityDefs, initPlayer)

    local mainBubble = ReplicatedStorage.EffectParts.Abilities.BasicAttack.BlackHole.BlackBubble:Clone()
    mainBubble.CFrame = params.BlackHoleCFrame
    mainBubble.Size = Vector3.new(RANGE * 2, RANGE * 2, RANGE * 2)
    mainBubble.Parent = Workspace.RenderedEffects

    for count = 1, TICK_COUNT do
        local newBubble = ReplicatedStorage.EffectParts.Abilities.BasicAttack.BlackHole.PurpleBubble:Clone()
        newBubble.CFrame = params.BlackHoleCFrame
        newBubble.Size = Vector3.new(RANGE * 2, RANGE * 2, RANGE * 2)
        newBubble.Parent = Workspace.RenderedEffects
        Debris:AddItem(newBubble, 2)
    
    
        local sizeTween = TweenService:Create(newBubble, TweenInfo.new(1), {Size = Vector3.new(1,1,1)})
        local transTween = TweenService:Create(newBubble, TweenInfo.new(1), {Transparency = 1})
        sizeTween:Play()
        transTween:Play()
        sizeTween:Destroy()
        transTween:Destroy()

        wait(TICK_DURATION)
    end

    mainBubble:Destroy()



    print("CLIENT STAGE 2")
end






return module