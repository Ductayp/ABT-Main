-- Player Data Service
-- PDab
-- 11/5/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- ProfileService requires and setup
local profileService = require(script.ProfileService)
local profileTemplate = require(script.ProfileTemplate)
local profiles = {} -- this is the table that holds each players data

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local PlayerDataService = Knit.CreateService { Name = "PlayerDataService", Client = {}}


-- This is loading the main functionality of profile service
-- The first argument is the data store name, the second is the default profile template structure
PlayerDataService.gameProfileStore = profileService.GetProfileStore(
	"PlayerData_v2", -- store name, change this to "forget" old data
	profileTemplate
)

--// PlayerConnected - fires once player has connected to data, we can do all osrts of things from here
function PlayerDataService:PlayerConnected(player)
    print("ProfileService: Data Loaded for: ",player)
    Knit.Services.DataReplicationService:UpdateAll(player)
end

function PlayerDataService:Connect(player)

    -- This loads the profile. If the player does not have one yet it uses the profileTemplate
    local profile = PlayerDataService.gameProfileStore:LoadProfileAsync("Player_" .. player.UserId, "ForceLoad")

    -- This is just a debug
    print("ProfileService: Attempting to load data for: ",player.UserId)

    -- If there is a newly initialized profile or a loaded profile
    if profile ~= nil then

        -- This is part of profile serviec inbuilt profile locking
        -- when a player leaves the game it will be released
        profile:ListenToRelease(function()
            profiles[player] = nil
            -- The profile could've been loaded on another Roblox server:
            player:Kick()
        end)

        -- This makes sure the player is in the game (like maybe a bad network connection and they left)
        if player:IsDescendantOf(players) == true then

            -- This assignes the loaded profile into the user/profile table
            profiles[player] = profile
            
            -- fire a function once player is connected
            self:PlayerConnected(player)

            -- give a message
            print("Loaded DataStore: Player_" .. player.UserId)

        else
            -- This will release/unlock the profile if there was a netowrk issue
            profile:Release()
        end

    else
        -- We get here if another server is trying to load the profile at exactly the same time
        player:Kick()
    end

return db

end

function PlayerDataService:Disconnect(player)
    local profile = profiles[player]
	if profile then
		profile:Release()
	end
end

function PlayerDataService:GetPlayerData(player)
    local profile = profiles[player]
	if profile then
		return profile.Data
	end
end

function PlayerDataService.Client:GetPlayerData(player)
    print("yes",player)
    --self:GetPlayerData(player)
end 

function PlayerDataService:KnitStart()

end


function PlayerDataService:KnitInit()
    -- Player Added event
    Players.PlayerAdded:Connect(function(player)
        self:Connect(player)
    end)

    -- Player Added event for studio tesing, catches when a player has joined before the server fully starts
    for _, player in ipairs(Players:GetPlayers()) do
        self:Connect(player)
    end

    -- Player Removing event
    Players.PlayerRemoving:Connect(function(player)
        self:Disconnect(player)
    end)
end

return PlayerDataService