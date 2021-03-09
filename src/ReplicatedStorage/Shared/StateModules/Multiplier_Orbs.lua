-- Double Cash
-- PDab
-- 1-12-2020

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

-- 
local statesFolder = ReplicatedStorage:FindFirstChild("StateService")

local Multiplier_Orbs = {}

--// Entry_Added -- fires after entry added in StateSerive. Can be blank.
function Multiplier_Orbs.Entry_Added(player, thisEntry, params, duplicateEntry)

end

--// Entry_Removed -- fires after entry added in StateSerive. Can be blank.
function Multiplier_Orbs.Entry_Removed(player, thisState)

end

function Multiplier_Orbs.GetTotalMultiplier(player)

    local totalMultiplier = 0
    local playerFolder = statesFolder:FindFirstChild(player.UserId)
    if playerFolder then
       local Multiplier_OrbsFolder = playerFolder:FindFirstChild("Multiplier_Orbs")
        if Multiplier_OrbsFolder then
            for _,entry in pairs(Multiplier_OrbsFolder:GetChildren()) do
                totalMultiplier = totalMultiplier + entry.Value
            end
        end
    end

    -- aways return at least 1
    if totalMultiplier == nil or totalMultiplier == 0 then
        totalMultiplier = 1
    end
    
    return totalMultiplier
end

return Multiplier_Orbs