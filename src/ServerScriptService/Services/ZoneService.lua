-- Zone Service
-- PDab
-- 12/24/2020

-- services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local ZoneService = Knit.CreateService { Name = "ZoneService", Client = {}}

-- modules
local utils = require(Knit.Shared.Utils)

-- ZonePlus Setup
local ZonePlus = require(4664437268) -- Initiate Zone+
local ZonePlusService = require(ZonePlus.ZoneService) -- Retrieve and require ZoneService

-- Zone: SafeZone
local safeZoneGroup = Workspace.ZoneServiceGroups.SafeZone -- A container (i.e. Model or Folder) of parts that represent the zone
local safeZone = ZonePlusService:createZone("safeZone", safeZoneGroup, 15) -- Construct a zone called 'ZoneName' using 'group' and with an extended height of 15
local playersInSafeZone = safeZone:getPlayers() -- Retrieves an array of players within the zone

--// AddSafeState
function ZoneService:AddSafeState(player)
    Knit.Services.StateService:AddEntryToState(player, "Invulnerable", "ZoneService_SafeZone", true)
end

--// RemoveSafeState
function ZoneService:RemoveSafeState(player)
    Knit.Services.StateService:RemoveEntryFromState(player, "Invulnerable", "ZoneService_SafeZone", true)
end

--// PlayerAdded
function ZoneService:PlayerAdded(player)

    -- safeZone events
    safeZone.playerAdded:Connect(function(player) -- Fires when a player enters the zone
        print(player.Name.." entered: SafeZone")
        self:AddSafeState(player)
    end)
    safeZone.playerRemoving:Connect(function(player)  -- Fires when a player exits the zone
        print(player.Name.." left: SafeZone")
        self:RemoveSafeState(player)
    end)

end

--// PlayerRemoved
function ZoneService:PlayerRemoved(player)

end

--// KnitStart
function ZoneService:KnitStart()

    safeZone:initLoop() -- Initiates loop (default 0.5) which enables the events to work

end

--// KnitInit
function ZoneService:KnitInit()

    -- Player Added event
    Players.PlayerAdded:Connect(function(player)
        self:PlayerAdded(player)
    end)

    -- Player Added event for studio tesing, catches when a player has joined before the server fully starts
    for _, player in ipairs(Players:GetPlayers()) do
        self:PlayerAdded(player)
    end

    -- Player Removing event
    Players.PlayerRemoving:Connect(function(player)
        self:PlayerRemoved(player)
    end)

end


return ZoneService