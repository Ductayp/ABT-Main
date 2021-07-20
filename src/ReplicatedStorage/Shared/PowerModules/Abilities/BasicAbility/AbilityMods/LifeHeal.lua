-- BlackHole

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)
local AnchoredSound = require(Knit.PowerUtils.AnchoredSound)
local ManageStand = require(Knit.Abilities.ManageStand)
local TargetByZone = require(Knit.PowerUtils.TargetByZone)

local module = {}

local healAmount = 10
local healDuration = 7

-- MobilityLock params
module.MobilityLockParams = {}
module.MobilityLockParams.Duration = 0
module.MobilityLockParams.ShiftLock_NoSpin = true
module.MobilityLockParams.AnchorCharacter = true

--// Server_Setup
function module.Server_Setup(params, abilityDefs, initPlayer)


end

--// Server_Run
function module.Server_Run(params, abilityDefs, initPlayer)

    Knit.Services.StateService:AddEntryToState(initPlayer, "HealthTick", "LifeHealAbility", true, {Day = healAmount, Night = healAmount, RemoveOnDeath = true,  RemoveOnPowerChange = true})
    wait(healDuration)
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "HealthTick", "LifeHealAbility")

end

function module.Client_Initialize(params, abilityDefs, delayOffset)

    spawn(function()
        local character = Players.LocalPlayer.Character
        if not character and character.HumanoidRootPart then return end
    
        Knit.Controllers.PlayerUtilityController.PlayerAnimations.Rage:Play()
        wait(2)
        Knit.Controllers.PlayerUtilityController.PlayerAnimations.Rage:Stop()
    end)

end


--// Client_Stage_1
function module.Client_Stage_1(params, abilityDefs, delayOffset)

    local targetStand = Workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
    if not targetStand then
        targetStand = ManageStand.QuickRender(params)
    end

    WeldedSound.NewSound(targetStand.HumanoidRootPart, ReplicatedStorage.Audio.General.PulseRay6)

    ManageStand.Aura_On(params)
    --ManageStand.MoveStand(params, "IdleHigh")
    ManageStand.PlayAnimation(params, "Rage")

    wait(2)

    --ManageStand.MoveStand(params, "Idle")
    ManageStand.Aura_Off(params)

end

--// Client_Stage_2
function module.Client_Stage_2(params, abilityDefs, initPlayer)

    if not initPlayer and initPlayer.Character then return end
    
    local upperTorso = initPlayer.Character:FindFirstChild("UpperTorso")
    if not upperTorso then return end

    local newParticles = ReplicatedStorage.EffectParts.Abilities.BasicAbility.LifeHeal.HealParticles:Clone()
    newParticles.CFrame = upperTorso.CFrame
    newParticles.Parent = Workspace.RenderedEffects
    utils.EasyWeld(newParticles, upperTorso, newParticles)

    newParticles.ParticleEmitter:Emit(10)
    
    wait(healDuration)

    newParticles.ParticleEmitter.Enabled = false

    wait(3)

    newParticles:Destroy()

end


return module