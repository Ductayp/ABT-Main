-- Basic Grenade Ability
-- PDab
-- 11-27-2020

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
--local Debris = game:GetService("Debris")
--local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local BulletKick = {}

BulletKick.HitEffects = {
    [1] = {Damage = {Damage = 10}},
    [2] = {Damage = {Damage = 10}},
    [3] = {Damage = {Damage = 10}, KnockBack = {Force = 100, Duration = 0.2}}
}


return BulletKick


