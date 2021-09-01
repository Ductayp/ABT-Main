
-- Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))


local module = {}

--/ Spawners
module.SpawnersFolder = Workspace:FindFirstChild("MobSpawners_DioBrando", true)

--/ Model
module.Model = ReplicatedStorage.Mobs.DioBrando

--/ Spawn
module.RespawnClock = os.clock()
module.RespawnTime = 60
module.RandomPlacement = true
module.Spawn_Y_Offset = 5
module.Max_Spawned = 1

--/ Animations
module.Animations = {
    Idle = "rbxassetid://507766666",
    Walk = "rbxassetid://507777826",
    Attack = {"rbxassetid://6235460206", "rbxassetid://6235479125"},
    FreezeAttack = "rbxassetid://6659001527",
    Rage = "rbxassetid://6782535195"
}

module.Defs = {}
module.Defs.Name = "Dio Brando"
module.Defs.MapZone = "DiosCrypt"
module.Defs.XpValue = 350
module.Defs.Health = 425
module.Defs.WalkSpeed = 22
module.Defs.JumpPower = 50
module.Defs.Aggressive = true
module.Defs.AttackSpeed = 2
module.Defs.AttackRange = 50
module.Defs.SeekRange = 70 -- In Studs
module.Defs.ChaseRange = 70 -- In Studs
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

        mobData.CanFreeze = true
        mobData.CanLaser = true
        mobData.CanPunch = true

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

    -- Freeze Attack
    local freezeAnimation = Instance.new("Animation")
    freezeAnimation.AnimationId = module.Animations.FreezeAttack
    mobData.Animations.FreezeAttack = animator:LoadAnimation(freezeAnimation)
    freezeAnimation:Destroy()

    -- Freeze Attack
    local rageAnimation = Instance.new("Animation")
    rageAnimation.AnimationId = module.Animations.Rage
    mobData.Animations.Rage = animator:LoadAnimation(rageAnimation)
    rageAnimation:Destroy()

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

        local targetHRP = mobData.AttackTarget.Character:FindFirstChild("HumanoidRootPart")
        if not targetHRP then return end

        local mobHRP = mobData.Model:FindFirstChild("HumanoidRootPart")
        if not mobHRP then return end

        local distance = (targetHRP.Position - mobHRP.Position).magnitude

        if mobData.CanFreeze and distance > 5 and distance <= 30 then

            local projectileCooldown = mobData.Model:FindFirstChild("ProjectileCooldown")
            if projectileCooldown then return end

            local newCooldown = Instance.new("BoolValue")
            newCooldown.Name = "ProjectileCooldown"
            newCooldown.Parent = mobData.Model
            spawn(function()
                wait(3)
                newCooldown:Destroy()
            end)

            spawn(function()
                mobData.CanFreeze = false
                wait(15)
                mobData.CanFreeze = true
            end)

            spawn(function()
                if not mobData.DisableAnimations then
                    mobData.Animations.FreezeAttack:Play()
                    mobData.Model.Humanoid.WalkSpeed = 0
                    wait(1.5)
                    mobData.Animations.FreezeAttack:Stop()
                    mobData.Model.Humanoid.WalkSpeed = module.Defs.WalkSpeed
                end
            end)

            local abilityScript = Knit.Shared.MobEffects.DioEffects
            local effectParams = {}
            effectParams.MobData = mobData 
            effectParams.HitCharacter = mobData.AttackTarget.Character        
            effectParams.RenderRange = 250
            Knit.Services.PowersService:RenderAbilityEffect_AllPlayers(abilityScript, "Freeze", effectParams)

            local hitEffects = {Damage = {Damage = 15}, PinCharacter = {Duration = 2}, IceBlock = {Duration = 2}}
            Knit.Services.MobService:HitPlayer(mobData.AttackTarget, hitEffects, mobData)

            return

        elseif mobData.CanLaser and distance > 20 then

            local projectileCooldown = mobData.Model:FindFirstChild("ProjectileCooldown")
            if projectileCooldown then return end

            local newCooldown = Instance.new("BoolValue")
            newCooldown.Name = "ProjectileCooldown"
            newCooldown.Parent = mobData.Model
            spawn(function()
                wait(3)
                newCooldown:Destroy()
            end)

            spawn(function()
                mobData.CanLaser = false
                wait(15)
                mobData.CanLaser = true
            end)

            spawn(function()
                if not mobData.DisableAnimations then
                    mobData.Animations.Rage:Play()
                    mobData.Model.Humanoid.WalkSpeed = 0
                    wait(1)
                    mobData.Animations.Rage:Stop()
                    mobData.Model.Humanoid.WalkSpeed = module.Defs.WalkSpeed
                end
            end)

            local abilityScript = Knit.Shared.MobEffects.DioEffects
            local effectParams = {}
            effectParams.MobData = mobData 
            effectParams.HitCharacter = mobData.AttackTarget.Character                  
            effectParams.RenderRange = 250
            Knit.Services.PowersService:RenderAbilityEffect_AllPlayers(abilityScript, "Laser", effectParams)

            local hitEffects = {Damage = {Damage = 20}}
            Knit.Services.MobService:HitPlayer(mobData.AttackTarget, hitEffects, mobData)

            return

        elseif mobData.CanPunch and distance < 3 then

            spawn(function()
                mobData.CanPunch = false
                wait(2)
                mobData.CanPunch = true
            end)

            if not mobData.DisableAnimations then
                local rand = math.random(1, #mobData.Animations.Attack)
                mobData.Animations.Attack[rand]:Play()
            end

            local hitEffects = {Damage = {Damage = 35}}
            Knit.Services.MobService:HitPlayer(mobData.AttackTarget, hitEffects, mobData)

            return

        end

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

    local itemDropPercent = 10
    local rand = math.random(1, 100)
    if rand <= itemDropPercent then

        if rand <= 2 then
            rewards.Items["DiosBone"] = 1
        else
            rewards.Items["GoldStar"] = 1
        end
        
    end


    rewards.XP = module.Defs.XpValue
    rewards.SoulOrbs = 1

    return rewards
    
end



return module