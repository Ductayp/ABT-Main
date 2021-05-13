-- Knife Throw Mod

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local ManageStand = require(Knit.Abilities.ManageStand)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)

local KnifeThrowMod = {}

--KnifeThrowMod.Cooldown = 3

-- projectile origin
KnifeThrowMod.CFrameOffest = CFrame.new(0, 0, -2) -- offset from the initPlayers HRP

-- hitbox data points
KnifeThrowMod.HitBox_Size_X = 4.5
KnifeThrowMod.HitBox_Size_Y = 1
KnifeThrowMod.HitBox_Resolution_X = 1
KnifeThrowMod.HitBox_Resolution_Y = 2 -- having this larger than the Y size will make it a flat plane

-- ray data
KnifeThrowMod.Velocity = 250
KnifeThrowMod.Lifetime = .5
KnifeThrowMod.Iterations = 500
KnifeThrowMod.BreakOnHit = true
--KnifeThrowMod.BreakifHuman = true
--KnifeThrowMod.BreakOnBlockAbility = true

-- ignore list
KnifeThrowMod.CustomIgnoreList = {}

-- animation stuff
KnifeThrowMod.PlayerAnchorTime = .5

-- hit effects
KnifeThrowMod.HitEffects = {Damage = {Damage = 20}}

function KnifeThrowMod.SetupCosmetic(initPlayer, params, abilityDefs)
    local projectile = ReplicatedStorage.EffectParts.Abilities.BasicProjectile.KnifeThrow.KnifeAssembly:Clone()
    spawn(function()
        wait(KnifeThrowMod.Lifetime)
        projectile:Destroy()
    end)
    return projectile
end

function KnifeThrowMod.FireEffects(initPlayer, projectile, params, abilityDefs)

    local targetStand = Workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
    if not targetStand then
        targetStand = ManageStand.QuickRender(params)
    end

    WeldedSound.NewSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.General.GenericWhoosh_Fast)

    spawn(function()
        ManageStand.MoveStand(params, "Front")
        ManageStand.PlayAnimation(params, "KnifeThrow")
        ManageStand.Aura_On(params)
        wait(KnifeThrowMod.PlayerAnchorTime)
        ManageStand.MoveStand(params, "Idle")
        ManageStand.StopAnimation(params, "KnifeThrow")
        ManageStand.Aura_Off(params)
    end)
end

function KnifeThrowMod.HitBoxResult(initPlayer, params, abilityDefs, result)

    local abilityScript = script.Parent
    local resultParams = {}
    resultParams.Position = result.Position
    resultParams.ProjectileID = params.projectileID
    resultParams.AbilityMod = abilityDefs.AbilityMod
    Knit.Services.PowersService:RenderAbilityEffect_AllPlayers(script, "DestroyCosmetic", resultParams)

    if result.Instance.Parent:FindFirstChild("Humanoid") then
        --print("HIT A HUMANOID", result.Instance.Parent)
        Knit.Services.PowersService:RegisterHit(initPlayer, result.Instance.Parent, abilityDefs)
    end
end

-- destroy cosmetic
function KnifeThrowMod.DestroyCosmetic(params)

    local projectilePart = Workspace.RenderedEffects:FindFirstChild(params.ProjectileID)

    local newBurst = ReplicatedStorage.EffectParts.Abilities.BasicProjectile.KnifeThrow.Burst:Clone()
    newBurst.Position = params.Position
    newBurst.Parent = Workspace.RenderedEffects
    Debris:AddItem(newBurst, 5)

    local sizeTween = TweenService:Create(newBurst, TweenInfo.new(.5),{Size = Vector3.new(5,5,5)})
    local transparencyTween = TweenService:Create(newBurst, TweenInfo.new(.5),{Transparency = 1})

    sizeTween:Play()
    transparencyTween:Play()

    newBurst.Part.ParticleEmitter:Emit(100)
    if projectilePart then
        projectilePart:Destroy()
    end
    

end

return KnifeThrowMod