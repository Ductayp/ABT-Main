-- module

-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))


local module = {}

--/ Spawners
module.SpawnersFolder = Workspace:FindFirstChild("MobSpawners_RedHot", true)

local animationFolder = ReplicatedStorage:FindFirstChild("MobAnimations", true)

--/ Model
module.Model = ReplicatedStorage.Mobs.RedHot

--/ Spawn
module.RespawnClock = os.clock()
module.RespawnTime = 5
module.RandomPlacement = false
module.Spawn_Z_Offset = 0
module.Max_Spawned = 1


--/ Defs
module.Defs = {}
module.Defs.Name = "Hot Tamale"
module.Defs.MapZone = "DuwangHarbor"
module.Defs.XpValue = 275
module.Defs.Health = 375
module.Defs.WalkSpeed = 0
module.Defs.JumpPower = 50
module.Defs.Aggressive = true
module.Defs.AttackSpeed = 1
module.Defs.AttackRange = 15
module.Defs.HitEffects = {Damage = {Damage = 20}}
module.Defs.SeekRange = 60 -- In Studs
module.Defs.ChaseRange = 5 -- In Studs
module.Defs.IsMobile = false
module.Defs.LifeSpan = 120 -- how long the mob lives before resapwn, in seconds

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

    local antiTeleport = Instance.new("BoolValue")
    antiTeleport.Name = "DisableTeleport"
    antiTeleport.Value = true
    antiTeleport.Parent = mobData.Model.Humanoid

end

--/ Spawn Function
function module.Post_Spawn(mobData)

    mobData.Model.HumanoidRootPart.Anchored = true

    mobData.Model.HumanoidRootPart.SpawnEmitter:Emit(200)

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

    mobData.Active = true
    

end

--// Setup_Animations
function module.Setup_Animations(mobData)

    local animator = Instance.new("Animator")
    animator.Parent = mobData.Model.Humanoid

    mobData.Animations = {}

    for _, animObject in pairs(animationFolder:GetChildren()) do
        mobData.Animations[animObject.Name] = animator:LoadAnimation(animObject)
    end
    
end

--// Setup_Attack
function  module.Setup_Attack(mobData)
    -- nothing here. yet ...
end

--// Attack
function  module.Attack(mobData)

    if not mobData.AttackTarget then return end
    if not mobData.AttackTarget.Character then return end

    local mobHRP = mobData.Model:FindFirstChild("HumanoidRootPart")
    if not mobHRP then return end

    local effectScript = Knit.Shared.MobEffects.RedHotEffects
    local effectParams = {}
    effectParams.Position = mobHRP.Position
    effectParams.MobModel = mobData.Model                
    effectParams.RenderRange = 250
    Knit.Services.PowersService:RenderAbilityEffect_AllPlayers(effectScript, "ElectroBall", effectParams)

    spawn(function()

        for _, player in pairs(game.Players:GetPlayers()) do
            if player.Character and player.Character.HumanoidRootPart then
                local distance = (player.Character.HumanoidRootPart.Position - mobHRP.Position).magnitude
                if distance <= module.Defs.AttackRange then

                    local hitEffects = {Damage = {Damage = 5}}
                    Knit.Services.MobService:HitPlayer(player, hitEffects, mobData)
                end
            end
        end

    end)                          
end

--// Setup_Death
function module.Setup_Death(mobData)
    -- nothing here, yet ...
end

--// Death
function module.Death(mobData)


end

function module.DeSpawn(mobData)

    mobData.Model.HumanoidRootPart.SpawnEmitter:Emit(200)

    -- make everything trasnparent for the spawn
    for _,instance in pairs(mobData.Model:GetDescendants()) do

        if instance:IsA("BasePart") then
            instance.Transparency = 1
        end

        if instance:IsA("ParticleEmitter") then
            instance.Enabled = false
        end

        if instance:IsA("Beam") then
            instance.Enabled = false
        end

        if instance:IsA("Decal") then
            instance:Destroy()
        end
    end

    --wait(3)

end

--// Setup_Drop
function module.Setup_Drop(mobData)

end

--// Drop
function module.Drop(player, mobData)

    local rewards = {}
    rewards.Items = {}

    local itemDropPercent = 5
    local rand = math.random(1, 100)
    if rand <= itemDropPercent then
        rewards.Items["GoldStar"] = 1
    end

    rewards.Items["BrokenArrow"] = math.random(1, 10)
    rewards.XP = module.Defs.XpValue
    rewards.SoulOrbs = 1

    return rewards
end



return module