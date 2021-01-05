-- Standless
-- PDab
-- 11/12/2020
--[[
Handles all thing related to the power and is triggered by BOTH PowersController AND PowerService
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)


local Standless = {}

Standless.Defs = {
    PowerName = "Standless",
    BaseSacrificeValue = 0,
}

--// MANAGER - this is the single point of entry from PowerService.
function Standless.Manager(initPlayer,params)
    print("You are Standless")
    params.CanRun = false

    return params
end


return Standless