-- Safe State
-- PDab
-- 12-26-2020

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

--
local statesFolder = ReplicatedStorage:FindFirstChild("StateService")

local StandStorageAccess = {}

--// Entry_Added -- fires after entry added in StateSerive. Can be blank.
function StandStorageAccess.Entry_Added(player,thisEntry,params)

end

--// Entry_Removed -- fires after entry added in StateSerive. Can be blank.
function StandStorageAccess.Entry_Removed(player, thisState, params)

end


return StandStorageAccess