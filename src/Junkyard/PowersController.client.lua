--[[ POWERS CONTROLLER ]]--

local replicatedStorage = game:GetService("ReplicatedStorage")
local userInputService = game:GetService("UserInputService")
local localPlayer = game.Players.LocalPlayer
local utils = require(replicatedStorage.SRC.Modules.Utilities)


local usePowerEvent = replicatedStorage.GameEvents:WaitForChild("UsePower")
local playerDataFolder = replicatedStorage.ReplicatedPlayerData


local module = {}

function module.ActivatePower(abilityID,dictionary)
	local assumedPower = playerDataFolder[localPlayer.UserId].CurrentStand.Value
	local intitModule = replicatedStorage.SRC.Modules.PowersShared.InitializeScripts:FindFirstChild(assumedPower)
	local abilityCooldown = replicatedStorage.PowerStatus.Cooldowns[localPlayer.UserId]:FindFirstChild(abilityID)
	
	dictionary.PowerID = assumedPower
	dictionary.AbilityID = abilityID

	if not abilityCooldown or abilityCooldown.Value <= os.time()  then -- just check cooldowns here to reduce spamming remotes to the server

		if intitModule then
			local requiredModule = require(intitModule)
			if requiredModule[abilityID] then
				requiredModule[abilityID](abilityID,dictionary) -- call the right function and also pass the name along so its handy
			else
				print("PowersController - Init module exists but there is not ability that matches request")
			end
		else	
			print("PowersController - Power does not have an Init Module")
		end	
	end
end

function module.ExecutePower(targetPlayer,dictionary)
	local powerExecuteModule = replicatedStorage.SRC.Modules.PowersShared.ExecuteScripts:FindFirstChild(dictionary.PowerID)
	local powerDef = require(replicatedStorage.SRC.Definitions.PowerDefs[dictionary.PowerID])
	
	-- set the cooldown GUI
	local setCooldown
	if localPlayer == targetPlayer then
		if dictionary.KeyState == "InputBegan" then
			if powerDef[dictionary.AbilityID].CoolDown_InputBegan then
				setCooldown = true
			end
		elseif dictionary.KeyState == "InputEnded" then
			if powerDef[dictionary.AbilityID].CoolDown_InputEnded then
				setCooldown = true
			end
		end
	end
	
	if setCooldown then
		spawn(function()
			local coolDownValue = powerDef[dictionary.AbilityID].Cooldown
			if coolDownValue then
				local mainGui = localPlayer.PlayerGui:WaitForChild("MainGui")
				local coolDownFrame = mainGui:FindFirstChild("CoolDown",true)
				local newButton = coolDownFrame:FindFirstChild(dictionary.AbilityID):Clone()
				newButton.Name = "Cooldown"
				newButton.Parent = coolDownFrame
				newButton.Text = coolDownValue
				utils.EasyDebris(newButton,coolDownValue)
				for count = 1, coolDownValue do
					wait(1)
					newButton.Text = coolDownValue - count
				end
			end
		end)
	end
	
	-- now fire the effects
	if powerExecuteModule then
		local requiredModule = require(powerExecuteModule)
		if requiredModule[dictionary.AbilityID] then
			requiredModule[dictionary.AbilityID](targetPlayer,dictionary)
		end
	else
		print("ERROR: assigned power doesnt exist")
	end
end

function module.PlayerJoinedAnimation(targetPlayer,dictionary)
	print(targetPlayer,dictionary)
	for i,v in pairs(dictionary) do
		print(i,v)
	end
	module.ExecutePower(targetPlayer,dictionary)
end

function module.KeyBoardSetup()
	userInputService.InputBegan:Connect(function(input, isTyping)
		if isTyping then
			return
		elseif input.KeyCode == Enum.KeyCode.Q then
			module.ActivatePower("Ability_1",{KeyState = "InputBegan"})
		elseif input.KeyCode == Enum.KeyCode.E then
			module.ActivatePower("Ability_2",{KeyState = "InputBegan"})
		elseif input.KeyCode == Enum.KeyCode.R then
			module.ActivatePower("Ability_3",{KeyState = "InputBegan"})
		elseif input.KeyCode == Enum.KeyCode.T then
			module.ActivatePower("Ability_4",{KeyState = "InputBegan"})
		elseif input.KeyCode == Enum.KeyCode.F then
			module.ActivatePower("Ability_5",{KeyState = "InputBegan"})
		elseif input.KeyCode == Enum.KeyCode.Z then
			module.ActivatePower("Ability_6",{KeyState = "InputBegan"})
		elseif input.KeyCode == Enum.KeyCode.X then
			module.ActivatePower("Ability_7",{KeyState = "InputBegan"})
		elseif input.KeyCode == Enum.KeyCode.C then
			module.ActivatePower("Ability_8",{KeyState = "InputBegan"})
		end
	end)

	userInputService.InputEnded:Connect(function(input, isTyping)
		if isTyping then
			return
		elseif input.KeyCode == Enum.KeyCode.Q then
			module.ActivatePower("Ability_1",{KeyState = "InputEnded"})
		elseif input.KeyCode == Enum.KeyCode.E then
			module.ActivatePower("Ability_2",{KeyState = "InputEnded"})
		elseif input.KeyCode == Enum.KeyCode.R then
			module.ActivatePower("Ability_3",{KeyState = "InputEnded"})
		elseif input.KeyCode == Enum.KeyCode.T then
			module.ActivatePower("Ability_4",{KeyState = "InputEnded"})
		elseif input.KeyCode == Enum.KeyCode.F then
			module.ActivatePower("Ability_5",{KeyState = "InputEnded"})
		elseif input.KeyCode == Enum.KeyCode.Z then
			module.ActivatePower("Ability_6",{KeyState = "InputEnded"})
		elseif input.KeyCode == Enum.KeyCode.X then
			module.ActivatePower("Ability_7",{KeyState = "InputEnded"})
		elseif input.KeyCode == Enum.KeyCode.C then
			module.ActivatePower("Ability_8",{KeyState = "InputEnded"})
		end
	end)
end


function module.Start()
	module.KeyBoardSetup()
	
	-- Setup the events
	local powerAnimationEvent = replicatedStorage.GameEvents:FindFirstChild("PowerAnimation")
	powerAnimationEvent.OnClientEvent:Connect(function(targetPlayer,dictionary)
		module.ExecutePower(targetPlayer,dictionary)
	end)
	
	local playerJoinedAnimation = replicatedStorage.GameEvents:FindFirstChild("PlayerJoinedAnimation")
	playerJoinedAnimation.OnClientEvent:Connect(function(targetPlayer,dictionary)
		module.PlayerJoinedAnimation(targetPlayer,dictionary)
	end)
end

return module
