-- DunegonService

-- services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local DunegonService = Knit.CreateService { Name = "DunegonService", Client = {}}
local RemoteEvent = require(Knit.Util.Remote.RemoteEvent)

-- modules
local utils = require(Knit.Shared.Utils)

--// BuyAccess
function DunegonService:BuyAccess(player, params)
    print("DUNEGON SERVICE", player, params)
      
    local dialogueModule = require(Knit.DialogueModules[params.ModuleName])
    if not dialogueModule then return end
    local transactionDef = dialogueModule.DungeonTravel[params.TransactionKey]
    if not transactionDef then return end

    local inputKey = transactionDef.Input.Key
    local inputValue = transactionDef.Input.Value
    local destination = transactionDef.Destination

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
        self:TravelIntoDunegon(player, destination)
    end

    return success

end

--// TravelIntoDunegon
function DunegonService:TravelIntoDunegon(player, destination)
    print("YOU CAN TRAVEL HOMES!", player, destination)
    Knit.Services.PlayerSpawnService:SetPlayerSpawn(player, destination, false)

    local spawners = require(Knit.Defs.SpawnGroups)

    print("1",destination)
    print("2",require(Knit.Defs.SpawnGroups))

    local spawnerGroup = require(Knit.Defs.SpawnGroups)[destination]:GetChildren()
    local randPick = math.random(1, #spawnerGroup)
    local targetSpawner = spawnerGroup[randPick]

    wait(1)

    if not player then return end

    player.Character.HumanoidRootPart.CFrame = targetSpawner.CFrame

end

---------------------------------------------------------------------------------------------
--// CLIENT METHODS
---------------------------------------------------------------------------------------------

--// Client:StoreStand
function DunegonService.Client:BuyAccess(player, params)
    local results = self.Server:BuyAccess(player, params)
    return results
end


----------------------------------------------------------------------------------------------------------
-- PLAYER/CHARACTER EVENTS
----------------------------------------------------------------------------------------------------------

--// CharacterAdded
function DunegonService:CharacterAdded(player)
    repeat wait() until player.Character
    player.Character:WaitForChild("Humanoid").Died:Connect(function()
        -- nothign yet
    end)
end

--// PlayerAdded
function DunegonService:PlayerAdded(player)

    repeat wait() until player.Character
    self:CharacterAdded(player)
end
 
--// PlayerRemoved
function DunegonService:PlayerRemoved(player)
    --nothign yet
end

----------------------------------------------------------------------------------------------------------
-- KNIT 
----------------------------------------------------------------------------------------------------------

--// KnitStart
function DunegonService:KnitStart()

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
function DunegonService:KnitInit()

end

return DunegonService