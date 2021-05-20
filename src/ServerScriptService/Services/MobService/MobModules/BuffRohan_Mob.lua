-- BuffRohan_Mob Mob
-- Pdab
-- 1/10/21

-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))


local BuffRohan_Mob = {}

--/ Model
BuffRohan_Mob.Model = ReplicatedStorage.Mobs.BuffRohan

--/ Spawn
BuffRohan_Mob.RespawnTime = 10
BuffRohan_Mob.RandomPlacement = true
BuffRohan_Mob.Spawn_Z_Offset = 3
BuffRohan_Mob.Max_Spawned = 4

--/ Animations
BuffRohan_Mob.Animations = {
    Idle = "rbxassetid://507766666",
    Walk = "rbxassetid://507777826",
    Attack = {"rbxassetid://6235460206", "rbxassetid://6235479125"},
}

BuffRohan_Mob.Defs = {}
BuffRohan_Mob.Defs.Name = "Buff Mangaka"
BuffRohan_Mob.Defs.XpValue = 350
BuffRohan_Mob.Defs.Health = 300
BuffRohan_Mob.Defs.WalkSpeed = 16
BuffRohan_Mob.Defs.JumpPower = 50
BuffRohan_Mob.Defs.Aggressive = true
BuffRohan_Mob.Defs.AttackSpeed = 2
BuffRohan_Mob.Defs.AttackRange = 4.5
BuffRohan_Mob.Defs.HitEffects = {Damage = {Damage = 20}}
BuffRohan_Mob.Defs.SeekRange = 60 -- In Studs
BuffRohan_Mob.Defs.ChaseRange = 80 -- In Studs
BuffRohan_Mob.Defs.IsMobile = true
BuffRohan_Mob.Defs.LifeSpan = 300 -- number of seconds it will live, get killed when the time is up



--/ Spawn Function
function BuffRohan_Mob.Pre_Spawn(mobData)

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
function BuffRohan_Mob.Post_Spawn(mobData)
    
    spawn(function()

        --[[
        -- a little particle effects
        mobData.Model.HumanoidRootPart.ParticleEmitter.Rate = 200
        wait(1)
        mobData.Model.HumanoidRootPart.ParticleEmitter.Rate = 500
        wait(1.2)
        mobData.Model.HumanoidRootPart.ParticleEmitter.Rate = 0
        ]]--

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
function BuffRohan_Mob.Setup_Animations(mobData)

    -- add an animator
    mobData.Animations = {} -- setup a table
    mobData.Animations.Attack = {} -- we need another table for attack aniamtions
    local animator = Instance.new("Animator")
    animator.Parent = mobData.Model.Humanoid

    -- idle animation
    local idleAnimation = Instance.new("Animation")
    idleAnimation.AnimationId = BuffRohan_Mob.Animations.Idle
    mobData.Animations.Idle = animator:LoadAnimation(idleAnimation)
    idleAnimation:Destroy()

    -- walk animation
    local walkAnimation = Instance.new("Animation")
    walkAnimation.AnimationId = BuffRohan_Mob.Animations.Walk
    mobData.Animations.Walk = animator:LoadAnimation(walkAnimation)
    walkAnimation:Destroy()

    -- attack animations
    for index, animationId in pairs(BuffRohan_Mob.Animations.Attack) do
        local newAnimation = Instance.new("Animation")
        newAnimation.AnimationId = animationId
        local newTrack = animator:LoadAnimation(newAnimation)
        table.insert(mobData.Animations.Attack, newTrack)
        newAnimation:Destroy()
    end

end

--// Setup_Attack
function  BuffRohan_Mob.Setup_Attack(mobData)
    -- nothing here. yet ...
end

--// Attack
function  BuffRohan_Mob.Attack(mobData)



    spawn(function()

        if not mobData.DisableAnimations then
            local rand = math.random(1, #mobData.Animations.Attack)
            mobData.Animations.Attack[rand]:Play()
        end

        mobData.Model.Humanoid.WalkSpeed = 2
        wait(.25)
        mobData.Model.Humanoid.WalkSpeed = mobData.Defs.WalkSpeed

        Knit.Services.MobService:HitPlayer(mobData.AttackTarget, mobData.Defs.HitEffects)
    end)  
                               
end

--// Setup_Death
function BuffRohan_Mob.Setup_Death(mobData)
    -- nothing here, yet ...
end

--// Death
function BuffRohan_Mob.Death(mobData)

    spawn(function()
        --mobData.Model.HumanoidRootPart.ParticleEmitter.Rate = 1000
        wait(.1)
        --mobData.Model.HumanoidRootPart.ParticleEmitter.Rate = 5
    end)
end

--// Setup_Drop
function BuffRohan_Mob.Setup_Drop(mobData)
    -- nothing here, yet ...
end

--// Drop
function BuffRohan_Mob.Drop(player, mobData)

    local rewards = {}
    rewards.Items = {}

    local itemDropPercent = 25
    local rand = math.random(1, 100)
    if rand <= itemDropPercent then
        rewards.Items["BlankPage"] = 1
    end

    rewards.XP = BuffRohan_Mob.Defs.XpValue
    rewards.SoulOrbs = 1

    return rewards
    
end

return BuffRohan_Mob