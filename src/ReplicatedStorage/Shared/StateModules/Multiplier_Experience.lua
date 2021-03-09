-- Double Xp
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

local Multiplier_Experience = {}

--// Entry_Added -- fires after entry added in StateSerive. Can be blank.
function Multiplier_Experience.Entry_Added(player, thisEntry, params, duplicateEntry)

end

--// Entry_Removed -- fires after entry added in StateSerive. Can be blank.
function Multiplier_Experience.Entry_Removed(player, thisState)

end

function Multiplier_Experience.GetTotalMultiplier(player)

    local totalMultiplier = 0
    local playerFolder = statesFolder:FindFirstChild(player.UserId)
    if playerFolder then
       local Multiplier_ExperienceFolder = playerFolder:FindFirstChild("Multiplier_Experience")
        if Multiplier_ExperienceFolder then
            for _,entry in pairs(Multiplier_ExperienceFolder:GetChildren()) do
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

return Multiplier_Experience