-- PlayerSpawnService

-- services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local PhysicsService = game:GetService("PhysicsService")


-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local PlayerSpawnService = Knit.CreateService { Name = "PlayerSpawnService", Client = {}}
local RemoteEvent = require(Knit.Util.Remote.RemoteEvent)

-- module
local utils = require(Knit.Shared.Utils)

local respawnDelay = 3

-- spawn location folders
PlayerSpawnService.SpawnerGroups = require(Knit.Defs.SpawnGroups)


PlayerSpawnService.PlayerSpawnSettigns = {}

--// SetPlayerSpawn
function PlayerSpawnService:SetPlayerSpawn(player, spawnName, respawn)

    if not PlayerSpawnService.SpawnerGroups[spawnName] then 
        print("nope")
        return
    end
    PlayerSpawnService.PlayerSpawnSettigns[player.UserId].CurrentSpawn = spawnName

    wait()

    if respawn then
        player.Character.Humanoid.Health = 0
    end

    
    Knit.Services.PlayerUtilityService.PlayerMapZone[player.UserId] = spawnName
    Knit.Services.GuiService:Update_Gui(player, "ItemFinderWindow")

end

--// TransportToSpawn - SERVER ONLY!!!! Can take a player to any spawners
function PlayerSpawnService:TransportToSpawn(player, spawnName)

    if not require(Knit.Defs.SpawnGroups)[spawnName] then 
        return 
    end

    local spawnerGroup = require(Knit.Defs.SpawnGroups)[spawnName]:GetChildren()
    local randPick = math.random(1, #spawnerGroup)
    local targetSpawner = spawnerGroup[randPick]

    wait(1)

    if not player then return end
    player.Character.HumanoidRootPart.CFrame = targetSpawner.CFrame
end

--// TransportHome - Soewhat safe for the client, can only take a player back to Default Spawn
function PlayerSpawnService:TransportHome(player)

    local spawnerGroup = require(Knit.Defs.SpawnGroups)["Morioh"]:GetChildren()
    local randPick = math.random(1, #spawnerGroup)
    local targetSpawner = spawnerGroup[randPick]

    wait(1)

    if not player then return end

    player.Character.HumanoidRootPart.CFrame = targetSpawner.CFrame

    Knit.Services.GuiService:PlayerTransported(player)

end

--// CustomSpawn
function PlayerSpawnService:CustomSpawn(player)

    --print("PlayerSpawnService:CustomSpawn(player)", player)

    wait(respawnDelay)

    if not player then return end

    local spawnGroupName = PlayerSpawnService.PlayerSpawnSettigns[player.UserId].CurrentSpawn
    if not spawnGroupName then 
        PlayerSpawnService.PlayerSpawnSettigns[player.UserId] = {CurrentSpawn = "Morioh"}
        spawnGroupName = "Morioh"
        Knit.Services.PlayerUtilityService:SetPlayerMapZone(player, {MapZone = "Morioh"})
    end

    local spawnerGroup = PlayerSpawnService.SpawnerGroups[spawnGroupName]:GetChildren()
    local randPick = math.random(1, #spawnerGroup)
    local targetSpawner = spawnerGroup[randPick]

    if player.Parent ~= game.Players then
        local p = game.Players:WaitForChild(player.Name, 5)
        if not p then warn("PlayerSpawnService:CustomSpawn", player.Name, " not loaded in world") return false end
    end

    if player then

        player:LoadCharacter()

        for _, object in pairs(player.Character:GetChildren()) do
            if object:IsA("BasePart") then
                PhysicsService:SetPartCollisionGroup(object, "Player_NoCollide")
            end
        end

        player.Character.HumanoidRootPart.CFrame = targetSpawner.CFrame

    end

end

----------------------------------------------------------------------------------------------------------
-- CLIENT METHODS
----------------------------------------------------------------------------------------------------------

function PlayerSpawnService.Client:TransportHome(player, spawnName)
    self.Server:TransportHome(player, spawnName)
end

----------------------------------------------------------------------------------------------------------
-- PLAYER MANAGEMENT
----------------------------------------------------------------------------------------------------------

--// CharacterAdded
function PlayerSpawnService:CharacterAdded(player)
    --repeat wait() until player.Character
    local character = player.Character or player.CharacterAdded:Wait()
    player.Character:WaitForChild("Humanoid").Died:Connect(function()
        self:CustomSpawn(player)
    end)
end

--// PlayerAdded
function PlayerSpawnService:PlayerAdded(player)

    --repeat wait() until player.UserId
    
    PlayerSpawnService.PlayerSpawnSettigns[player.UserId] = {CurrentSpawn = "Morioh"}
    self:CustomSpawn(player)

    --repeat wait() until player.Character
    local character = player.Character or player.CharacterAdded:Wait()
    if character then
        self:CharacterAdded(player)
    end
    
end
 
--// PlayerRemoved
function PlayerSpawnService:PlayerRemoved(player)
    PlayerSpawnService.PlayerSpawnSettigns[player.UserId] = nil
end

----------------------------------------------------------------------------------------------------------
-- KNIT 
----------------------------------------------------------------------------------------------------------

--// KnitStart
function PlayerSpawnService:KnitStart()

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
function PlayerSpawnService:KnitInit()

    Players.CharacterAutoLoads = false

    PhysicsService:CreateCollisionGroup("Player_NoCollide")
    PhysicsService:CollisionGroupSetCollidable("Player_NoCollide", "Player_NoCollide", false)
    PhysicsService:CollisionGroupSetCollidable("Player_NoCollide", "Mob_NoCollide", false)

end

return PlayerSpawnService