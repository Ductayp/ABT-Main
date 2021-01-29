-- Basic Grenade Ability
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
local FastCast = require(KNite.Shared.FastCastRedux)

-- Ability modules
local ManageStand = require(Knit.Abilities.ManageStand)

-- Effect modules
local Damage = require(Knit.Effects.Damage)

local BasicGrenade = {}

--[[
    local castModule = require(script.Parent:WaitForChild("FastCastRedux"))
    local newCast = castModule.new()
    local newCastBhaviour = castModule.newBehaviour()

    newCast:Fire( 
                    bulletOrigin.CFrame.Position,
                    mouse.Hit.Position,
                    Vector3.new(mouse.Hit.Position) * bulletSpeed
                )
]]


function BasicGrenade.Server_Activate(initPlayer,params)

 
    
end

function BasicGrenade.Client_Execute(initPlayer,params)


end

return BasicGrenade


