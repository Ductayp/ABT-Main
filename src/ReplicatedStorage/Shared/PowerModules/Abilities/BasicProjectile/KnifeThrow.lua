-- Knife Throw Mod

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

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
--KnifeThrowMod.BreakifNotHuman = false
--KnifeThrowMod.BreakifHuman = true
--KnifeThrowMod.BreakOnBlockAbility = true

-- ignore list
KnifeThrowMod.CustomIgnoreList = {}

-- animation stuff
KnifeThrowMod.PlayerAnchorTime = .5
KnifeThrowMod.StandPostion = "Front"
KnifeThrowMod.StandAnimation = "KnifeThrowMod"

-- audio
KnifeThrowMod.FireSound = ReplicatedStorage.Audio.General.GenericWhoosh_Fast

-- cosmetic projectile
KnifeThrowMod.CosmeticProjectile = ReplicatedStorage.EffectParts.Abilities.BasicProjectile.KnifeThrow.KnifeAssembly

-- hit effects
KnifeThrowMod.HitEffects = {Damage = {Damage = 20}}

function KnifeThrowMod.HitBoxResult(initPlayer, abilityDefs, result, params)
    if result.Instance.Parent:FindFirstChild("Humanoid") then
        --print("HIT A HUMANOID", result.Instance.Parent)
        Knit.Services.PowersService:RegisterHit(initPlayer, result.Instance.Parent, abilityDefs)
    end
end

-- destroy cosmetic
function KnifeThrowMod.DestroyCosmetic(projectilePart, params)

    local newBurst = ReplicatedStorage.EffectParts.Abilities.BasicProjectile.KnifeThrow.Burst:Clone()
    newBurst.Position = params.Position
    newBurst.Parent = Workspace.RenderedEffects
    Debris:AddItem(newBurst, 5)

    local sizeTween = TweenService:Create(newBurst, TweenInfo.new(.5),{Size = Vector3.new(6,6,6)})
    local transparencyTween = TweenService:Create(newBurst, TweenInfo.new(.5),{Transparency = 1})

    sizeTween:Play()
    transparencyTween:Play()

    newBurst.Part.ParticleEmitter:Emit(400)
    projectilePart:Destroy()

end

return KnifeThrowMod