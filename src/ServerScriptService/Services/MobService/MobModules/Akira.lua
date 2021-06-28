-- module

-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local module = {}

--/ Spawners
module.SpawnersFolder = Workspace:FindFirstChild("MobSpawners_Akira", true)

--/ Model
module.Model = ReplicatedStorage.Mobs.Akira

--/ Spawn
module.RespawnClock = os.clock()
module.RespawnTime = 10
module.RandomPlacement = true
module.Spawn_Z_Offset = 5
module.Max_Spawned = 4

--/ Animations
module.Animations = {
    Idle = "rbxassetid://507766666",
    Walk = "rbxassetid://507777826",
    Attack = {"rbxassetid://6235460206", "rbxassetid://6235479125"},
    GuitarAttack = "rbxassetid://6905847408"
}

module.Defs = {}
module.Defs.Name = "Akira"
module.Defs.MapZone = "DuwangHarbor"
module.Defs.XpValue = 200
module.Defs.Health = 175
module.Defs.WalkSpeed = 20
module.Defs.JumpPower = 50
module.Defs.Aggressive = true
module.Defs.AttackSpeed = 4
module.Defs.AttackRange = 15
module.Defs.Special_LastAttack = os.clock()
module.Defs.SeekRange = 50 -- In Studs
module.Defs.ChaseRange = 60 -- In Studs
module.Defs.IsMobile = true
module.Defs.LifeSpan = 600 -- number of seconds it will live, get killed when the time is up

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

    -- Spn Arms animation
    local guitarAnimation = Instance.new("Animation")
    guitarAnimation.AnimationId = module.Animations.GuitarAttack
    mobData.Animations.GuitarAttack = animator:LoadAnimation(guitarAnimation)
    guitarAnimation:Destroy()

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
                if distance <= module.Defs.AttackRange then

                    table.insert(hitCharacters, player.Character)

                    local hitEffects = {Damage = {Damage = 10}, Slow = {WalkSpeedModifier = -11, Duration = 2}}
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

        mobData.Model.Humanoid.WalkSpeed = require(Knit.MobUtils.MobWalkSpeed).GetWalkSpeed(mobData)
        mobData.Animations.GuitarAttack:Stop()


    end) 
                               
end

--// Setup_Death
function module.Setup_Death(mobData)
    -- nothing here, yet ...
end

--// Death
function module.Death(mobData)

    --[[
    spawn(function()
        mobData.Model.HumanoidRootPart.ParticleEmitter.Rate = 1000
        wait(.1)
        mobData.Model.HumanoidRootPart.ParticleEmitter.Rate = 0
    end)
    ]]--
end

--// Setup_Drop
function module.Setup_Drop(mobData)
    -- nothing here, yet ...
end

--// Drop
function module.Drop(player, mobData)


    local rewards = {}
    rewards.Items = {}

    local itemDropPercent = 50
    local rand = math.random(1, 100)
    if rand <= itemDropPercent then
        local newRand = math.random(1, 5)
        rewards.Items["BrokenArrow"] = newRand
    end
    

    rewards.XP = module.Defs.XpValue
    rewards.SoulOrbs = 1

    return rewards
    
end



return module