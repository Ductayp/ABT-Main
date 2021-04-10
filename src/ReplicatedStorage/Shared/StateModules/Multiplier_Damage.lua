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

local Multiplier_Damage = {}

--// Entry_Added -- fires after entry added in StateSerive. Can be blank.
function Multiplier_Damage.Entry_Added(player, thisEntry, params, duplicateEntry)

end

--// Entry_Removed -- fires after entry added in StateSerive. Can be blank.
function Multiplier_Damage.Entry_Removed(player, thisState)

end

function Multiplier_Damage.GetTotalMultiplier(player)

    local totalMultiplier = 0
    local entryCount = 0
    local playerFolder = statesFolder:FindFirstChild(player.UserId)
    if playerFolder then
       local Multiplier_DamageFolder = playerFolder:FindFirstChild("Multiplier_Damage")
        if Multiplier_DamageFolder then
            for _,entry in pairs(Multiplier_DamageFolder:GetChildren()) do

                if entry.Value ~= 1 then
                    entryCount = entryCount + 1
                end
                
                totalMultiplier = totalMultiplier + (entry.Value - 1)
            end
        end
    end

    -- aways return at least 1
    if totalMultiplier == nil or totalMultiplier == 0 then
        totalMultiplier = 1
    end

    totalMultiplier = totalMultiplier + entryCount

    return totalMultiplier
end

return Multiplier_Damage