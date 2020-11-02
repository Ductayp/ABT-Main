-- Powers Service
local serverScriptService = game:GetService("ServerScriptService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")

local dataService = require(serverScriptService.Services.DataService)
local dataReplicationService = require(serverScriptService.Services.DataReplicationService)
local utils = require(replicatedStorage.SRC.Modules.Utilities)


--// Event Variables - decalare this here so it can be used by the whole script
local usePowerEvent
local powerAnimationEvent
local playerJoinedAnimations

local module = {}

--// USE POWER
function module.UsePower(player,dictionary)

	local playerData = dataService.GetPlayerData(player)
	local currentPower = playerData.Character.CurrentStand
	local powerDef = require(replicatedStorage.SRC.Definitions.PowerDefs[currentPower])
	local playerToggleFolder = replicatedStorage.PowerStatus.AbilityToggle[player.UserId]

	-- check if an ability toggle boolean exists, make it if not, this happens the first time an ability is used. Bools are set opposite so they work in the checks below
	local abilityToggle = playerToggleFolder:FindFirstChild(dictionary.AbilityID)
	if not abilityToggle then
		if dictionary.KeyState == "InputBegan" then
			abilityToggle = utils.EasyInstance("BoolValue",{Name = dictionary.AbilityID,Parent = replicatedStorage.PowerStatus.AbilityToggle[player.UserId],Value = false})
		else
			abilityToggle = utils.EasyInstance("BoolValue",{Name = dictionary.AbilityID,Parent = replicatedStorage.PowerStatus.AbilityToggle[player.UserId],Value = true})
		end

	end

	-- check if a cooldown exists for this ability, make it if not
	local abilityCooldown = replicatedStorage.PowerStatus.Cooldowns[player.UserId]:FindFirstChild(dictionary.AbilityID)
	if not abilityCooldown then
		abilityCooldown = utils.EasyInstance("NumberValue",{Name = dictionary.AbilityID,Parent = replicatedStorage.PowerStatus.Cooldowns[player.UserId],Value = os.time() - 1})
	end

	-- check cooldown - this is also done on the client
	if os.time() < abilityCooldown.Value then
		return
	end
	

	--check override - if an ability override is true, no other ability can fire while it is toggled on
	for i,v in pairs(playerToggleFolder:GetChildren()) do
		if v.Value == true then
			local overrideValue = powerDef[v.Name].Override
			if overrideValue and dictionary.KeyState == "InputBegan" then
				print("override")
				return
			end
		end
	end

	-- check Ability pre-requisites
	if powerDef[dictionary.AbilityID].AbilityPreReq then
		for i,v in pairs(powerDef[dictionary.AbilityID].AbilityPreReq) do
			local thisObject = playerToggleFolder:FindFirstChild(v)
			if thisObject then
				local thisValue = thisObject.Value
				print(thisValue)
				if not thisValue then
					print("preReq not met")
					return
				end
			else
				return
			end
		end
	end
	
	--[[ -- abondned this but leaving it here for now. Instead lets let the Power Script handle state change stuff
	-- check ability state change, if were not doing anythign, then return
	if dictionary.KeyState == "InputBegan" and abilityToggle.Value == true then
		print("no ability state change")
		return
	elseif dictionary.KeyState == "InputEnded" and abilityToggle.Value == false then
		if powerDef[dictionary.AbilityID].CoolDown_InputEnded then
			print("no ability state change")
			return
		end
	end
	]]--

	-- set cooldowns
	if dictionary.KeyState == "InputBegan" and powerDef[dictionary.AbilityID].CoolDown_InputBegan then
		abilityCooldown.Value = os.time() + powerDef[dictionary.AbilityID].Cooldown
	end
	if dictionary.KeyState == "InputEnded" and powerDef[dictionary.AbilityID].CoolDown_InputEnded then
		abilityCooldown.Value = os.time() + powerDef[dictionary.AbilityID].Cooldown
	end


	if currentPower == dictionary.PowerID then -- sanity check, if this fails then its probably a hacker
		local powerModule = script.Powers:FindFirstChild(currentPower)
		if powerModule then
			local requiredModule = require(powerModule)
			requiredModule[dictionary.AbilityID](player,dictionary) -- fire the ability

		else
			print("ERROR: assigned power doesnt exist")
		end
	else
		print("NOPE, cant run this power")
	end
end

--// SET POWER/STAND
function module.SetPower(player,power)
	local playerData = dataService.GetPlayerData(player)
	playerData.Character.CurrentStand = power
	dataReplicationService.UpdateAll(player)

	--delete any stands in the palyer folder
	local playerStandFolder = workspace.LocalEffects.PlayerStands:FindFirstChild(player.UserId)
	if playerStandFolder then
		playerStandFolder:ClearAllChildren()
	end
end


--// PLAYER LEAVE
function module.PlayerLeave(player)

	local playerStandFolder = workspace.LocalEffects.PlayerStands:FindFirstChild(player.UserId)
	if playerStandFolder then
		playerStandFolder:Destroy()
	end

	local playerCooldownFolder =  replicatedStorage.PowerStatus.Cooldowns[player.UserId]
	playerStandFolder:Destroy()
	local playerToggleFolder =  replicatedStorage.PowerStatus.AbilityToggle[player.UserId]
	playerToggleFolder:Destroy()

end

--// CHARACTER JOINED
function module.CharacterJoined(player)

end

--// APPEARANCE LODADED
function module.AppearanceLoaded(player)

end

--// CHARACTER DIED
function module.CharacterDied(player)
	print("POWERS SERVICE: character died: ",player)

	local abilityToggleFolder = replicatedStorage.PowerStatus.AbilityToggle[player.UserId]:GetChildren()
	for i,v in pairs(abilityToggleFolder) do
		v.Value = false
	end

	local playerStandFolder = workspace.LocalEffects.PlayerStands:FindFirstChild(player.UserId)
	if playerStandFolder then
		playerStandFolder:Destroy()
	end
	--local playerStandFolder = utils.EasyInstance("Folder",{Name = player.UserId, Parent = workspace.PlayerStands})

end

--// PLAYER SETUP
function module.PlayerSetup(player)

	-- setup the players Stand folder
	local playerStandFolder = utils.EasyInstance("Folder",{Name = player.UserId, Parent = workspace.LocalEffects.PlayerStands})

	-- TODO: we need to replcaite the CurrentStand data to the client!

	-- setup the players cooldown and toggle folders
	local newPlrCooldownFolder = utils.EasyInstance("Folder",{Parent = replicatedStorage.PowerStatus.Cooldowns,Name = player.UserId})
	local newPlrToggleFolder = utils.EasyInstance("Folder",{Parent = replicatedStorage.PowerStatus.AbilityToggle,Name = player.UserId})

	-- render existing stands for the player when they join
	spawn(function()
		for _,targetPlayer in pairs(players:GetPlayers()) do
			if player ~= targetPlayer then

				print("player loading in: ",player)
				print("player with stand to render:",targetPlayer)

				local playerData = dataService.GetPlayerData(player)
				local dictionary = {}
				dictionary.PowerID = playerData.Character.CurrentStand

				local abilityToggleFolder = replicatedStorage.PowerStatus.AbilityToggle[targetPlayer.UserId]
				local ability_1 = abilityToggleFolder:FindFirstChild("Ability_1")

				if ability_1 then
					dictionary.AbilityID = "Ability_1"
					if ability_1.Value == true then
						dictionary.NewStandStatus = true
					else
						dictionary.NewStandStatus = false
					end
				else
					dictionary.AbilityID = "Ability_1"
					dictionary.NewStandStatus = false
				end
				replicatedStorage.GameEvents.PlayerJoinedAnimation:FireClient(player,targetPlayer,dictionary)
			end
		end
	end)


end

--// START
function module.Start()

	-- Setup the Events
	usePowerEvent = utils.EasyRemoteEvent("UsePower")
	usePowerEvent.OnServerEvent:Connect(function(player,dictionary)
		module.UsePower(player,dictionary)
	end)
	powerAnimationEvent = utils.EasyRemoteEvent("PowerAnimation")
	playerJoinedAnimations =  utils.EasyRemoteEvent("PlayerJoinedAnimation")

	-- create folders in workspace for parenting effects and also stands
	local effectFolder = utils.EasyInstance("Folder",{Name = "LocalEffects", Parent = workspace})
	local standFolder = utils.EasyInstance("Folder",{Name = "PlayerStands", Parent = effectFolder})

	-- setup power status folders
	local statusFolder = utils.EasyInstance("Folder",{Parent = replicatedStorage,Name = "PowerStatus"})
	local cooldownFolder = utils.EasyInstance("Folder",{Parent = statusFolder,Name = "Cooldowns"})
	local toggleFolder = utils.EasyInstance("Folder",{Parent = statusFolder,Name = "AbilityToggle"})
end

return module

