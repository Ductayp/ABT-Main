-- RedHot_Mob

-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))


local RedHot_Mob = {}

--/ Spawners
RedHot_Mob.SpawnersFolder = Workspace:FindFirstChild("MobSpawners_RedHot", true)

--/ Model
RedHot_Mob.Model = ReplicatedStorage.Mobs.RedHot

--/ Spawn
RedHot_Mob.RespawnClock = os.clock()
RedHot_Mob.RespawnTime = 5
RedHot_Mob.RandomPlacement = false
RedHot_Mob.Spawn_Z_Offset = 0
RedHot_Mob.Max_Spawned = 1

--/ Animations
RedHot_Mob.Animations = {
    Idle = "rbxassetid://507766666",
    Walk = "rbxassetid://507777826",
    Attack = {"rbxassetid://6245847704"},
}

--/ Defs
RedHot_Mob.Defs = {}
RedHot_Mob.Defs.Name = "Hot Tamale"
RedHot_Mob.Defs.MapZone = "DuwangHarbor"
RedHot_Mob.Defs.XpValue = 250
RedHot_Mob.Defs.Health = 200
RedHot_Mob.Defs.WalkSpeed = 0
RedHot_Mob.Defs.JumpPower = 50
RedHot_Mob.Defs.Aggressive = true
RedHot_Mob.Defs.AttackSpeed = 1
RedHot_Mob.Defs.AttackRange = 15
RedHot_Mob.Defs.HitEffects = {Damage = {Damage = 20}}
RedHot_Mob.Defs.SeekRange = 60 -- In Studs
RedHot_Mob.Defs.ChaseRange = 5 -- In Studs
RedHot_Mob.Defs.IsMobile = false
RedHot_Mob.Defs.LifeSpan = 60 -- how long the mob lives before resapwn, in seconds

--/ Spawn Function
function RedHot_Mob.Pre_Spawn(mobData)

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
function RedHot_Mob.Post_Spawn(mobData)

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
function RedHot_Mob.Setup_Animations(mobData)

        -- add an animator
        mobData.Animations = {} -- setup a table
        mobData.Animations.Attack = {} -- we need another table for attack aniamtions
        local animator = Instance.new("Animator")
        animator.Parent = mobData.Model.Humanoid
    
        -- idle animation
        local idleAnimation = Instance.new("Animation")
        idleAnimation.AnimationId = RedHot_Mob.Animations.Idle
        mobData.Animations.Idle = animator:LoadAnimation(idleAnimation)
        idleAnimation:Destroy()
    
        -- walk animation
        local walkAnimation = Instance.new("Animation")
        walkAnimation.AnimationId = RedHot_Mob.Animations.Walk
        mobData.Animations.Walk = animator:LoadAnimation(walkAnimation)
        walkAnimation:Destroy()
    
        -- attack animations
        for index, animationId in pairs(RedHot_Mob.Animations.Attack) do
            local newAnimation = Instance.new("Animation")
            newAnimation.AnimationId = animationId
            local newTrack = animator:LoadAnimation(newAnimation)
            table.insert(mobData.Animations.Attack, newTrack)
            newAnimation:Destroy()
        end

end

--// Setup_Attack
function  RedHot_Mob.Setup_Attack(mobData)
    -- nothing here. yet ...
end

--// Attack
function  RedHot_Mob.Attack(mobData)

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
                if distance <= RedHot_Mob.Defs.AttackRange then

                    local hitEffects = {Damage = {Damage = 10}}
                    Knit.Services.MobService:HitPlayer(player, hitEffects)
                end
            end
        end

    end)                          
end

--// Setup_Death
function RedHot_Mob.Setup_Death(mobData)
    -- nothing here, yet ...
end

--// Death
function RedHot_Mob.Death(mobData)


end

function RedHot_Mob.DeSpawn(mobData)

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
function RedHot_Mob.Setup_Drop(mobData)

end

--// Drop
function RedHot_Mob.Drop(player, mobData)

    local rewards = {}
    rewards.Items = {}

    --[[
    local itemDropPercent = 25
    local rand = math.random(1, 100)
    if rand <= itemDropPercent then
        rewards.Items["BrokenArrow"] = 10
    end
    ]]--

    rewards.Items["BrokenArrow"] = math.random(1, 10)
    rewards.XP = RedHot_Mob.Defs.XpValue
    rewards.SoulOrbs = 10

    return rewards
end



return RedHot_Mob