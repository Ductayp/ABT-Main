local replicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(replicatedStorage.SRC.Modules.Utilities)
local powerUtils = require(replicatedStorage.SRC.Modules.PowersShared.PowerUtils)
local powerDefs = require(replicatedStorage.SRC.Definitions.PowerDefs.TheWorld)

local module = {}

-- ABILITY 1 - Equip Stand
function module.Ability_1(targetPlayer,dictionary)
	local equipScript = require(script.Parent.Parent.EffectScripts.EquipStand)
	if dictionary.NewStandStatus then
		equipScript.EquipStand(targetPlayer,dictionary)
	else
		equipScript.RemoveStand(targetPlayer,dictionary)
	end
end

-- Ability 2 - Barrage "Za Warudo"?
function module.Ability_2(targetPlayer,dictionary)
	local targetStand = workspace.LocalEffects.PlayerStands[targetPlayer.UserId]:FindFirstChildWhichIsA("Model")
	local barrageScript = require(script.Parent.Parent.EffectScripts.Barrage)

	if targetStand then
		if dictionary.BarrageOn then
			barrageScript.RunEffect(targetPlayer,dictionary)
		else 
			barrageScript.EndEffect(targetPlayer,dictionary)
		end	
	end
end

-- Ability 3 - EXAMPLE
function module.Ability_3(targetPlayer,dictionary)
	print("Client - The World - Ability 3 - ?")
	
end

-- Ability 4 - EXAMPLE
function module.Ability_4(targetPlayer,dictionary)
	print("Client - The World - Ability 4 - ?")
	
end

-- Ability 5 - EXAMPLE
function module.Ability_5(targetPlayer,dictionary)
	print("Client - The World - Ability 5 - ?")
	
end

-- Ability 5 - EXAMPLE
function module.Ability_6(targetPlayer,dictionary)
	print("Client - The World - Ability 6 - ?")
	
end

return module