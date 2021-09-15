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
--local MobAnimations = require(Knit.MobUtils.MobAnimations)

local module = {}

module.InputBlockTime = .5

-- MobilityLock params
module.MobilityLockParams = {}
module.MobilityLockParams.Duration = 0
module.MobilityLockParams.ShiftLock_NoSpin = true
module.MobilityLockParams.AnchorCharacter = true

local EFFECT_DURATION = 10

--// Server_Setup
function module.Server_Setup(params, abilityDefs, initPlayer)


end

--// Server_Run
function module.Server_Run(params, abilityDefs, initPlayer)

    if not initPlayer then return end

    local character = initPlayer.Character
    if not character then return end

    local HRP = character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end

    local organToggle = initPlayer.Character:FindFirstChild("OrganInversion_Active", true)
    if not organToggle then
        organToggle = Instance.new("BoolValue")
        organToggle.Name = "OrganInversion_Active"
        organToggle.Parent = character
    end

    organToggle.Value = true
    spawn(function()
        wait(EFFECT_DURATION)
        organToggle.Value = false
    end)

end


function module.Client_Initialize(params, abilityDefs, delayOffset)

    spawn(function()
        Knit.Controllers.PlayerUtilityController.PlayerAnimations.Rage:Play()
        wait(.5)
        Knit.Controllers.PlayerUtilityController.PlayerAnimations.Rage:Stop()
    end)
    
end


--// Client_Stage_1
function module.Client_Stage_1(params, abilityDefs, initPlayer)

    local character = initPlayer.Character
    if not character then return end
    
    local HRP = character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end

    local targetStand = Workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
    if not targetStand then
        targetStand = ManageStand.QuickRender(params)
    end

    WeldedSound.NewSound(targetStand.HumanoidRootPart, ReplicatedStorage.Audio.General.PulseRay6)

    spawn(function()

        ManageStand.PlayAnimation(params, "CastOnUser")
        wait(2)
        ManageStand.StopAnimation(params, "CastOnUser")

    end)

    spawn(function()

        ManageStand.Aura_On(params)
        wait(EFFECT_DURATION)
        ManageStand.Aura_Off(params)

    end)

    spawn(function()

        local fistAuraLeft = ReplicatedStorage.EffectParts.Abilities.BasicAbility.OrganInversion.FistAura:Clone()
        local fistAuraRight = ReplicatedStorage.EffectParts.Abilities.BasicAbility.OrganInversion.FistAura:Clone()
        local headAura = ReplicatedStorage.EffectParts.Abilities.BasicAbility.OrganInversion.HeadAura:Clone()

        fistAuraLeft.Parent = character.LeftHand
        fistAuraRight.Parent = character.RightHand
        headAura.Parent = character.Head

        wait(EFFECT_DURATION)

        fistAuraLeft:Destroy()
        fistAuraRight:Destroy()
        headAura:Destroy()

    end)


end

--// Client_Stage_2
function module.Client_Stage_2(params, abilityDefs, initPlayer)

    -- nothing needed here

end


return module