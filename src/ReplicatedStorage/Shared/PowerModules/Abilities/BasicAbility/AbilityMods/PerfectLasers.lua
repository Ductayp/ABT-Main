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

local HIT_DELAY = .1
local RANGE = 15

local module = {}

-- MobilityLock params
module.MobilityLockParams = {}
module.MobilityLockParams.Duration = 1
module.MobilityLockParams.ShiftLock_NoSpin = true
module.MobilityLockParams.AnchorCharacter = true


--// Server_Setup
function module.Server_Setup(params, abilityDefs, initPlayer)
    params.Origin = initPlayer.Character.HumanoidRootPart.Position
end

--// Server_Run
function module.Server_Run(params, abilityDefs, initPlayer)

    wait(HIT_DELAY)



    local hitCharacters = TargetByZone.GetAllInRange(initPlayer, params.Origin, RANGE, true)

    for _, character in pairs(hitCharacters) do

        abilityDefs.HitEffects = {
            RenderEffects = {
                {Script = script, Function = "LaserHit", Arguments = {InitPlayer = initPlayer, HitCharacter = character}}
            },
            Damage = {Damage = 30},
        }

        if character ~= initPlayer.Character then
            Knit.Services.PowersService:RegisterHit(initPlayer, character, abilityDefs)
        end
    end

end

function module.Client_Initialize(params, abilityDefs, delayOffset)

    local character = Players.LocalPlayer.Character
    if not character and character.HumanoidRootPart then return end

    spawn(function()

        Knit.Controllers.PlayerUtilityController.PlayerAnimations.PowerPose1:Play()
        wait(module.MobilityLockParams.Duration)
        Knit.Controllers.PlayerUtilityController.PlayerAnimations.PowerPose1:Stop()

    end)


end


--// Client_Stage_1
function module.Client_Stage_1(params, abilityDefs, delayOffset)

    local targetStand = Workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
    if not targetStand then
        targetStand = ManageStand.QuickRender(params)
    end

    spawn(function()
        ManageStand.PlayAnimation(params, "RotateAttack")
        ManageStand.MoveStand(params, "IdleHigh")
        ManageStand.Aura_On(params)
        
        wait(2.2)

        ManageStand.MoveStand(params, "Idle")
        ManageStand.Aura_Off(params)
    end)

    -- particles
    local newParticles = ReplicatedStorage.EffectParts.Abilities.BasicAbility.PerfectLasers.Particles:Clone()
    newParticles.Parent = Workspace.RenderedEffects
    newParticles.CFrame = targetStand.Head.CFrame
    utils.EasyWeld(newParticles, targetStand.Head, newParticles)
    Debris:AddItem(newParticles, 10)
    newParticles.Attach.Rays:Emit(30)
    newParticles.Attach.Hex:Emit(30)
    newParticles.Attach.Aura:Emit(30)
    for _,v in pairs(newParticles.Attach:GetChildren()) do
        if v:IsA("ParticleEmitter") then
            v.Enabled = false
        end
    end

    -- laser ball
    local laserBall = ReplicatedStorage.EffectParts.Abilities.BasicAbility.PerfectLasers.LaserBall:Clone()
    laserBall.Parent = Workspace.RenderedEffects
    laserBall.CFrame = initPlayer.Character.HumanoidRootPart.CFrame

    local headAttach = Instance.new("Attachment")
    headAttach.Paent = targetStand.Head

    local beamAttachments = laserBall:GetChildren()
    for i, attachment in pairs(beamAttachments) do

        local newBeam = ReplicatedStorage.EffectParts.Abilities.BasicAbility.PerfectLasers.Beam:Clone()
        newBeam.Parent = laserBall
        newBeam.Attachment0 = headAttach
        newBeam.Attachment1 = attachment
    end

end

--// Client_Stage_2
function module.Client_Stage_2(params, abilityDefs, initPlayer)

    if not initPlayer then return end
    if not initPlayer.Character then return end

    --[[
    local newBubble = ReplicatedStorage.EffectParts.Abilities.BasicAbility.PerfectLasers.Bubble:Clone()
    newBubble.Parent = Workspace.RenderedEffects
    newBubble.CFrame = initPlayer.Character.HumanoidRootPart.CFrame

    local tween1 = TweenService:Create(newBubble, TweenInfo.new(2), {Transparency = 1, Size = Vector3.new(5,5,5)})
    local tween2 = TweenService:Create(newBubble.Mesh, TweenInfo.new(2.5), {Transparency = 1})
    tween1:Play()
    tween2:Play()
    tween1:Destroy()
    tween2:Destroy()

    wait(2.1)

    newBubble:Destroy()
    ]]--


   
end

function module.LaserHit(params)

    if not params.InitPlayer then return end
    if not params.InitPlayer.Character then return end

    if not params.HitCharacter then return end

    WeldedSound.NewSound(params.HitCharacter.HumanoidRootPart, ReplicatedStorage.Audio.General.LaserBeamDescend)

    local targetStand = Workspace.PlayerStands[params.InitPlayer.UserId]:FindFirstChildWhichIsA("Model")
    if not targetStand then
        targetStand = ManageStand.QuickRender(params)
    end

    local attach0 = Instance.new("Attachment")
    attach0.Parent = targetStand.Head

    local attach1 = Instance.new("Attachment")
    attach1.Parent = params.HitCharacter.Head

    local newBeam = ReplicatedStorage.EffectParts.Abilities.BasicAbility.PerfectLasers.Beam:Clone()
    newBeam.Parent = targetStand.Head
    newBeam.Attachment0 = attach0
    newBeam.Attachment1 = attach1

    wait(1.5)

    attach0:Destroy()
    attach1:Destroy()
    newBeam:Destroy()





end


return module