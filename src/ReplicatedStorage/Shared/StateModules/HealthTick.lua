-- HealthTick State module
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
--local tickTime = 1
--local lastTick = os.clock()

local HealthTick = {}

--// Entry_Added
function HealthTick.Entry_Added(player, thisEntry, params, duplicateEntry)

end

--// Entry_Removed
function HealthTick.Entry_Removed(player, thisState)

end

function HealthTick.OnTick(player)

    local healthModifier = 0

    local playerFolder = statesFolder:FindFirstChild(player.UserId)
    if playerFolder then
        local thisFolder = playerFolder:FindFirstChild("HealthTick")
        for _,valueObject in pairs(thisFolder:GetChildren()) do

            if Knit.Services.EnvironmentService.CurrentCycle == "Day" then
                healthModifier += valueObject.Day.Value
            else 
                healthModifier += valueObject.Night.Value
            end
        end

        
    end

    --print("healthModifier", healthModifier)

    local character = player.Character
    if character and character.Humanoid then
        character.Humanoid.Health += healthModifier
    end

end








return HealthTick