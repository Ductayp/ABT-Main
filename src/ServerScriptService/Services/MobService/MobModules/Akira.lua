-- Akira_Mob

-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local Akira_Mob = {}

--/ Spawners
Akira_Mob.SpawnersFolder = Workspace:FindFirstChild("MobSpawners_Akira", true)

--/ Model
Akira_Mob.Model = ReplicatedStorage.Mobs.Akira_Mob

--/ Spawn
Akira_Mob.RespawnClock = os.clock()
Akira_Mob.RespawnTime = 10
Akira_Mob.RandomPlacement = true
Akira_Mob.Spawn_Z_Offset = 5
Akira_Mob.Max_Spawned = 4

--/ Animations
Akira_Mob.Animations = {
    Idle = "rbxassetid://507766666",
    Walk = "rbxassetid://507777826",
    Attack = {"rbxassetid://6235460206", "rbxassetid://6235479125"},
    GuitarAttack = "rbxassetid://6905847408"
}

Akira_Mob.Defs = {}
Akira_Mob.Defs.Name = "Akira"
Akira_Mob.Defs.MapZone = "DuwangHarbor"
Akira_Mob.Defs.XpValue = 175
Akira_Mob.Defs.Health = 175
Akira_Mob.Defs.WalkSpeed = 20
Akira_Mob.Defs.JumpPower = 50
Akira_Mob.Defs.Aggressive = true
Akira_Mob.Defs.AttackSpeed = 4
Akira_Mob.Defs.AttackRange = 15
Akira_Mob.Defs.Special_LastAttack = os.clock()
Akira_Mob.Defs.SeekRange = 50 -- In Studs
Akira_Mob.Defs.ChaseRange = 60 -- In Studs
Akira_Mob.Defs.IsMobile = true
Akira_Mob.Defs.LifeSpan = 600 -- number of seconds it will live, get killed when the time is up

--/ Spawn Function
function Akira_Mob.Pre_Spawn(mobData)

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
function Akira_Mob.Post_Spawn(mobData)
    
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
                elseif instance:FindFirstChild("Transparent", true) then
                    instance.Transparency = 1
                else
                    instance.Transparency = 0
                end
            end
        end
    end)
end

--// Setup_Animations
function Akira_Mob.Setup_Animations(mobData)

    -- add an animator
    mobData.Animations = {} -- setup a table
    mobData.Animations.Attack = {} -- we need another table for attack aniamtions
    local animator = Instance.new("Animator")
    animator.Parent = mobData.Model.Humanoid

    -- idle animation
    local idleAnimation = Instance.new("Animation")
    idleAnimation.AnimationId = Akira_Mob.Animations.Idle
    mobData.Animations.Idle = animator:LoadAnimation(idleAnimation)
    idleAnimation:Destroy()

    -- walk animation
    local walkAnimation = Instance.new("Animation")
    walkAnimation.AnimationId = Akira_Mob.Animations.Walk
    mobData.Animations.Walk = animator:LoadAnimation(walkAnimation)
    walkAnimation:Destroy()

    -- Spn Arms animation
    local guitarAnimation = Instance.new("Animation")
    guitarAnimation.AnimationId = Akira_Mob.Animations.GuitarAttack
    mobData.Animations.GuitarAttack = animator:LoadAnimation(guitarAnimation)
    guitarAnimation:Destroy()

    -- attack animations
    for index, animationId in pairs(Akira_Mob.Animations.Attack) do
        local newAnimation = Instance.new("Animation")
        newAnimation.AnimationId = animationId
        local newTrack = animator:LoadAnimation(newAnimation)
        table.insert(mobData.Animations.Attack, newTrack)
        newAnimation:Destroy()
    end

end

--// Setup_Attack
function  Akira_Mob.Setup_Attack(mobData)
    -- nothing here. yet ...
end

--// Attack
function  Akira_Mob.Attack(mobData)

    spawn(function()

        if not mobData.AttackTarget then return end
        if not mobData.AttackTarget.Character then return end

        --local targetHRP = mobData.AttackTarget.Character:FindFirstChild("HumanoidRootPart")
        --if not targetHRP then return end

        local mobHRP = mobData.Model:FindFirstChild("HumanoidRootPart")
        if not mobHRP then return end

        mobData.Model.Humanoid.WalkSpeed = 0
        mobData.Animations.GuitarAttack:Play()

        local hitCharacters = {}
        for _, player in pairs(game.Players:GetPlayers()) do
            if player.Character and player.Character.HumanoidRootPart then
                local distance = (player.Character.HumanoidRootPart.Position - mobHRP.Position).magnitude
                if distance <= Akira_Mob.Defs.AttackRange then

                    table.insert(hitCharacters, player.Character)

                    local hitEffects = {Damage = {Damage = 10}, Slow = {WalkSpeed = 5, Duration = 2}}
                    Knit.Services.MobService:HitPlayer(player, hitEffects)
                end
            end
        end
        
        -- attack animation
        local abilityScript = Knit.Shared.MobEffects.AkiraEffects
        local effectParams = {}
        effectParams.HitCharacters = hitCharacters
        effectParams.Position = mobHRP.Position
        effectParams.MobModel = mobData.Model
        effectParams.AttackTarget = mobData.AttackTarget              
        effectParams.RenderRange = 250
        Knit.Services.PowersService:RenderAbilityEffect_AllPlayers(abilityScript, "SoundWaves", effectParams)

        wait(2)

        mobData.Model.Humanoid.WalkSpeed = mobData.Defs.WalkSpeed
        mobData.Animations.GuitarAttack:Stop()


    end) 
                               
end

--// Setup_Death
function Akira_Mob.Setup_Death(mobData)
    -- nothing here, yet ...
end

--// Death
function Akira_Mob.Death(mobData)

    --[[
    spawn(function()
        mobData.Model.HumanoidRootPart.ParticleEmitter.Rate = 1000
        wait(.1)
        mobData.Model.HumanoidRootPart.ParticleEmitter.Rate = 0
    end)
    ]]--
end

--// Setup_Drop
function Akira_Mob.Setup_Drop(mobData)
    -- nothing here, yet ...
end

--// Drop
function Akira_Mob.Drop(player, mobData)


    local rewards = {}
    rewards.Items = {}

    local itemDropPercent = 50
    local rand = math.random(1, 100)
    if rand <= itemDropPercent then
        local newRand = math.random(1, 5)
        rewards.Items["BrokenArrow"] = newRand
    end
    

    rewards.XP = Akira_Mob.Defs.XpValue
    rewards.SoulOrbs = 1

    return rewards
    
end



return Akira_Mob