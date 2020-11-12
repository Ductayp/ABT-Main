--[[ THE WORLD - SERVER ]]--

local replicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(replicatedStorage.SRC.Modules.Utilities)
local powerUtils = require(replicatedStorage.SRC.Modules.PowersShared.PowerUtils)
local powerDefs = require(replicatedStorage.SRC.Definitions.PowerDefs.TheWorld)

local module = {}

-- ABILITY 1 - Equip Stand
function module.Ability_1(player,dictionary)
	local abilityToggle = replicatedStorage.PowerStatus.AbilityToggle[player.UserId]:FindFirstChild(dictionary.AbilityID)
	if abilityToggle.Value == true then
		dictionary.NewStandStatus = false
		abilityToggle.Value = false
		--powerUtils.SetCooldown(player,dictionary)
	else
		dictionary.NewStandStatus = true
		abilityToggle.Value = true
		--powerUtils.SetCooldown(player,dictionary)
	end
	replicatedStorage.GameEvents.PowerAnimation:FireAllClients(player,dictionary)
end

--// Ability 2 - Barrage "Za Warudo"?
function module.Ability_2(player,dictionary)
	local abilityToggle = replicatedStorage.PowerStatus.AbilityToggle[player.UserId]:FindFirstChild(dictionary.AbilityID)
	
	-- return if ability toggle isnt there, this happens sometimes when the player leaves before cooldown is over
	if not abilityToggle then
		return
	end

	if dictionary.KeyState == "InputBegan" and abilityToggle.Value == false then
		dictionary.BarrageOn = true
		abilityToggle.Value = true
		replicatedStorage.GameEvents.PowerAnimation:FireAllClients(player,dictionary)
		wait(powerDefs.Ability_2.Duration)
		dictionary.KeyState = "InputEnded"
		module.Ability_2(player,dictionary)
		
	elseif dictionary.KeyState == "InputEnded" and abilityToggle.Value == true then
		dictionary.BarrageOn = false
		abilityToggle.Value = false
		powerUtils.SetCooldown(player,dictionary) -- set cooldown in here (redundnat with PowersService) so you cant spam barrage
		replicatedStorage.GameEvents.PowerAnimation:FireAllClients(player,dictionary)
	end
end

-- //Ability 3 - EXAMPLE
function module.Ability_3(player,dictionary)
	print("Server - The World - Ability 3 - ?")

end

--// Ability 4 - EXAMPLE
function module.Ability_4(player,dictionary)
	print("Server - The World - Ability 4 - ?")
	
end

--// Ability 5 - EXAMPLE
function module.Ability_5(player,dictionary)
	print("Server - The World - Ability 5 - ?")
	
end

--// Ability 6 - EXAMPLE
function module.Ability_6(player,dictionary)
	print("Server - The World - Ability 6 - ?")
	
end


return module
