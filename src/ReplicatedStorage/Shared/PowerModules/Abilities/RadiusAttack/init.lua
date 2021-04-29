-- Basic Projectile
-- PDab
-- 11-27-2020

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local AbilityToggle = require(Knit.PowerUtils.AbilityToggle)
local ManageStand = require(Knit.Abilities.ManageStand)
local Cooldown = require(Knit.PowerUtils.Cooldown)
local MobilityLock = require(Knit.PowerUtils.MobilityLock)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)
local hitboxMod = require(Knit.Shared.RaycastProjectileHitbox)


local RadiusAttack = {}

--// --------------------------------------------------------------------
--// Handler Functions
--// --------------------------------------------------------------------

--// Initialize
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

    RadiusAttack.Setup(params, abilityDefs)

end

--// Activate
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

    -- tween hitbox
    RadiusAttack.Run_Server(params, abilityDefs)

end

--// Execute
function RadiusAttack.Execute(params, abilityDefs)

    -- tween effects
	RadiusAttack.Run_Client(params, abilityDefs)

end


--// --------------------------------------------------------------------
--// Ability Functions
--// --------------------------------------------------------------------

function RadiusAttack.Setup(params, abilityDefs)

end

function RadiusAttack.Run_Server(params, abilityDefs)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    --print("initPlayer", initPlayer)

    local abilityMod = require(abilityDefs.AbilityMod)

    if abilityMod.HitDelay then wait(abilityMod.HitDelay) end
    
    local hitCharacters = {}
    -- hit all players in range, subject to immunity
    for _, player in pairs(game.Players:GetPlayers()) do
        if player:DistanceFromCharacter(initPlayer.Character.Head.Position) <= abilityMod.Range then
            if player ~= initPlayer then
                if not require(Knit.StateModules.Invulnerable).IsInvulnerable(player) then
                    table.insert(hitCharacters, player.Character)
                end
            end
        end
    end

    -- hit all Mobs in range
    for _,mob in pairs(Knit.Services.MobService.SpawnedMobs) do
        if initPlayer:DistanceFromCharacter(mob.Model.HumanoidRootPart.Position) <= abilityMod.Range then
            table.insert(hitCharacters, mob.Model)
        end
    end

    -- hit all dummies
    for _, dummy in pairs(Workspace.Dummies:GetChildren()) do
        if initPlayer:DistanceFromCharacter(dummy.HumanoidRootPart.Position) <= abilityMod.Range then
            table.insert(hitCharacters, dummy)
        end
    end

    params.HitCharacters = hitCharacters
    --params.Test = true

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

function RadiusAttack.Run_Client(params, abilityDefs)

    print("YESSS!", params, abilityDefs)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    if not initPlayer then
        return
    end

    -- setup the stand, if its not there then make it
	abilityDefs.TargetStand = Workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
	if not abilityDefs.TargetStand then
		abilityDefs.TargetStand = ManageStand.QuickRender(params)
    end

    local abilityMod = require(abilityDefs.AbilityMod)

    if abilityMod.HitDelay then wait(abilityMod.HitDelay) end

    if abilityMod.Server_Start then
        abilityMod.Client_Start(params, abilityDefs, initPlayer)
    end

    for count = 1, abilityMod.TickCount do
        wait(abilityMod.TickTime)
        if abilityMod.Server_Tick then
            abilityMod.Client_Tick(params, abilityDefs, initPlayer, hitCharacters)
        end
    end

    if abilityMod.Server_End then
        abilityMod.Client_End(params, abilityDefs, initPlayer, hitCharacters)
    end



end


return RadiusAttack