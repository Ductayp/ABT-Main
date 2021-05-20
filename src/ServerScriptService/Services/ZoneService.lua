-- Zone Service

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

-- Zone: SwimZone
local swimZoneGroup = Workspace.ZoneServiceGroups.SwimZone -- A container (i.e. Model or Folder) of parts that represent the zone
local swimZone = Zone.new(swimZoneGroup)

-- Zone: FireDamage
local fireZoneGroup = Workspace.ZoneServiceGroups.FireZone -- A container (i.e. Model or Folder) of parts that represent the zone
local fireZone = Zone.new(fireZoneGroup)

---------------------------------------------------------

safeZone.playerEntered:Connect(function(player)
    --print(("%s entered the zone!"):format(player.Name))
    Knit.Services.StateService:AddEntryToState(player, "Invulnerable", "ZoneService", true)
end)

safeZone.playerExited:Connect(function(player)
    --print(("%s exited the zone!"):format(player.Name))
    Knit.Services.StateService:RemoveEntryFromState(player, "Invulnerable", "ZoneService", true)
end)

storageZone.playerEntered:Connect(function(player)
    --print(("%s entered the zone!"):format(player.Name))
    Knit.Services.GuiService:Update_Gui(player, "StoragePanel_Access")
end)

storageZone.playerExited:Connect(function(player)
    --print(("%s exited the zone!"):format(player.Name))
    Knit.Services.GuiService:Update_Gui(player, "StoragePanel_Access")
end)

swimZone.playerEntered:Connect(function(player)
    --print(("%s entered the SWIM zone!"):format(player.Name))
    Knit.Services.EnvironmentService:SwimToggle(player, true)
end)

swimZone.playerExited:Connect(function(player)
    --print(("%s exited the SWIM zone!"):format(player.Name))
    Knit.Services.EnvironmentService:SwimToggle(player, false)
end)

fireZone.playerEntered:Connect(function(player)
    --print(("%s entered the FIRE zone!"):format(player.Name))
    Knit.Services.EnvironmentService:TogglePlayerInZone(player, "FireZone", true)
end)

fireZone.playerExited:Connect(function(player)
    --print(("%s exited the FIRE zone!"):format(player.Name))
    Knit.Services.EnvironmentService:TogglePlayerInZone(player, "FireZone", false)
end)



--// 
function ZoneService:IsPlayerInZone(player, zoneName)

    local ValidZoneNames = {
       ["SafeZone"] = safeZone,
       ["StorageZone"] = storageZone,
       ["SwimZone"] = swimZone,
       ["FireZone"] = fireZone,
    }

    local isInZone = false -- default returns false

    local thisZone = ValidZoneNames[zoneName]
    if thisZone then
        isInZone = thisZone:findPlayer(player)
    end

    return isInZone
end

--// PlayerAdded
function ZoneService:PlayerAdded(player)

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