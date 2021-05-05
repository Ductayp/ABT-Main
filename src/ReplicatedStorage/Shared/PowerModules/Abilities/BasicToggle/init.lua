-- Stand Manager

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Knits and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local AbilityToggle = require(Knit.PowerUtils.AbilityToggle)
local Cooldown = require(Knit.PowerUtils.Cooldown)


local BasicToggle = {}

--// --------------------------------------------------------------------
--// Handler Functions
--// --------------------------------------------------------------------

--// Initialize
function BasicToggle.Initialize(params, abilityDefs)

	-- check KeyState
	if params.KeyState == "InputBegan" then
		params.CanRun = true
	else
		params.CanRun = false
		return
	end

	-- check cooldown
	if not Cooldown.Client_IsCooled(params) then
		params.CanRun = false
		print("not cooled down")
		return
	end
end

--// Activate
function BasicToggle.Activate(params, abilityDefs)

	--print("BasicToggle.Activate(params, abilityDefs)", params, abilityDefs)


	local powerStatusFolder = ReplicatedStorage.PowerStatus[params.InitUserId]

	-- check KeyState
	if params.KeyState == "InputBegan" then
		params.CanRun = true
	else
		params.CanRun = false
		return
	end

	-- check cooldown
	if not Cooldown.Client_IsCooled(params) then
		params.CanRun = false
		return
	end

	-- set the toggles and StandTracker
	if AbilityToggle.GetToggleValue(params.InitUserId, params.InputId) == true then
		AbilityToggle.SetToggle(params.InitUserId, params.InputId, false)
		params.AbilityOn = false
	else
		AbilityToggle.SetToggle(params.InitUserId, params.InputId, true)
		params.AbilityOn = true
	end

	-- set cooldown
	Cooldown.SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)

	BasicToggle.RunServer(params, abilityDefs)

end

--// Execute
function BasicToggle.Execute(params, abilityDefs)

	BasicToggle.RunClient(params, abilityDefs)

end


--// --------------------------------------------------------------------
--// Ability Functions
--// --------------------------------------------------------------------

--// equips a stand for the target player
function BasicToggle.RunServer(params, abilityDefs)

	local abilityMod = require(abilityDefs.AbilityMod)

	if params.AbilityOn then
		abilityMod.Server_AbilityOn(params, abilityDefs)
	else
		abilityMod.Server_AbilityOff(params, abilityDefs)
	end
	
end

--// removes the stand for the target player
function BasicToggle.RunClient(params, abilityDefs)

	local abilityMod = require(abilityDefs.AbilityMod)

	if params.AbilityOn then
		abilityMod.Client_AbilityOn(params, abilityDefs)
	else
		abilityMod.Client_AbilityOff(params, abilityDefs)
	end
	
end


return BasicToggle
