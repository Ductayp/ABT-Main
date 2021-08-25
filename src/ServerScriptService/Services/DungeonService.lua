-- DungeonService

-- services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local DungeonService = Knit.CreateService { Name = "DungeonService", Client = {}}
local RemoteEvent = require(Knit.Util.Remote.RemoteEvent)
local utils = require(Knit.Shared.Utils)

local timePerKey = 900 -- 900 seconds equals 15 minutes

--// BuyAccess
function DungeonService:BuyTime(player, dungeonId)

    local success = false
      
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    if not playerData then warn("DungeonService:BuyTime - Player data not found") return end

    if not playerData.ItemInventory.DungeonKey then
        playerData.ItemInventory.DungeonKey = 0
    end

    if not playerData.DungeonTimes then
        playerData.DungeonTimes = {}
    end

    local findModule = Knit.DungeonModules[dungeonId]
    if not findModule then warn("DungeonService:BuyTime - No dungeon module with that name") return end
    local dungeonModule = require(findModule)

    -- check if player has enough of the input
    if playerData.ItemInventory.DungeonKey > 0 then

        if not playerData.DungeonTimes[dungeonId] then playerData.DungeonTimes[dungeonId] = os.time() end

        if playerData.DungeonTimes[dungeonId] < os.time() then 
            playerData.DungeonTimes[dungeonId] = os.time() + timePerKey
        else 
            playerData.DungeonTimes[dungeonId] += timePerKey
        end

        

        playerData.ItemInventory.DungeonKey = playerData.ItemInventory.DungeonKey - 1

        Knit.Services.GuiService:Update_Gui(player, "ItemsWindow")
        Knit.Services.GuiService:Update_Gui(player, "DungeonTimes")

        success = true

    end

    return success

end

--// RequestEnter
function DungeonService:RequestEnter(player, dungeonId)

    local success = false

    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    if not playerData then warn("DungeonService:RequestEnter - Player data not found") return end

    if not playerData.DungeonTimes then
        playerData.DungeonTimes = {}
    end

    if not playerData.DungeonTimes[dungeonId] then
        playerData.DungeonTimes[dungeonId] = os.time() - 1
    end

    if playerData.DungeonTimes[dungeonId] > os.time() then
        success = true
        self:EnterDungeon(player, dungeonId)
    end

    return success

end

--// EnterDungeon
function DungeonService:EnterDungeon(player, dungeonId)

    print("DungeonService:EnterDungeon(player, dungeonId)", player, dungeonId)

    local findModule = Knit.DungeonModules[dungeonId]
    if not findModule then warn("DungeonService:EnterDungeon - No dungeon module with that name") return end
    local dungeonModule = require(findModule)

    local spawnName = dungeonModule.SpawnName

    Knit.Services.PlayerSpawnService:SetPlayerSpawn(player, dungeonId, false)

    local mapZoneParams = {}
    mapZoneParams.MapZone = mapZoneId

    Knit.Services.PlayerUtilityService:SetPlayerMapZone(player, dungeonId)

    spawn(function()
        Knit.Services.PlayerSpawnService:TransportToSpawn(player, dungeonId)
    end)

    Knit.Services.GuiService:ToggleDungeonTimer(player, true, dungeonId)

end

function DungeonService:LeaveDungeon(player)

    Knit.Services.PlayerSpawnService:SetPlayerSpawn(player, "Morioh", false)
    Knit.Services.PlayerUtilityService:SetPlayerMapZone(player, "Morioh")

    spawn(function()
        Knit.Services.PlayerSpawnService:TransportHome(player)
    end)

    Knit.Services.GuiService:ToggleDungeonTimer(player, false)

    local success = true
    return success
end

--// TimerLoop
function DungeonService:TimerLoop()

    local lastUpdate = os.time()

    RunService.Heartbeat:Connect(function(step)
        if lastUpdate < os.time() then
            lastUpdate = os.time()

            for _, player in pairs(Players:GetChildren()) do

                local mapZone =  Knit.Services.PlayerUtilityService:GetPlayerMapZone(player)
                if mapZone ~= "Morioh" then

                    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
                    if playerData then

                        if playerData.DungeonTimes[mapZone] then
                            local dungeonTime = playerData.DungeonTimes[mapZone]
                            if dungeonTime < os.time() then
                                self:LeaveDungeon(player)
                            end
                        end

                    end

                end
            end

        end
    end)

end

---------------------------------------------------------------------------------------------
--// CLIENT METHODS
---------------------------------------------------------------------------------------------

--// Client:BuyAccess
function DungeonService.Client:BuyTime(player, params)
    local results = self.Server:BuyTime(player, params)
    return results
end

--// Client:LeaveDungeon
function DungeonService.Client:RequestEnter(player, dungeonId)
    local results = self.Server:RequestEnter(player, dungeonId)
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
    --[[
    repeat wait() until player.Character
    player.Character:WaitForChild("Humanoid").Died:Connect(function()
        -- nothign yet
    end)
    ]]--
end

--// PlayerAdded
function DungeonService:PlayerAdded(player)

    --DungeonService.PlayerTimes[player.UserId] = {}

    repeat wait() until player.Character
    self:CharacterAdded(player)
end
 
--// PlayerRemoved
function DungeonService:PlayerRemoved(player)
    --DungeonService.PlayerTimes[player.UserId] = nil
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

        self:TimerLoop()

end

--// KnitInit
function DungeonService:KnitInit()

end

return DungeonService