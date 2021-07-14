
-- Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))


local module = {}

--/ Spawners
module.SpawnersFolder = Workspace:FindFirstChild("MobSpawners_Santana", true)

--/ Model
module.Model = ReplicatedStorage.Mobs.Santana

--/ Spawn
module.RespawnClock = os.clock()
module.RespawnTime = 10
module.RandomPlacement = true
module.Spawn_Y_Offset = 5
module.Max_Spawned = 6

--/ Animations
module.Animations = {
    Idle = "rbxassetid://507766666",
    Walk = "rbxassetid://507777826",
    Attack = {"rbxassetid://6235460206", "rbxassetid://6235479125"},
}

module.Defs = {}
module.Defs.Name = "Pillar Man"
module.Defs.MapZone = "Morioh"
module.Defs.XpValue = 80
module.Defs.Health = 100
module.Defs.WalkSpeed = 16
module.Defs.JumpPower = 50
module.Defs.Aggressive = false
module.Defs.AttackSpeed = 2
module.Defs.AttackRange = 4
module.Defs.HitEffects = {Damage = {Damage = 15}}
module.Defs.SeekRange = 60 -- In Studs
module.Defs.ChaseRange = 80 -- In Studs
module.Defs.IsMobile = true
module.Defs.LifeSpan = 300 -- number of seconds it will live, get killed when the time is up

function module.GetModel()
    return module.Model
end

--/ Spawn Function
function module.Pre_Spawn(mobData)

    -- set mob to inactive so its brain doesnt run yet
    mobData.Active = false

    -- make everything trasnparent for the spawn
    for _,instance in pairs(mobData.Model:GetDescendants()) do
        if instance:IsA("BasePart") then
            instance.Transparency = 1
        end
    end
end

--/ Spawn Function
function module.Post_Spawn(mobData)
    
    spawn(function()

        -- a little particle effects
        mobData.Model.HumanoidRootPart.ParticleEmitter.Rate = 200
        wait(1)
        mobData.Model.HumanoidRootPart.ParticleEmitter.Rate = 500
        wait(1.2)
        mobData.Model.HumanoidRootPart.ParticleEmitter.Rate = 0

        -- make the mob active so the brain runs
        mobData.Active = true

        -- make it visible
        for _,instance in pairs(mobData.Model:GetDescendants()) do
            if instance:IsA("BasePart") then
                if instance.Name == "HumanoidRootPart" then
                    instance.Transparency = 1
                else
                    instance.Transparency = 0
                end
            end
        end
    end)
end

--// Setup_Animations
function module.Setup_Animations(mobData)

    -- add an animator
    mobData.Animations = {} -- setup a table
    mobData.Animations.Attack = {} -- we need another table for attack aniamtions
    local animator = Instance.new("Animator")
    animator.Parent = mobData.Model.Humanoid

    -- idle animation
    local idleAnimation = Instance.new("Animation")
    idleAnimation.AnimationId = module.Animations.Idle
    mobData.Animations.Idle = animator:LoadAnimation(idleAnimation)
    idleAnimation:Destroy()

    -- walk animation
    local walkAnimation = Instance.new("Animation")
    walkAnimation.AnimationId = module.Animations.Walk
    mobData.Animations.Walk = animator:LoadAnimation(walkAnimation)
    walkAnimation:Destroy()

    -- attack animations
    for index, animationId in pairs(module.Animations.Attack) do
        local newAnimation = Instance.new("Animation")
        newAnimation.AnimationId = animationId
        local newTrack = animator:LoadAnimation(newAnimation)
        table.insert(mobData.Animations.Attack, newTrack)
        newAnimation:Destroy()
    end

end

--// Setup_Attack
function  module.Setup_Attack(mobData)
    -- nothing here. yet ...
end

--// Attack
function  module.Attack(mobData)

    spawn(function()

        if not mobData.DisableAnimations then
            local rand = math.random(1, #mobData.Animations.Attack)
            mobData.Animations.Attack[rand]:Play()
        end

        mobData.Model.Humanoid.WalkSpeed = 2
        local rand = math.random(1, #mobData.Animations.Attack)
        wait(.25)
        mobData.Model.Humanoid.WalkSpeed = require(Knit.MobUtils.MobWalkSpeed).GetWalkSpeed(mobData)

        Knit.Services.MobService:HitPlayer(mobData.AttackTarget, mobData.Defs.HitEffects, mobData)
    end)  
                               
end

--// Setup_Death
function module.Setup_Death(mobData)
    -- nothing here, yet ...
end

--// Death
function module.Death(mobData)

    spawn(function()
        mobData.Model.HumanoidRootPart.ParticleEmitter.Rate = 1000
        wait(.1)
        mobData.Model.HumanoidRootPart.ParticleEmitter.Rate = 0
    end)
end

--// DeSpawn
function module.DeSpawn(mobData)

end

--// Setup_Drop
function module.Setup_Drop(mobData)
    -- nothing here, yet ...
end

--// Drop
function module.Drop(player, mobData)

    local rewards = {}
    rewards.Items = {}
    rewards.Items["MaskFragment"] = 1

    --[[
    local itemDropPercent = 65
    local rand = math.random(1, 100)
    if rand <= itemDropPercent then
        
    end
    ]]--

    rewards.XP = module.Defs.XpValue
    rewards.SoulOrbs = 1

    return rewards
    
end



return module