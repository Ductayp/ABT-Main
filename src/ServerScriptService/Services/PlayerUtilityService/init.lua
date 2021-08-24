-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local StarterPlayer = game:GetService("StarterPlayer")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local PlayerUtilityService = Knit.CreateService { Name = "PlayerUtilityService", Client = {}}
local RemoteEvent = require(Knit.Util.Remote.RemoteEvent)

-- events
PlayerUtilityService.Client.Event_PlayerUtility = RemoteEvent.new()

-- modules
--local pingTime = require(Knit.Shared.PingTime)
local utils = require(Knit.Shared.Utils)

-- public variables
PlayerUtilityService.PlayerAnimations = {}
PlayerUtilityService.PlayerMapZone = {}


-- local variables
local updatePlayerTime = 3



--// UpdatePlayerLoop
function PlayerUtilityService:UpdatePlayerLoop()


end

function PlayerUtilityService:SetPlayerMapZone(player, zoneName)

    if not player or not zoneName then return end
    PlayerUtilityService.PlayerMapZone[player.UserId] = zoneName

end

function PlayerUtilityService:GetPlayerMapZone(player)

    return PlayerUtilityService.PlayerMapZone[player.UserId]

end

function PlayerUtilityService:GetPlayersInMapZone(mapZone)

    local playersInZone = {}
    for userId, currentMapZone in pairs(PlayerUtilityService.PlayerMapZone) do
        if currentMapZone == mapZone then
            local player = utils.GetPlayerByUserId(userId)
            if player then
                table.insert(playersInZone, player)
            end
        end
    end

    return playersInZone

end

--// LoadAnimations
function PlayerUtilityService:LoadAnimations(player)

    -- clear the players animation table so its fresh
    PlayerUtilityService.PlayerAnimations[player.UserId] = {}

    -- load the players animation table with tracks
    local animator = player.Character.Humanoid:WaitForChild("Animator")
    for _,animObject in pairs(ReplicatedStorage.PlayerAnimations:GetChildren()) do
        PlayerUtilityService.PlayerAnimations[player.UserId][animObject.Name] = animator:LoadAnimation(animObject)
    end

end

--------------------------------------------------------------------------------------------------------------------------
--// CLIENT METHODS ---------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------

function PlayerUtilityService.Client:GetPlayerMapZone(player)
    local playerMapZone = self.Server:GetPlayerMapZone(player)
    return playerMapZone
end

--------------------------------------------------------------------------------------------------------------------------
--// PLAYER EVENTS ---------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------

--// PlayerAdded
function PlayerUtilityService:PlayerAdded(player)

    self:SetPlayerMapZone(player, "Morioh")

    -- wait for the character
    repeat wait() until player.Character
    self:CharacterAdded(player)
    
    Knit.Services.StateService:AddEntryToState(player, "HealthTick", "Default", true, {Day = 1, Night = 1})


end

--// PlayerRemoved
function PlayerUtilityService:PlayerRemoved(player)

    PlayerUtilityService.PlayerAnimations[player.UserId] = nil
    PlayerUtilityService.PlayerMapZone[player.UserId] = nil
end

--// CharacterAdded
function PlayerUtilityService:CharacterAdded(player)

    -- wait for the character
    repeat wait() until player.Character

    self:LoadAnimations(player)

end

--// CharacterDied
function PlayerUtilityService:CharacterDied(player)
    --print("PLAYER DIED:", player)
end

--------------------------------------------------------------------------------------------------------------------------
--// KNIT ---------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------

--// KnitStart
function PlayerUtilityService:KnitStart()

    -- start the loop
    self:UpdatePlayerLoop()

    -- Player Added event
    Players.PlayerAdded:Connect(function(player)
        self:PlayerAdded(player)

        player.CharacterAdded:Connect(function(character)
            self:CharacterAdded(player)
    
            character:WaitForChild("Humanoid").Died:Connect(function()
                --self:CharacterDied(player)
            end)
        end)
    end)

    -- Player Added event for studio tesing, catches when a player has joined before the server fully starts
    for _, player in ipairs(Players:GetPlayers()) do
        self:PlayerAdded(player)

        player.CharacterAdded:Connect(function(character)
            self:CharacterAdded(player)
    
            character:WaitForChild("Humanoid").Died:Connect(function()
                --self:CharacterDied(player)
            end)
        end)
    end

    -- Player Removing event
    Players.PlayerRemoving:Connect(function(player)
        self:PlayerRemoved(player)
    end)

end

--// KnitInit
function PlayerUtilityService:KnitInit()

    local healthScript = script:FindFirstChild("Health")
    if healthScript then
        healthScript.Parent = StarterPlayer.StarterCharacterScripts
    end

end

return PlayerUtilityService