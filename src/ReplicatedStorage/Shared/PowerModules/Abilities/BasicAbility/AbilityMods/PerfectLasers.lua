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
local SanityChecks = require(Knit.PowerUtils.SanityChecks)

local HIT_DELAY = .8
local RANGE = 30

local module = {}

module.InputBlockTime = 1

-- MobilityLock params
module.MobilityLockParams = {}
module.MobilityLockParams.Duration = .5
module.MobilityLockParams.ShiftLock_NoSpin = true
module.MobilityLockParams.AnchorCharacter = true


--// Server_Setup
function module.Server_Setup(params, abilityDefs, initPlayer)

    params.Origin = SanityChecks.TestPosition(initPlayer, params.Origin)
    
end

--// Server_Run
function module.Server_Run(params, abilityDefs, initPlayer)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    if not initPlayer then return end
    if not initPlayer.Character then return end

    local hitCharacters = TargetByZone.GetAllInRange(initPlayer, params.Origin, RANGE, true)

    wait(HIT_DELAY)

    for _, character in pairs(hitCharacters) do

        if character ~= initPlayer.Character then

            local newLookVector = (character.HumanoidRootPart.Position - initPlayer.Character.HumanoidRootPart.Position).unit

            abilityDefs.HitEffects = {
                RunFunctions = {
                    {RunOn = "Client", Script = script, FunctionName = "LaserHit", Arguments = {}}
                },
                KnockBack = {Force = 50, ForceY = 35, LookVector = newLookVector},
                Damage = {Damage = 20, HideEffects = true}
            }

            Knit.Services.PowersService:RegisterHit(initPlayer, character, abilityDefs)

            wait(.2)

        end
    end
end

function module.Client_Initialize(params, abilityDefs, delayOffset)

    local character = Players.LocalPlayer.Character
    if not character and character then return end

    params.Origin = character.HumanoidRootPart.Position

    spawn(function()

        Knit.Controllers.PlayerUtilityController.PlayerAnimations.PowerPose1:Play()
        wait(module.MobilityLockParams.Duration)
        Knit.Controllers.PlayerUtilityController.PlayerAnimations.PowerPose1:Stop()

    end)


end


--// Client_Stage_1
function module.Client_Stage_1(params, abilityDefs, delayOffset)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    if not initPlayer then return end
    if not initPlayer.Character then return end

    local targetStand = Workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
    if not targetStand then
        targetStand = ManageStand.QuickRender(params)
    end

    spawn(function()

        WeldedSound.NewSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.General.Wry)
        WeldedSound.NewSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.General.GlassBoom)

        ManageStand.PlayAnimation(params, "RotateAttack")
        ManageStand.MoveStand(params, "IdleHigh")
        ManageStand.Aura_On(params)

        wait(.5)

        WeldedSound.NewSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.General.PowerUpStinger3)
        
        wait(2)

        ManageStand.MoveStand(params, "Idle")
        ManageStand.Aura_Off(params)
    end)

    
    

    -- particles
    local newParticles = ReplicatedStorage.EffectParts.Abilities.BasicAbility.PerfectLasers.BeamParticles:Clone()
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

    -- laser ball -----------------------------------------------------------
    local laserBall = ReplicatedStorage.EffectParts.Abilities.BasicAbility.PerfectLasers.LaserBall:Clone()
    laserBall.Parent = Workspace.RenderedEffects
    laserBall.CFrame = CFrame.new(params.Origin)

    local headAttach = Instance.new("Attachment")
    headAttach.Parent = targetStand.Head
    Debris:AddItem(headAttach, 20)

    local beamTargets = laserBall:GetChildren()
    for i, part in pairs(beamTargets) do
        if part:IsA("BasePart") then
            local newBeam = ReplicatedStorage.EffectParts.Abilities.BasicAbility.PerfectLasers.SkinnyBeam:Clone()
            newBeam.Parent = laserBall
            newBeam.Attachment0 = headAttach
            newBeam.Attachment1 = part.Attachment
        end
    end

    local ballSpin = TweenService:Create(laserBall, TweenInfo.new(1), { CFrame = laserBall.CFrame * CFrame.Angles(0,math.rad(-120),0) })
    local ballEnd = TweenService:Create(laserBall, TweenInfo.new(.25), { CFrame = targetStand.Head.CFrame, Size = Vector3.new(.1,.1,.1)})

    ballSpin:Play()

    wait(1)

    for i, part in pairs(beamTargets) do
        part:Destroy()
    end

    ballEnd:Play() 

    wait(.3)

    laserBall:Destroy()

end

--// Client_Stage_2
function module.Client_Stage_2(params, abilityDefs, initPlayer)

    if not initPlayer then return end
    if not initPlayer.Character then return end

    local targetStand = Workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
    if not targetStand then
        targetStand = ManageStand.QuickRender(params)
    end

    wait(HIT_DELAY)

    local newParticles = ReplicatedStorage.EffectParts.Abilities.BasicAbility.PerfectLasers.PopParticles:Clone()
    newParticles.Parent = Workspace.RenderedEffects
    newParticles.CFrame = targetStand.Head.CFrame
    utils.EasyWeld(newParticles, targetStand.HumanoidRootPart, newParticles)
    Debris:AddItem(newParticles, 10)
    newParticles.RingBolts:Emit(2)
    newParticles.Hex:Emit(50)

end

function module.LaserHit(params)

    if not params.InitPlayer then return end
    if not params.InitPlayer.Character then return end

    if not params.HitCharacter then return end

    WeldedSound.NewSound(params.InitPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.General.LaserBeamDescend)

    local targetStand = Workspace.PlayerStands[params.InitPlayer.UserId]:FindFirstChildWhichIsA("Model")
    if not targetStand then
        targetStand = ManageStand.QuickRender(params)
    end

    local attach0 = Instance.new("Attachment")
    attach0.Parent = targetStand.Head

    local attach1 = Instance.new("Attachment")
    attach1.Parent = params.HitCharacter.UpperTorso

    local newBeam = ReplicatedStorage.EffectParts.Abilities.BasicAbility.PerfectLasers.FatBeam:Clone()
    newBeam.Parent = targetStand.Head
    newBeam.Attachment0 = attach0
    newBeam.Attachment1 = attach1

    local hitParticles = ReplicatedStorage.EffectParts.Abilities.BasicAbility.PerfectLasers.HitParticles:Clone()
    hitParticles.Parent = Workspace.RenderedEffects
    hitParticles.CFrame = params.HitCharacter.HumanoidRootPart.CFrame
    utils.EasyWeld(hitParticles, params.HitCharacter.UpperTorso, hitParticles)
    Debris:AddItem(hitParticles, 5)

    for _, v in pairs(hitParticles:GetDescendants()) do
        if v:IsA("ParticleEmitter") then
            if v.Name == "RingBolts" then
                v:Emit(2)
            else
                v:Emit(50)
            end
            
        end
    end

    wait(.75)

    attach0:Destroy()
    attach1:Destroy()
    newBeam:Destroy()



end


return module