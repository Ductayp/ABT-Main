-- Knife Throw Mod

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local WeldedSound = require(Knit.PowerUtils.WeldedSound)
local utils = require(Knit.Shared.Utils)

local module = {}

module.InputBlockTime = .1

module.MobilityLockParams = {}
module.MobilityLockParams.Duration = .5
module.MobilityLockParams.ShiftLock_NoSpin = true
module.MobilityLockParams.AnchorCharacter = true

-- projectile origin
module.CFrameOffest = CFrame.new(0, 1.5, 0) -- offset from the initPlayers HRP

-- hitbox data points
module.HitBox_Size_X = 2.5
module.HitBox_Size_Y = 2.5
module.HitBox_Resolution_X = .5
module.HitBox_Resolution_Y = 1 -- having this larger than the Y size will make it a flat plane

-- ray data
module.Velocity = 800
module.Lifetime = .5
module.Iterations = 1
module.BreakOnHit = false
module.BreakifHuman = false
module.BreakOnBlockAbility = false

-- ignore list
module.CustomIgnoreList = {}


-- hit effects
module.HitEffects = {Damage = {Damage = 15}}

-----------------------------------------------------------------------------------------------------------------------
-- SERVER FUNCTIONS ---------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

--// HitBoxResult
function module.HitBoxResult(initPlayer, params, abilityDefs, result)

    abilityDefs.HitEffects = module.HitEffects

    --print("HIT A HUMANOID", result.Instance.Parent)
    if result.Instance.Parent:FindFirstChild("Humanoid") then
        Knit.Services.PowersService:RegisterHit(initPlayer, result.Instance.Parent, abilityDefs)
    end

    local abilityScript = script.Parent
    local resultParams = {}
    resultParams.Position = result.Position
    resultParams.ProjectileID = params.projectileID

    Knit.Services.PowersService:RenderAbilityEffect_AllPlayers(script, "ParticlePop", resultParams)

end

-----------------------------------------------------------------------------------------------------------------------
-- CLIENT FUNCTIONS ---------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

--// Client_Initialize
function module.Client_Initialize(params, abilityDefs, playerPing)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    if not initPlayer and initPlayer.Character then return end

    spawn(function()

        Knit.Controllers.PlayerUtilityController.PlayerAnimations.Point:Play()
        wait(.5)
        Knit.Controllers.PlayerUtilityController.PlayerAnimations.Point:Stop()

    end)
end

--// Client_Stage_1
function module.Client_Stage_1(params, abilityDefs, delayOffset)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    if not initPlayer and initPlayer.Character then return end

    spawn(function()
        WeldedSound.NewSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.General.MagicWandCast6)

        local newEyeBlast = ReplicatedStorage.EffectParts.Abilities.BasicProjectile.LaserEyes.EyeBlast:Clone()

        local newWeld2 = Instance.new("Weld")
        newWeld2.C1 =  CFrame.new(0,.2,0)
        newWeld2.Part0 = newEyeBlast
        newWeld2.Part1 = initPlayer.Character.Head
        newWeld2.Parent = newEyeBlast
        newEyeBlast.Parent = Workspace.RenderedEffects
        Debris:AddItem(newEyeBlast, 2)

        local tween1 = TweenService:Create(newEyeBlast.Blast_Left, TweenInfo.new(.7),{Transparency = 1})
        local tween2 = TweenService:Create(newEyeBlast.Blast_Right, TweenInfo.new(.7),{Transparency = 1})
        tween1:Play()
        tween2:Play()

    end)
end



--// Projectile_Setup
function module.Projectile_Setup(initPlayer, params, abilityDefs)

    local newProjectile = ReplicatedStorage.EffectParts.Abilities.BasicProjectile.LaserEyes.LaserEyesAssembly:Clone()

    newProjectile.BeamAnchor.CFrame = params.projectileOrigin
    newProjectile.BeamAnchor.Anchored = true

    spawn(function()
        wait(0.05)

        if not newProjectile then return end
        if not newProjectile.BeamAnchor then return end
        if not newProjectile.BeamAnchor.BodyVelocity then return end

        newProjectile.BeamAnchor.BodyVelocity.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
        newProjectile.BeamAnchor.BodyVelocity.P = module.Velocity
        newProjectile.BeamAnchor.BodyVelocity.Velocity = params.projectileOrigin.LookVector * module.Velocity

        newProjectile.BeamAnchor.Anchored = false

    end)

    return newProjectile
end

--// Projectile_FireEffects
function module.Projectile_FireEffects(initPlayer, projectile, params, abilityDefs)

    WeldedSound.NewSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.General.LaserBeamDescend)

end

--// ParticlePop
function module.ParticlePop(params)

    local projectilePart = Workspace.RenderedEffects:FindFirstChild(params.ProjectileID)

    local newBurst = ReplicatedStorage.EffectParts.Abilities.BasicProjectile.LaserEyes.Burst:Clone()
    newBurst.Position = params.Position
    newBurst.Parent = Workspace.RenderedEffects
    Debris:AddItem(newBurst, 5)

    newBurst.Part.ParticleEmitter:Emit(20)

end

-- end cosmetic
function module.Projectile_Destroy(projectile)

    projectile:Destroy()

end

return module