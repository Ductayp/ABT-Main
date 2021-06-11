-- Knife Throw Mod

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local WeldedSound = require(Knit.PowerUtils.WeldedSound)

local LaserEyesMod = {}

--LaserEyesMod.Cooldown = 3

-- projectile origin
LaserEyesMod.CFrameOffest = CFrame.new(0, 1.5, 0) -- offset from the initPlayers HRP

-- hitbox data points
LaserEyesMod.HitBox_Size_X = 2.5
LaserEyesMod.HitBox_Size_Y = 2.5
LaserEyesMod.HitBox_Resolution_X = .5
LaserEyesMod.HitBox_Resolution_Y = 1 -- having this larger than the Y size will make it a flat plane

-- ray data
LaserEyesMod.Velocity = 800
LaserEyesMod.Lifetime = .5
LaserEyesMod.Iterations = 1
LaserEyesMod.BreakOnHit = false
LaserEyesMod.BreakifHuman = false
LaserEyesMod.BreakOnBlockAbility = false

-- ignore list
LaserEyesMod.CustomIgnoreList = {}

-- animation stuff
LaserEyesMod.PlayerAnchorTime = 0

-- hit effects
LaserEyesMod.HitEffects = {Damage = {Damage = 15}}

function LaserEyesMod.HitBoxResult(initPlayer, params, abilityDefs, result)

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

-- setup cosmetic
function LaserEyesMod.SetupCosmetic(initPlayer, params, abilityDefs)

    local newProjectile = ReplicatedStorage.EffectParts.Abilities.BasicProjectile.LaserEyes.LaserEyesAssembly:Clone()
    local newEyeBlast = ReplicatedStorage.EffectParts.Abilities.BasicProjectile.LaserEyes.EyeBlast:Clone()

    local newWeld1 = Instance.new("Weld")
    newWeld1.C1 =  CFrame.new(0,.2,0)
    newWeld1.Part0 = newProjectile.BeamAnchor
    newWeld1.Part1 = initPlayer.Character.Head
    newWeld1.Parent = newProjectile.BeamAnchor

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

    spawn(function()
        wait(0.1)

        if not newProjectile then return end
        if not newProjectile.BeamAnchor then return end
        if not newProjectile.BeamAnchor.BodyVelocity then return end
        if not newWeld1 then return end

        newWeld1:Destroy()
        newProjectile.BeamAnchor.BodyVelocity.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
        newProjectile.BeamAnchor.BodyVelocity.P = LaserEyesMod.Velocity
        newProjectile.BeamAnchor.BodyVelocity.Velocity = params.projectileOrigin.LookVector * LaserEyesMod.Velocity

    end)

    return newProjectile
end

-- fire effects
function LaserEyesMod.FireEffects(initPlayer, projectile, params, abilityDefs)

    WeldedSound.NewSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.General.LaserBeamDescend)

end

function LaserEyesMod.ParticlePop(params)

    local projectilePart = Workspace.RenderedEffects:FindFirstChild(params.ProjectileID)

    local newBurst = ReplicatedStorage.EffectParts.Abilities.BasicProjectile.LaserEyes.Burst:Clone()
    newBurst.Position = params.Position
    newBurst.Parent = Workspace.RenderedEffects
    Debris:AddItem(newBurst, 5)

    --local sizeTween = TweenService:Create(newBurst, TweenInfo.new(.5),{Size = Vector3.new(2,2,2)})
    --local transparencyTween = TweenService:Create(newBurst, TweenInfo.new(.5),{Transparency = 1})

    --sizeTween:Play()
    --transparencyTween:Play()

    newBurst.Part.ParticleEmitter:Emit(20)

end

return LaserEyesMod