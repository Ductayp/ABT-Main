-- This service handles all management of the player Gui from the server side.
-- It is responsible for creating and destroying a player folder that contains ValueObjects in
-- ReplicatedStorage. It also connects Changed events and spawns scripts that help
-- keep the player Gui updated to reflect the values of the ValueObjects

local serverScriptService = game:GetService("ServerScriptService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local StarterPlayer = game:GetService("StarterPlayer")

local dataService = require(serverScriptService.Services.DataService)
local utils = require(replicatedStorage.SRC.Modules.Utilities)

local module = {}
module.dataKeyTable = {}

--[[
--// UPDATE VALUE - uses new Profile Service
function module.UpdateValue(player,key)
	local playerFolder = ReplicatedStorage.ReplicatedPlayerData[player.UserId]
	
	local playerData = dataService.getPlayerData(player)
	local value = playerData[key]
	
	local thisValueObject = playerFolder:FindFirstChild(key)
	if thisValueObject then
		thisValueObject.Value = value
	else
		thisValueObject = utils.NewValueObject(key,value,playerFolder)
	end
end
]]--

--// UPDATE ALL - grabs the playerdata table and build it in replicated, can be fired any time and will copy al currnt data over whatever exists
function module.UpdateAll(player)
	local playerFolder = replicatedStorage.ReplicatedPlayerData[player.UserId]
	local playerData = dataService.GetPlayerData(player)

	-- loop through the playe data and get only keys and values, insert in new dictionary
	local keyTable = {}
	local function loop(playerData)
		for key, value in pairs(playerData) do
			if type(value) == 'table'  then
				loop(value)
			else
				keyTable[key] = value
			end
		end
	end
	loop(playerData)

	for key,value in pairs(keyTable) do
		local thisValueObject = playerFolder:FindFirstChild(key)
		if not thisValueObject then
			thisValueObject = utils.NewValueObject(key,value,playerFolder)
		else
			thisValueObject.Value = value
		end
	end
end

--// PLAYER LEAVE
function module.PlayerLeave(player)
	replicatedStorage.ReplicatedPlayerData:FindFirstChild(player.UserId):Destroy()  
end

--// PLAYER JOIN
function module.PlayerSetup(player)
	local replicatedDataFolder = replicatedStorage:WaitForChild("ReplicatedPlayerData")
	local newFolder = Instance.new("Folder")
	newFolder.Name = player.UserId
	newFolder.Parent = replicatedDataFolder

	module.UpdateAll(player)
end

--// SERVER SETUP
function module.Start()
	local NewFolder = Instance.new("Folder")
	NewFolder.Name = "ReplicatedPlayerData"
	NewFolder.Parent = replicatedStorage
	
end

return module
