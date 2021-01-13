-- Morioh_Gang Mob
-- Pdab
-- 1/10/21

-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local Morioh_Gang = {}

--/ Model
Morioh_Gang.Model = ReplicatedStorage.Mobs.Morioh_Gang

--/ Xp
Morioh_Gang.XpValue = 500

--/ Humanoid Settings
Morioh_Gang.Health = 100
Morioh_Gang.WalkSpeed = 16
Morioh_Gang.JumpPower = 50

--/ Damage Data
Morioh_Gang.Damage = 10
Morioh_Gang.AttackSpeed = 2
Morioh_Gang.AttackRange = 3

--/ Agression Chase Behavior
Morioh_Gang.Agressive = false
Morioh_Gang.SeekRange = 60 -- In Studs
Morioh_Gang.ChaseRange = 80 -- In Studs

--/ Spawn
Morioh_Gang.RespawnTime = 10
Morioh_Gang.MaxSpawned = 2 -- Quantity of Spawns Per Spawner

--/ Animations
Morioh_Gang.Animations = {
    Idle = "rbxassetid://507766666",
    Walk = "rbxassetid://507777826",
    Attack = {"rbxassetid://6235460206", "rbxassetid://6235479125"},
}


return Morioh_Gang