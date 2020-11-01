-- THIS SERVICE WILL BOOTSTRAP THE ENTIRE GAME

-- This script bootstraps the whole game
local players = game:GetService("Players")
local serverScriptService = game:GetService("ServerScriptService")
local replicatedStorage = game:GetService("ReplicatedStorage")

local dataReplicationService = require(serverScriptService.Services.DataReplicationService)
local powersService = require(serverScriptService.Services.PowersService)
local dataService = require(serverScriptService.Services.DataService)


--// SERVER STARTUP
print("Main Service - Server Startup - Begin")
dataReplicationService.Start()
powersService.Start()
print("Main Service - Server Startup - Complete")

--[[
--// ON PLAYER ADDED
players.PlayerAdded:Connect(function(player)

	print("Main Service - Player Added - Begin for Player: ",player)
	dataService.PlayerSetup(player)
	dataReplicationService.PlayerSetup(player)
	powersService.PlayerSetup(player)
	print("Main Service - Player Added - Complete for Player: ",player)
	
	
	--// ON CHARACTER ADDED
	player.CharacterAdded:Connect(function()
		print(player," character has connected")
		powersService.CharacterJoined(player)
	end)
	
	--// ON CHARACTER APPEARANCE LOADED
	player.CharacterAppearanceLoaded:Connect(function(character)
		print(player," appearance has loaded")
		powersService.AppearanceLoaded(player)
	end)

end)
]]--

--// ON PLAYER ADDED
local function PlayerAdded(player)

	print("Main Service - Player Added - Begin for Player: ",player)
	dataService.PlayerSetup(player)
	dataReplicationService.PlayerSetup(player)
	powersService.PlayerSetup(player)
	print("Main Service - Player Added - Complete for Player: ",player)


	--// ON CHARACTER ADDED
	player.CharacterAdded:Connect(function()
		print(player," character has connected")
		powersService.CharacterJoined(player)
	end)

	--// ON CHARACTER APPEARANCE LOADED
	player.CharacterAppearanceLoaded:Connect(function(character)
		print(player," appearance has loaded")
		powersService.AppearanceLoaded(player)
	end)

	--// ON CHARACTER DIED
	player.CharacterAdded:Connect(function(character)
		character:WaitForChild("Humanoid").Died:Connect(function()
			print(player.Name," has died")
			powersService.CharacterDied(player)
		end)
	end)

end

--[[
--// ON CHARACTER DIED
players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		character:WaitForChild("Humanoid").Died:Connect(function()
			print(player.Name," has died")
			powersService.CharacterDied(player)
		end)
	end)
end)
]]--


--// ON PLAYER REMOVING
players.PlayerRemoving:Connect(function(player)

	dataReplicationService.PlayerLeave(player)
	powersService.PlayerLeave(player)
	dataService.PlayerLeave(player)

end)


players.PlayerAdded:Connect(PlayerAdded)
for _, player in ipairs(players:GetPlayers()) do
	PlayerAdded(player)
end

--[[
local function PlayerRemoved(player)
	dataReplicationService.PlayerLeave(player)
	powersService.PlayerLeave(player)
	dataService.PlayerLeave(player)
end




players.PlayerRemoving:Connect(PlayerRemoved)
for _, player in ipairs(players:GetPlayers()) do
	PlayerRemoved(player)
end
]]--
