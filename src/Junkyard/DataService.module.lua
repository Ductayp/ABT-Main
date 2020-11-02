local players = game:GetService("Players")
local profileService = require(script.ProfileService)
local profileTemplate = require(script.ProfileTemplate)

local profiles = {}

-- This is loading the main functionality of profile service
-- The first argument is the data store name, the second is the default profile template structure
local gameProfileStore = profileService.GetProfileStore(
	"PlayerData_v1", -- store name, change this to "forget" old data
	profileTemplate
)

local db = {}

db.Connect = function(player)

	-- This loads the profile. If the player does not have one yet it uses the profileTemplate
	local profile = gameProfileStore:LoadProfileAsync("Player_" .. player.UserId, "ForceLoad")

	-- This is just a debug
	print("DataStore: Player_" .. player.UserId)

	-- If there is a newly initialized profile or a loaded profile
	if profile ~= nil then

		-- This is part of profile serviec inbuilt profile locking
		-- when a player leaves the game it will be released
		profile:ListenToRelease(function()
			profiles[player] = nil
			-- The profile could've been loaded on another Roblox server:
			player:Kick()
		end)

		-- This makes sure the player is in the game (like mayeb a bad network connection and they left)
		if player:IsDescendantOf(players) == true then

			-- This assignes the loaded profile into the user/profile table
			profiles[player] = profile

		else
			-- This will release/unlock the profile if there was a netowrk issue
			profile:Release()
		end

	else
		-- We get here if another server is trying to load the profile at exactly the dame time
		player:Kick()
	end

	return db
end

-- This is your way to gracefully release a profile lock as shown in the Bootstrap file
db.Disconnect = function(_, player)
	local profile = profiles[player]
	if profile then
		profile:Release()
	end
end

-- This is how to get one players Data
db.GetPlayerData = function(player)
	local profile = profiles[player]
	if profile then
		return profile.Data
	end
end

--// Player Setup
function db.PlayerSetup(player)
	db.Connect(player)
end

--// Player Leave
function db.PlayerLeave(player)
	db.Disconnect(player)
end

return db
