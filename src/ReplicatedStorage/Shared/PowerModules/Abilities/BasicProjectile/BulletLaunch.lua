-- BulletLaunch mod for BasicProjectile
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local hitboxMod = require(Knit.Shared.RaycastProjectileHitbox)

module = {}


-- animation data
module.StandAnimation = ReplicatedStorage.StandAnimations.KnifeThrow,
module.FireSound = ReplicatedStorage.Audio.General.GenericWhoosh_Fast,
module.StandMove = {
    Positionname = "Front",
    ReturnDelay = 1.5,
},
module.Projectile = {
    Range = 70,
    Assembly = ReplicatedStorage.EffectParts.AbilityMods.BulletLaunch.Bullet,
    OriginOffset = CFrame.new(0,1,-6),
}

function module.GetDataPoints(initPlayer)

end

-- raycast projectile data
SquarePoints = {X = 2, Y = 2},
HitboxData = {
    Direction = CFrame.new(rootPart.Position, mouseCFrame.Position).LookVector
    Velocity= 2000
    Lifetime = 0.1
    Iterations = 300
    Visualize = false
    Ignore = {workspace.Debris, workspace.Spawns, character}
},



return module