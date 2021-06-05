-- DungeonService

-- services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local DungeonService = Knit.CreateService { Name = "DungeonService", Client = {}}
local RemoteEvent = require(Knit.Util.Remote.RemoteEvent)

-- modules
local utils = require(Knit.Shared.Utils)

--// BuyAccess
function DungeonService:BuyAccess(player, params)

    print("DUNEGON SERVICE", player, params)
      
    local dialogueModule = require(Knit.DialogueModules[params.ModuleName])
    if not dialogueModule then return end
    local transactionDef = dialogueModule.DungeonTravel[params.TransactionKey]
    if not transactionDef then return end

    local inputKey = transactionDef.Input.Key
    local inputValue = transactionDef.Input.Value
    local spawnName = transactionDef.SpawnName
    local mapZoneId = transactionDef.MapZone

    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    if not playerData then return end

    -- check if player has enough of the input
    local success = false

    if inputKey == "Cash" or inputKey == "SoulOrbs"then
        if playerData.Currency[inputKey] >= inputValue then
            playerData.Currency[inputKey] = playerData.Currency[inputKey] - inputValue
            success = true
        end
    else
        if playerData.ItemInventory[inputKey] >= inputValue then
            playerData.ItemInventory[inputKey] = playerData.ItemInventory[inputKey] - inputValue
            success = true
        end
    end

    if success then
        Knit.Services.GuiService:Update_Gui(player, "Currency")
        Knit.Services.GuiService:Update_Gui(player, "ItemPanel")

        Knit.Services.PlayerSpawnService:SetPlayerSpawn(player, spawnName, false)
        Knit.Services.PlayerSpawnService:TransportToSpawn(player, spawnName)

        local mapZoneParams = {}
        mapZoneParams.MapZone = mapZoneId
        Knit.Services.PlayerUtilityService:SetPlayerMapZone(player, mapZoneParams)
    end

    return success

end

function DungeonService:LeaveDungeon(player, params)

    Knit.Services.PlayerSpawnService:SetPlayerSpawn(player, "Morioh", false)
    Knit.Services.PlayerSpawnService:TransportToSpawn(player, "Morioh")

    local mapZoneParams = {}
    mapZoneParams.MapZone = "Morioh"
    Knit.Services.PlayerUtilityService:SetPlayerMapZone(player, mapZoneParams)

    local success = true
    return success
end


---------------------------------------------------------------------------------------------
--// CLIENT METHODS
---------------------------------------------------------------------------------------------

--// Client:StoreStand
function DungeonService.Client:BuyAccess(player, params)
    local results = self.Server:BuyAccess(player, params)
    return results
end

--// Client:LeaveDungeon
function DungeonService.Client:LeaveDungeon(player, params)
    local results = self.Server:LeaveDungeon(player, params)
    return results
end
----------------------------------------------------------------------------------------------------------
-- PLAYER/CHARACTER EVENTS
----------------------------------------------------------------------------------------------------------

--// CharacterAdded
function DungeonService:CharacterAdded(player)
    repeat wait() until player.Character
    player.Character:WaitForChild("Humanoid").Died:Connect(function()
        -- nothign yet
    end)
end

--// PlayerAdded
function DungeonService:PlayerAdded(player)

    repeat wait() until player.Character
    self:CharacterAdded(player)
end
 
--// PlayerRemoved
function DungeonService:PlayerRemoved(player)
    --nothign yet
end

----------------------------------------------------------------------------------------------------------
-- KNIT 
----------------------------------------------------------------------------------------------------------

--// KnitStart
function DungeonService:KnitStart()

        -- Player Added event
        Players.PlayerAdded:Connect(function(player)
            self:PlayerAdded(player)

            player.CharacterAdded:Connect(function(character)
                self:CharacterAdded(player)
            end)
        end)
    
        -- Player Added event for studio tesing, catches when a player has joined before the server fully starts
        for _, player in ipairs(Players:GetPlayers()) do
            self:PlayerAdded(player)

            player.CharacterAdded:Connect(function(character)
                self:CharacterAdded(player)
            end)
        end
    
        -- Player Removing event
        Players.PlayerRemoving:Connect(function(player)
            self:PlayerRemoved(player)
        end)

end

--// KnitInit
function DungeonService:KnitInit()

end

return DungeonService