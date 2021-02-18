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


local Invulnerable = {}

--// Entry_Added -- fires after entry added in StateSerive. Can be blank.
function Invulnerable.Entry_Added(player, thisEntry, params)
    local immuneShield = player.Character.Head:FindFirstChild("InvuneraleShield", true)
    if not immuneShield then
        immuneShield = ReplicatedStorage.EffectParts.StateService.Invulnerable.InvuneraleShield:Clone()
        immuneShield.Parent = player.Character.Head
    end

    immuneShield.Enabled = true
end

--// Entry_Removed -- fires after entry removed in StateSerive. Can be blank.
function Invulnerable.Entry_Removed(player, thisState, params)

    -- if player is no longer invulnerable, turn it off
    if Invulnerable.IsInvulnerable(player) then
        -- do nothing
    else
        local immuneShield = player.Character.Head:FindFirstChild("InvuneraleShield", true)
        if immuneShield then
            immuneShield.Enabled = false
        end
    end

end

function Invulnerable.IsInvulnerable(player)

    local isInvulnerable = false
    local playerFolder = statesFolder:FindFirstChild(player.UserId)
    if playerFolder then
        local stateFolder = playerFolder:FindFirstChild("Invulnerable")
        if stateFolder then
            local entryObjects = stateFolder:GetChildren()
            if entryObjects ~= nil then
                for _,object in pairs(entryObjects) do
                    if object.Value == true then
                        isInvulnerable = true
                        break
                    end
                end
            end
        end
    end

    return isInvulnerable

end


return Invulnerable