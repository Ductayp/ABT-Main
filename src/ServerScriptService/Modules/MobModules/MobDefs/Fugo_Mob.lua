-- Fugo_Mob Mob
-- Pdab
-- 1/10/21

-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))


local Fugo_Mob = {}

--/ Model
Fugo_Mob.Model = ReplicatedStorage.Mobs.Fugo

--/ Spawn
Fugo_Mob.RespawnTime = 10
Fugo_Mob.RandomPlacement = true
Fugo_Mob.Spawn_Z_Offset = 5
Fugo_Mob.Max_Spawned = 4

--/ Animations
Fugo_Mob.Animations = {
    Idle = "rbxassetid://507766666",
    Walk = "rbxassetid://507777826",
    Attack = {"rbxassetid://6235460206", "rbxassetid://6235479125"},
}

Fugo_Mob.Defs = {}
Fugo_Mob.Defs.XpValue = 100
Fugo_Mob.Defs.Health = 200
Fugo_Mob.Defs.WalkSpeed = 16
Fugo_Mob.Defs.JumpPower = 50
Fugo_Mob.Defs.Aggressive = false
Fugo_Mob.Defs.AttackSpeed = 2
Fugo_Mob.Defs.AttackRange = 4.5
Fugo_Mob.Defs.SeekRange = 50 -- In Studs
Fugo_Mob.Defs.ChaseRange = 50 -- In Studs
Fugo_Mob.Defs.IsMobile = true
Fugo_Mob.Defs.LifeSpan = 300 -- number of seconds it will live, get killed when the time is up


-- attack defs
Fugo_Mob.HitEffects = {Damage = {Damage = 10}}
Fugo_Mob.Special_HitEffects = {Poison = {TickTime = 1, TickCount = 4, Damage = 10}}


--/ Spawn Function
function Fugo_Mob.Pre_Spawn(mobData)

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
function Fugo_Mob.Post_Spawn(mobData)
    
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
function Fugo_Mob.Setup_Animations(mobData)

    -- add an animator
    mobData.Animations = {} -- setup a table
    mobData.Animations.Attack = {} -- we need another table for attack aniamtions
    local animator = Instance.new("Animator")
    animator.Parent = mobData.Model.Humanoid

    -- idle animation
    local idleAnimation = Instance.new("Animation")
    idleAnimation.AnimationId = Fugo_Mob.Animations.Idle
    mobData.Animations.Idle = animator:LoadAnimation(idleAnimation)
    idleAnimation:Destroy()

    -- walk animation
    local walkAnimation = Instance.new("Animation")
    walkAnimation.AnimationId = Fugo_Mob.Animations.Walk
    mobData.Animations.Walk = animator:LoadAnimation(walkAnimation)
    walkAnimation:Destroy()

    -- attack animations
    for index, animationId in pairs(Fugo_Mob.Animations.Attack) do
        local newAnimation = Instance.new("Animation")
        newAnimation.AnimationId = animationId
        local newTrack = animator:LoadAnimation(newAnimation)
        table.insert(mobData.Animations.Attack, newTrack)
        newAnimation:Destroy()
    end

end

--// Setup_Attack
function  Fugo_Mob.Setup_Attack(mobData)
    -- nothing here. yet ...
end

--// Attack
function  Fugo_Mob.Attack(mobData)

    spawn(function()

        mobData.Model.Humanoid.WalkSpeed = 2
        local rand = math.random(1, #mobData.Animations.Attack)
        mobData.Animations.Attack[rand]:Play()
        wait(.25)
        mobData.Model.Humanoid.WalkSpeed = mobData.Defs.WalkSpeed
        
        local rand = math.random(1,100)
        if rand <= 75 then
            Knit.Services.MobService:HitPlayer(mobData.AttackTarget, Fugo_Mob.Special_HitEffects)
        else
            Knit.Services.MobService:HitPlayer(mobData.AttackTarget, Fugo_Mob.HitEffects)
        end
    
    end) 
                               
end

--// Setup_Death
function Fugo_Mob.Setup_Death(mobData)
    -- nothing here, yet ...
end

--// Death
function Fugo_Mob.Death(mobData)

    spawn(function()
        mobData.Model.HumanoidRootPart.ParticleEmitter.Rate = 1000
        wait(.1)
        mobData.Model.HumanoidRootPart.ParticleEmitter.Rate = 5
    end)
end

--// Setup_Drop
function Fugo_Mob.Setup_Drop(mobData)
    -- nothing here, yet ...
end

--// Drop
function Fugo_Mob.Drop(player, mobData)
    
    local itemDropPercent = 10
    local rand = math.random(1, 100)
    if rand <= itemDropPercent then
        Knit.Services.InventoryService:Give_Item(player, "VirusBulb", 1)
    end

    local orbDropPercent = 50
    local rand = math.random(1, 100)
    if rand <= orbDropPercent then
        local value = math.random(20,40)
        Knit.Services.InventoryService:Give_Currency(player, "SoulOrbs", value, "MobDrop")
    end
end



return Fugo_Mob