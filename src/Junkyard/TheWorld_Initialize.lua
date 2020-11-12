--[[ THE WORLD - CLIENT - INITIALIZE]]--

local replicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer
local utils = require(replicatedStorage.SRC.Modules.Utilities)

local usePowerEvent = replicatedStorage.GameEvents:WaitForChild("UsePower")


local module = {}

--// ABILITY 1 - Equip Stand
function module.Ability_1(abilityID,dictionary)
	--print("Client - The World - INITIALIZE - Ability 1 - Equip Stand")

	if dictionary.KeyState == "InputBegan" then
		usePowerEvent:FireServer(dictionary)
	end
	
end

--// Ability 2 - Barrage "Za Warudo"?
function module.Ability_2(abilityID,dictionary)
	--print("Client - The World - INITIALIZE - Ability 2 - Barrage")
	
	usePowerEvent:FireServer(dictionary)
	
end

--// Ability 3 - EXAMPLE
function module.Ability_3(ability,dictionary)
	print("Client - The World - INITIALIZE - Ability 3 - ?")

	usePowerEvent:FireServer(dictionary)
end

--// Ability 4 - EXAMPLE
function module.Ability_4(ability,dictionary)
	print("Client - The World - INITIALIZE - Ability 4 - ?")

	usePowerEvent:FireServer(dictionary)
end

--// Ability 5 - EXAMPLE
function module.Ability_5(ability,dictionary)
	print("Client - The World - INITIALIZE - Ability 5 - ?")

	usePowerEvent:FireServer(dictionary)
end

--// Ability 6 - EXAMPLE
function module.Ability_6(ability,dictionary)
	print("Client - The World - INITIALIZE - Ability 6 - ?")

	usePowerEvent:FireServer(dictionary)
end


return module
