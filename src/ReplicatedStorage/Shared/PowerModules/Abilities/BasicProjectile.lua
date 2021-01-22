-- Knife Throw Ability
-- PDab
-- 11-27-2020

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

-- Ability modules
local ManageStand = require(Knit.Abilities.ManageStand)

-- Effect modules
local Damage = require(Knit.Effects.Damage)

local BasicProjectile = {}

function BasicProjectile.Server_Activate(initPlayer,params)

    
end

function BasicProjectile.Client_Execute(initPlayer,params)


end

return BasicProjectile


