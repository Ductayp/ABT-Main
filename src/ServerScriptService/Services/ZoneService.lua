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
local Zone = require(Knit.Shared.Zone)

-- Zone: SafeZone
local safeZoneGroup = Workspace.ZoneServiceGroups.SafeZone -- A container (i.e. Model or Folder) of parts that represent the zone
local safeZone = Zone.new(safeZoneGroup)

-- Zone: StandStorage
local storageZoneGroup = Workspace.ZoneServiceGroups.StandStorage -- A container (i.e. Model or Folder) of parts that represent the zone
local storageZone = Zone.new(storageZoneGroup)

-- Zone: StandStorage
local swimZoneGroup = Workspace.ZoneServiceGroups.SwimZone -- A container (i.e. Model or Folder) of parts that represent the zone
local swimZone = Zone.new(swimZoneGroup)


--// AddSafeState
function ZoneService:AddSafeState(player)
    Knit.Services.StateService:AddEntryToState(player, "Invulnerable", "ZoneService", true)
end

--// RemoveSafeState
function ZoneService:RemoveSafeState(player)
    Knit.Services.StateService:RemoveEntryFromState(player, "Invulnerable", "ZoneService", true)
end

--// AddStorageState
function ZoneService:AddStorageState(player)
    Knit.Services.StateService:AddEntryToState(player, "StandStorageAccess", "ZoneService", true)
end

--// RemoveStorageState
function ZoneService:RemoveStorageState(player)
    Knit.Services.StateService:RemoveEntryFromState(player, "StandStorageAccess", "ZoneService", true)
end

--// PlayerAdded
function ZoneService:PlayerAdded(player)

    safeZone.playerEntered:Connect(function(player)
        --print(("%s entered the zone!"):format(player.Name))
        self:AddSafeState(player)
    end)
    
    safeZone.playerExited:Connect(function(player)
        --print(("%s exited the zone!"):format(player.Name))
        self:RemoveSafeState(player)
    end)

    storageZone.playerEntered:Connect(function(player)
        --print(("%s entered the zone!"):format(player.Name))
        self:AddStorageState(player)
        self:AddSafeState(player)
    end)
    
    storageZone.playerExited:Connect(function(player)
        --print(("%s exited the zone!"):format(player.Name))
        self:RemoveStorageState(player)
        self:RemoveSafeState(player)
    end)

    swimZone.playerEntered:Connect(function(player)
        --print(("%s entered the SWIM zone!"):format(player.Name))
        Knit.Services.PlayerUtilityService:SwimToggle(player, true)
    end)
    
    swimZone.playerExited:Connect(function(player)
        --print(("%s exited the SWIM zone!"):format(player.Name))
        Knit.Services.PlayerUtilityService:SwimToggle(player, false)
    end)

end

--// PlayerRemoved
function ZoneService:PlayerRemoved(player)

end

--// KnitStart
function ZoneService:KnitStart()

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