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


local Immunity = {}

--// Entry_Added -- fires after entry added in StateSerive. Can be blank.
function Immunity.Entry_Added(player,thisEntry,params)

end

--// Entry_Removed -- fires after entry added in StateSerive. Can be blank.
function Immunity.Entry_Removed(player, thisState, params)

end

--// Has-Immunity - returns true if the player has an true entry equal to the name passed
function Immunity.Has_Immunity(player,immunityName)

    local playerFolder = statesFolder:FindFirstChild(player.UserId)
    local immunityFolder = playerFolder:FindFirstChild("Immunity")

    local isImmune = false
    for _,stateEntry in pairs(immunityFolder:GetChildren()) do
        if stateEntry.Name == immunityName then
            isImmune = true
            break
        end
    end

    return isImmune
end

return Immunity