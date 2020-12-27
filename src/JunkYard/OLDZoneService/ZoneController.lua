-- Zone Controller
-- PDab
-- 12/24/2020

-- services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")


-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local ZoneController = Knit.CreateController { Name = "ZoneController" }
local ZoneService = Knit.GetService("ZoneService")

-- Constants
local LOOP_TIME = 1
local ALL_ZONES = {}

-- Variables
local activeZones = {} -- activeZones is a table of zones that has been sent to the server for action

-- Knit modules
local utils = require(Knit.Shared.Utils)

--// CheckZonesLoop
function ZoneController:CheckZonesLoop()

    spawn(function()

        while wait(LOOP_TIME) do

            -- loop through zones in table, if the LocalPlayer is in a zone, add that zone to currenZones
            local currentZones = {} -- this table exists only to compare itself against activeZones
            for zoneName,zoneRegion in pairs(ALL_ZONES) do

                -- find parts in region3
                local foundParts = Workspace:FindPartsInRegion3(zoneRegion, Workspace.GameMap)

                -- check if any parts hit are owned by this player
                for _,part in pairs (foundParts) do
                    if part.Parent:FindFirstChild("Humanoid") then
                        local player = utils.GetPlayerFromCharacter(part.Parent)
                        if player == Players.LocalPlayer then
                            --print(player, "ZoneController - Zone = ",zoneName," LocalPlayer = ", player)
                            currentZones[zoneName] = zoneRegion
                        end
                    end
                end
            end

            -- check is currentZones has any entries
            local currentZones_hasEntry = false
            for _,_ in pairs(currentZones) do
                currentZones_hasEntry = true
                break
            end

            -- check is currentZones has any entries
            local activeZones_hasEntry = false
            for _,_ in pairs(activeZones) do
                activeZones_hasEntry = true
                break
            end

            -- do this if currentZone has entries
            if currentZones_hasEntry == true then

                -- check if we need to add any zones in currentZone into activeZones. Set boolean zoneAdded if we added at least one
                local zoneAdded = false
                for currentZoneName,_ in pairs(currentZones) do
                    local canAdd = true -- check this CurrentZone against all entries in activeZones, if canAdd remains true, then we will add it
                    for activeZoneName,_ in pairs(activeZones) do
                        if currentZoneName == activeZoneName then
                            canAdd = false
                        end
                    end

                    -- if none of the names matched, then canAdd stayed true, lets add it to active zones and set zoneAdded to true
                    if canAdd == true then
                        activeZones[currentZoneName] = true
                        zoneAdded = true
                    end
                end

                -- remove any zones from activeZones that the player is no longer in
                local zoneRemoved = false
                for activeZoneName,_ in pairs(activeZones) do
                    local canRemove = true
                    for currentZoneName,_ in pairs(currentZones) do
                        if currentZoneName == activeZoneName then
                            canRemove = false
                        end
                    end
                    if canRemove == true then
                        activeZoneName = nil
                        zoneRemoved = true
                    end
                end

                -- if either are truem send it tot he server for action
                if zoneRemoved == true or zoneAdded == true then
                    ZoneService:UpdateZonesForPlayer(activeZones)
                end

            else
                -- if currentZones is empty AND theres entries in activeZones, we make activeZones nil and send that to the server
                if activeZones_hasEntry == true then
                    activeZones = {}
                    ZoneService:UpdateZonesForPlayer(activeZones)
                end
            end
        end
    end)
end

--// KnitStart
function ZoneController:KnitStart()

    -- get all the zones fromt he server
    ALL_ZONES = ZoneService:GetAllZones()

    -- run the loop
    self:CheckZonesLoop()
end

--// KnitInit
function ZoneController:KnitInit()

end

return ZoneController