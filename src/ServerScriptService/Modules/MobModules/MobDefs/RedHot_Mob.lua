-- Santana_Mob Mob
-- Pdab
-- 1/10/21

-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))


local Santana_Mob = {}

--/ Model
Santana_Mob.Model = ReplicatedStorage.Mobs.RedHotChiliPepper_TEST

--/ Spawn
Santana_Mob.RespawnTime = 10
Santana_Mob.RandomPlacement = true
Santana_Mob.Spawn_Z_Offset = 0
Santana_Mob.Max_Spawned = 6




Santana_Mob.Defs = {}
Santana_Mob.Defs.XpValue = 500
Santana_Mob.Defs.Health = 100
Santana_Mob.Defs.WalkSpeed = 16
Santana_Mob.Defs.JumpPower = 50
Santana_Mob.Defs.AttackSpeed = 2
Santana_Mob.Defs.AttackRange = 4.5
Santana_Mob.Defs.HitEffects = {Damage = {Damage = 20}}
Santana_Mob.Defs.SeekRange = 60 -- In Studs
Santana_Mob.Defs.ChaseRange = 80 -- In Studs
Santana_Mob.Defs.IsMobile = false

--/ Spawn Function
function Santana_Mob.Pre_Spawn(mobData)

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
function Santana_Mob.Post_Spawn(mobData)

    mobData.Model.HumanoidRootPart.Anchored = true
    
    spawn(function()

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
function Santana_Mob.Setup_Animations(mobData)


end

--// Setup_Attack
function  Santana_Mob.Setup_Attack(mobData)
    -- nothing here. yet ...
end

--// Attack
function  Santana_Mob.Attack(mobData)

    spawn(function()
        mobData.Model.Humanoid.WalkSpeed = 2
        local rand = math.random(1, #mobData.Animations.Attack)
        mobData.Animations.Attack[rand]:Play()
        wait(.25)
        mobData.Model.Humanoid.WalkSpeed = mobData.Defs.WalkSpeed

        Knit.Services.MobService:HitPlayer(mobData.ChaseTarget, mobData.Defs.HitEffects)
    end)  
                               
end

--// Setup_Death
function Santana_Mob.Setup_Death(mobData)
    -- nothing here, yet ...
end

--// Death
function Santana_Mob.Death(mobData)

    spawn(function()
        mobData.Model.HumanoidRootPart.ParticleEmitter.Rate = 1000
        wait(.1)
        mobData.Model.HumanoidRootPart.ParticleEmitter.Rate = 5
    
    end)

end



return Santana_Mob