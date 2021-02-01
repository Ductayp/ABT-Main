-- Game Pass State
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


local GamePass = {}

--// Entry_Added -- fires after entry added in StateSerive. Can be blank.
function GamePass.Entry_Added(player,thisEntry,params)

end

--// Entry_Removed -- fires after entry added in StateSerive. Can be blank.
function GamePass.Entry_Removed(player, thisState, params)

end

function GamePass.Has_Pass(player,passName)

    local hasPass = false

    local playerFolder = statesFolder:FindFirstChild(player.UserId)
    if playerFolder then
        local gamePassFolder = playerFolder:FindFirstChild("GamePass")
        if gamePassFolder then
            local gamePassEntry = gamePassFolder:FindFirstChild(passName)
            if gamePassEntry then
                if gamePassEntry.Value == true then
                    hasPass = true
                end
            end
        end
    end

    return hasPass

end


return GamePass