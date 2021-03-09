-- ItemFinderAccess
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

local ItemFinderAccess = {}

--// Entry_Added -- fires after entry added in StateSerive. Can be blank.
function ItemFinderAccess.Entry_Added(player, thisEntry, params, duplicateEntry)

--[[
    print("ItemFinderAccess.Entry_Added", player, thisEntry, params, duplicateEntry)
    -- if this is not a new netry, then we need to add the duration to the existing existing
    if duplicateEntry then
        print("DUPLIACTE!")
        local durationObject = thisEntry:FindFirstChild("Duration")
        if durationObject then
            durationObject.Value = durationObject.Value + params.Duration
        end
    end
]]--

    Knit.Services.GuiService:Update_Gui(player, "ItemFinderWindow")
end

--// Entry_Removed -- fires after entry added in StateSerive. Can be blank.
function ItemFinderAccess.Entry_Removed(player, thisState)
    print("REMOVED")
    Knit.Services.GuiService:Update_Gui(player, "ItemFinderWindow")
end

--[[
function ItemFinderAccess.Update_Timers(player, loopTime)

    local thisState = statesFolder[player.UserId].ItemFinderAccess
    for _, entry in pairs(thisState:GetChildren()) do
        if entry:FindFirstChild("Timed") then
            local durationObject = entry:FindFirstChild("Duration")
            if durationObject.Value <= 0 then
                Knit.Services.StateService:RemoveEntryFromState(player, "ItemFinderAccess", entry.Name)
            else
                durationObject.Value = durationObject.Value - loopTime
            end
        end
    end
end
]]--

--// HasAccess
function ItemFinderAccess.HasAccess(player)

    local hasAccess = false
    local fromGamePass = false
    local expirationTime = 0

    local playerFolder = statesFolder:FindFirstChild(player.UserId)
    if playerFolder then
        local thisStateFolder = playerFolder:FindFirstChild("ItemFinderAccess")
        if thisStateFolder then
            local entryObjects = thisStateFolder:GetChildren()
            if entryObjects ~= nil then
                for _,object in pairs(entryObjects) do
                    if object.Value == true then

                        -- set if it was from GamePassService
                        if object.Name == "GamePassService" then
                            fromGamePass = true
                        end

                        -- set hasAccess
                        hasAccess = true
                        
                    end
                end
            end
        end
    end

    return hasAccess, fromGamePass, expirationTime
end


return ItemFinderAccess