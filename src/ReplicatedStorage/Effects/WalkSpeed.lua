-- Walk Speed Effect
-- PDab
-- 12-5-2020

-- tracks player actual walkspeed based on any number of modifiers.
-- Also has function to modify the players walkspeed and restore it, as well as visual effects

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)

local defaultWalkSpeed = 16

local WalkSpeed = {}

return WalkSpeed