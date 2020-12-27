-- Walk Speed Effect
-- PDab
-- 12-5-2020

-- tracks player actual walkspeed based on any number of modifiers.
-- Also has function to modify the players walkspeed and restore it, as well as visual effects

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)

-- Constants
local DEFAULT_WALKSPEED = 16

local WalkSpeed = {}

--// AddState - fires after AddState from 
function WalkSpeed.Entry_Added(player,thisEntry,params)

    local newWalkSpeed = DEFAULT_WALKSPEED -- start with the default and then add the modifers
    for _,valueObject in pairs(thisEntry.Parent:GetChildren()) do
        newWalkSpeed = newWalkSpeed + valueObject.Value
    end

    player.Character.Humanoid.WalkSpeed = newWalkSpeed

end

--// RemoveEntry - fires after RemoveEntry from 
function WalkSpeed.Entry_Removed(player, thisState, params)

    local newWalkSpeed = DEFAULT_WALKSPEED -- start with the default and then add the modifers

    for _,valueObject in pairs(thisState:GetChildren()) do
        newWalkSpeed = newWalkSpeed + valueObject.Value
    end

    player.Character.Humanoid.WalkSpeed = newWalkSpeed
end

--// GetModifiedValue - can be accessed from anywhere, will return DEFUALT_WALKSPEED plus all current modifiers
function WalkSpeed.GetModifiedValue(player, params)

    local totalWalkSpeed = DEFAULT_WALKSPEED -- start with the default and then add the modifers
    local walkSpeedState = ReplicatedStorage.StateService[player.UserId]:FindFirstChild("WalkSpeed")
    if walkSpeedState then
        for _,valueObject in pairs(walkSpeedState:GetChildren()) do
            totalWalkSpeed = totalWalkSpeed + valueObject.Value
        end
    else
        print("No STATES or MODIFIERS found for walkspeed, giving the default value")
    end
    
    return totalWalkSpeed
end

function WalkSpeed.Test()
    print("test BOOPIE!")
end




return WalkSpeed