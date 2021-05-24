-- Wamuu_Mob

-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local Wamuu_Mob = {}

--/ Spawners
Wamuu_Mob.SpawnersFolder = Workspace:FindFirstChild("MobSpawners_Wamuu", true)

--/ Model
Wamuu_Mob.Model = ReplicatedStorage.Mobs.Wamuu

--/ Spawn
Wamuu_Mob.RespawnClock = os.clock()
Wamuu_Mob.RespawnTime = 10
Wamuu_Mob.RandomPlacement = true
Wamuu_Mob.Spawn_Z_Offset = 5
Wamuu_Mob.Max_Spawned = 8

--/ Animations
Wamuu_Mob.Animations = {
    Idle = "rbxassetid://507766666",
    Walk = "rbxassetid://507777826",
    Attack = {"rbxassetid://6235460206", "rbxassetid://6235479125"},
    SpinArmsAttack = "rbxassetid://6807049836"
}

Wamuu_Mob.Defs = {}
Wamuu_Mob.Defs.Name = "Wham"
Wamuu_Mob.Defs.MapZone = "SkeletonHeelStone"
Wamuu_Mob.Defs.XpValue = 450
Wamuu_Mob.Defs.Health = 350
Wamuu_Mob.Defs.WalkSpeed = 18
Wamuu_Mob.Defs.JumpPower = 50
Wamuu_Mob.Defs.Aggressive = true
Wamuu_Mob.Defs.AttackSpeed = 2
Wamuu_Mob.Defs.AttackRange = 5
Wamuu_Mob.Defs.SeekRange = 70 -- In Studs
Wamuu_Mob.Defs.ChaseRange = 80 -- In Studs
Wamuu_Mob.Defs.IsMobile = true
Wamuu_Mob.Defs.LifeSpan = 600 -- number of seconds it will live, get killed when the time is up

--/ Spawn Function
function Wamuu_Mob.Pre_Spawn(mobData)

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
function Wamuu_Mob.Post_Spawn(mobData)
    
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
function Wamuu_Mob.Setup_Animations(mobData)

    -- add an animator
    mobData.Animations = {} -- setup a table
    mobData.Animations.Attack = {} -- we need another table for attack aniamtions
    local animator = Instance.new("Animator")
    animator.Parent = mobData.Model.Humanoid

    -- idle animation
    local idleAnimation = Instance.new("Animation")
    idleAnimation.AnimationId = Wamuu_Mob.Animations.Idle
    mobData.Animations.Idle = animator:LoadAnimation(idleAnimation)
    idleAnimation:Destroy()

    -- walk animation
    local walkAnimation = Instance.new("Animation")
    walkAnimation.AnimationId = Wamuu_Mob.Animations.Walk
    mobData.Animations.Walk = animator:LoadAnimation(walkAnimation)
    walkAnimation:Destroy()

    -- Spn Arms animation
    local spinArmAnimation = Instance.new("Animation")
    spinArmAnimation.AnimationId = Wamuu_Mob.Animations.SpinArmsAttack
    mobData.Animations.SpinArmsAttack = animator:LoadAnimation(spinArmAnimation)
    spinArmAnimation:Destroy()

    -- attack animations
    for index, animationId in pairs(Wamuu_Mob.Animations.Attack) do
        local newAnimation = Instance.new("Animation")
        newAnimation.AnimationId = animationId
        local newTrack = animator:LoadAnimation(newAnimation)
        table.insert(mobData.Animations.Attack, newTrack)
        newAnimation:Destroy()
    end

end

--// Setup_Attack
function  Wamuu_Mob.Setup_Attack(mobData)
    -- nothing here. yet ...
end

--// Attack
function  Wamuu_Mob.Attack(mobData)

    spawn(function()



        if not mobData.AttackTarget then return end
        if not mobData.AttackTarget.Character then return end

        local targetHRP = mobData.AttackTarget.Character:FindFirstChild("HumanoidRootPart")
        if not targetHRP then return end

        local mobHRP = mobData.Model:FindFirstChild("HumanoidRootPart")
        if not mobHRP then return end

        local randAttack = math.random(1, 5)
        local distance = (targetHRP.Position - mobHRP.Position).magnitude

        if randAttack == 5 then

            print("SPECIAL ATTACK!")

            local abilityScript = Knit.Shared.MobEffects.WamuuEffects


            if not mobData.DisableAnimations then
                mobData.Animations.SpinArmsAttack:Play()
                mobData.Model.Humanoid.WalkSpeed = mobData.Defs.WalkSpeed + 10
            end

            
            for count = 1, 4 do

                local effectParams = {}
                effectParams.Position = mobHRP.Position
                effectParams.MobModel = mobData.Model                effectParams.RenderRange = 250
                Knit.Services.PowersService:RenderAbilityEffect_AllPlayers(abilityScript, "Tornado", effectParams)

                for _, player in pairs(game.Players:GetPlayers()) do
                    if player.Character and player.Character.HumanoidRootPart then
                        local distance = (player.Character.HumanoidRootPart.Position - mobHRP.Position).magnitude
                        if distance <= 8 then
                            local newLookVector = (player.Character.HumanoidRootPart.Position - mobHRP.Position).unit
                            local hitEffects = {Damage = {Damage = 10}, KnockBack = {Force = 70, ForceY = 50, LookVector = newLookVector}}
        
                            Knit.Services.MobService:HitPlayer(player, hitEffects)
                        end
                    end
                end
                wait(.5)
            end
            
            mobData.Model.Humanoid.WalkSpeed = mobData.Defs.WalkSpeed
            mobData.Animations.SpinArmsAttack:Stop()

        else

            if not mobData.DisableAnimations then
                local rand = math.random(1, #mobData.Animations.Attack)
                mobData.Animations.Attack[rand]:Play()
            end


            local HitEffects_Attack = {Damage = {Damage = 20}}
            Knit.Services.MobService:HitPlayer(mobData.AttackTarget, HitEffects_Attack)
        end

    end) 
                               
end

--// Setup_Death
function Wamuu_Mob.Setup_Death(mobData)
    -- nothing here, yet ...
end

--// Death
function Wamuu_Mob.Death(mobData)

    spawn(function()
        mobData.Model.HumanoidRootPart.ParticleEmitter.Rate = 1000
        wait(.1)
        mobData.Model.HumanoidRootPart.ParticleEmitter.Rate = 5
    end)
end

--// Setup_Drop
function Wamuu_Mob.Setup_Drop(mobData)
    -- nothing here, yet ...
end

--// Drop
function Wamuu_Mob.Drop(player, mobData)

    local rewards = {}
    rewards.Items = {}

    local itemDropPercent = 75
    local rand = math.random(1, 100)
    if rand <= itemDropPercent then
        rewards.Items["Antidote"] = 1
    end

    rewards.XP = Wamuu_Mob.Defs.XpValue
    rewards.SoulOrbs = 1

    return rewards
    
end



return Wamuu_Mob