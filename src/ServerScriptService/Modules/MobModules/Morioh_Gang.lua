-- Morioh_Gang Mob
-- Pdab
-- 1/10/21

-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local Morioh_Gang = {}

--/ Model
Morioh_Gang.Model = ReplicatedStorage.Mobs.Morioh_Gang

--/ Xp
Morioh_Gang.XpValue = 25

--/ Humanoid Settings
Morioh_Gang.Health = 100
Morioh_Gang.WalkSpeed = 16
Morioh_Gang.JumpPower = 50

--/ Damage Data
Morioh_Gang.Damage = 10
Morioh_Gang.AttackSpeed = 1
Morioh_Gang.AttackRange = 3

--/ Agression Chase Behavior
Morioh_Gang.Agressive = false
Morioh_Gang.SeekRange = 30 -- In Studs
Morioh_Gang.ChaseRange = 100 -- In Studs

--/ Spawn
Morioh_Gang.RespawnTime = 10
Morioh_Gang.MaxSpawned = 2 -- Quantity of Spawns Per Spawner

--/ Animations
Animations = {
    Idle = "rbxassetid://5051775001",
    Walk = "rbxassetid://5051979913",
    Attack = {"rbxassetid://5153989112", "rbxassetid://5153964818", "rbxassetid://5134956506", "rbxassetid://5153991114"},
}


return Morioh_Gang