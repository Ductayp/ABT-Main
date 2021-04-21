-- Health State module
-- PDab
-- 12-5-2020

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local statesFolder = ReplicatedStorage:FindFirstChild("StateService")

-- Constants
local DEFAULT_HEALTH = 100

local Health = {}

--// AddState - fires after AddState from 
function Health.Entry_Added(player, thisEntry, params, duplicateEntry)

    local newMaxHealth = DEFAULT_HEALTH -- start with the default and then add the modifers
    local playerFolder = statesFolder:FindFirstChild(player.UserId)
    if playerFolder then
        local healthFolder = playerFolder:FindFirstChild("Health")
        for _,valueObject in pairs(healthFolder:GetChildren()) do
            newMaxHealth = newMaxHealth + valueObject.Value
        end
    end


    local humanoid = player.Character:WaitForChild("Humanoid")
    humanoid.MaxHealth = newMaxHealth
    if humanoid.Health > humanoid.MaxHealth then
        humanoid.Health = humanoid.MaxHealth
    end
 
end

--// RemoveEntry - fires after RemoveEntry from 
function Health.Entry_Removed(player, thisState)

    local newMaxHealth = DEFAULT_HEALTH -- start with the default and then add the modifers
    for _,valueObject in pairs(thisState:GetChildren()) do
        newMaxHealth = newMaxHealth + valueObject.Value
    end

    local humanoid = player.Character:WaitForChild("Humanoid")
    humanoid.MaxHealth = newMaxHealth

end

--// GetMaxHealth
function Health.GetMaxHealth(player, params)

    local maxHealth = DEFAULT_HEALTH
    local healthState = ReplicatedStorage.StateService[player.UserId]:FindFirstChild("Health")
    if healthState then
        for _,valueObject in pairs(healthState:GetChildren()) do
            maxHealth = maxHealth + valueObject.Value
        end
    else
        print("No STATES or MODIFIERS found for walkspeed, giving the default value")
    end

    return maxHealth
end






return Health