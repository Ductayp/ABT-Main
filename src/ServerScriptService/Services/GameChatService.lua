-- GameChatService

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ChatService = require(ServerScriptService:WaitForChild("ChatServiceRunner").ChatService)

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local GameChatService = Knit.CreateService { Name = "GameChatService", Client = {}}
local RemoteEvent = require(Knit.Util.Remote.RemoteEvent)

-- module
local utils = require(Knit.Shared.Utils)

local TAG_DEFS = {
    ["Owner"] = {TagText = "DEV", TagColor = Color3.fromRGB(255, 0, 255)},
    ["Admin"] = {TagText = "DEV", TagColor = Color3.fromRGB(255, 0, 255)},
    ["Tester"] = {TagText = "TESTER", TagColor = Color3.fromRGB(85, 255, 255)},
    --["Guest"] = {TagText = "GUEST", TagColor = Color3.new(1, 0, 0)},
}

--// SpeakerAdded
function GameChatService:SpeakerAdded(speakerName)

    local speaker = ChatService:GetSpeaker(speakerName)
    local player = speaker:GetPlayer()

    local playerRole = player:GetRoleInGroup(3486129)

    if TAG_DEFS[playerRole] then
        speaker:SetExtraData("Tags", {TAG_DEFS[playerRole]})
    end

    local playerDataStatuses = ReplicatedStorage:WaitForChild("PlayerDataLoaded")
    local playerDataBoolean = playerDataStatuses:WaitForChild(player.UserId)
    repeat wait(1) until playerDataBoolean.Value == true -- wait until the value is true, this is set by PlayerDataService when the data is fully loaded for this player

    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    if not playerData then return end
    
    if playerData.Admin.Muted then
        local allChannel = ChatService:GetChannel("ALL")
        allChannel:MuteSpeaker(speakerName)
    end

end

--// MutePlayer
function GameChatService:MutePlayer(player, muteBoolean)

    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

    playerData.Admin.Muted = muteBoolean
        
    local allChannel = ChatService:GetChannel("ALL")

    if muteBoolean == true then
        allChannel:MuteSpeaker(player.Name)
    else
        allChannel:UnmuteSpeaker(player.Name)
    end

end

--// PlayerAdded
function GameChatService:PlayerAdded(player)
    repeat wait() until player.Character
    self:CharacterAdded(player)
end
 
--// PlayerRemoved
function GameChatService:PlayerRemoved(player)

end

--// CharacterAdded
function GameChatService:CharacterAdded(player)
    repeat wait() until player.Character
end

--// KnitStart
function GameChatService:KnitStart()

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
function GameChatService:KnitInit()

    ChatService.SpeakerAdded:Connect(function(speakerName)
        self:SpeakerAdded(speakerName)
    end)

    for _, speaker in ipairs(ChatService:GetSpeakerList()) do
        self:SpeakerAdded(speakerName)
    end


end

return GameChatService