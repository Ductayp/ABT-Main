-- RadiusAttack

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local AbilityToggle = require(Knit.PowerUtils.AbilityToggle)
local ManageStand = require(Knit.Abilities.ManageStand)
local Cooldown = require(Knit.PowerUtils.Cooldown)
local TargetByZone = require(Knit.PowerUtils.TargetByZone)
local MobilityLock = require(Knit.PowerUtils.MobilityLock)

local RadiusAttack = {}

------------------------------------------------------------------------------------------------------------------------------
--// Initialize --------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
function RadiusAttack.Initialize(params, abilityDefs)

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

    if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
        params.CanRun = false
        return params
    end

    local abilityMod = require(abilityDefs.AbilityMod)

    MobilityLock.Client_AddLock(abilityMod.MobilityLockParams)

    local playerPing = Knit.Controllers.PlayerUtilityController:GetPing()
    local delayOffset = playerPing / 2
    abilityMod.CharacterAnimations(params, abilityDefs, delayOffset)

end

------------------------------------------------------------------------------------------------------------------------------
--// Activate ----------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
function RadiusAttack.Activate(params, abilityDefs)

    local abilityMod = require(abilityDefs.AbilityMod)

	-- check KeyState
	if params.KeyState == "InputBegan" then
		params.CanRun = true
	else
		params.CanRun = false
		return params
    end
    
    -- check cooldown
    if not Cooldown.Server_IsCooled(params) then
        params.CanRun = false
        return params
    end
    
    if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
        params.CanRun = false
        return params
    end

	-- set cooldown
    Cooldown.SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)

    -- block input
    require(Knit.PowerUtils.BlockInput).AddBlock(params.InitUserId, "RadiusAttack", abilityMod.InputBlockTime)

    
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    if not initPlayer then return end

    local abilityMod = require(abilityDefs.AbilityMod)
    if abilityMod.HitDelay then wait(abilityMod.HitDelay) end

    local origin = initPlayer.Character.HumanoidRootPart.Position
    local hitCharacters = TargetByZone.GetAllInRange(initPlayer, origin, abilityMod.Range, true)

    params.HitCharacters = hitCharacters

    spawn(function()

        if abilityMod.Server_Start then
            params, abilityDefs = abilityMod.Server_Start(params, abilityDefs, initPlayer)
        end
    
        for count = 1, abilityMod.TickCount do
            wait(abilityMod.TickTime)
            if abilityMod.Server_Tick then
                params, abilityDefs = abilityMod.Server_Tick(params, abilityDefs, initPlayer)
            end
        end
    
        if abilityMod.Server_End then
            params, abilityDefs = abilityMod.Server_End(params, abilityDefs, initPlayer)
        end

    end)

end

------------------------------------------------------------------------------------------------------------------------------
--// Execute -----------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
function RadiusAttack.Execute(params, abilityDefs)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    if not initPlayer then
        return
    end

    local abilityMod = require(abilityDefs.AbilityMod)

    if abilityMod.HitDelay then wait(abilityMod.HitDelay) end

    abilityMod.Client_Start(params, abilityDefs, initPlayer)

    for count = 1, abilityMod.TickCount do
        wait(abilityMod.TickTime)
        abilityMod.Client_Tick(params, abilityDefs, initPlayer, hitCharacters)
    end

    abilityMod.Client_End(params, abilityDefs, initPlayer, hitCharacters)

end


return RadiusAttack