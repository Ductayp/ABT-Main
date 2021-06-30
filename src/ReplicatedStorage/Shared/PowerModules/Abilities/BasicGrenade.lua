-- Basic Grenade Ability
-- PDab
-- 11-27-2020

-- this module requires a refernce to an AbilityMod script, it does not work alone

--Roblox Services
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
local RayHitbox = require(Knit.PowerUtils.RayHitbox)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)

local BasicGrenade = {}

--// --------------------------------------------------------------------
--// Handler Functions
--// --------------------------------------------------------------------

--// Initialize
function BasicGrenade.Initialize(params, abilityDefs)

	-- checks
	if params.KeyState == "InputBegan" then params.CanRun = true end
    if params.KeyState == "InputEnded" then params.CanRun = false return end
    if not Cooldown.Client_IsCooled(params) then params.CanRun = false return end
    if not Cooldown.Server_IsCooled(params) then params.CanRun = false return end
    if abilityDefs.RequireToggle_On then
        if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then params.CanRun = false return end
    end

    Cooldown.Client_SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)
    
end

--// Activate
function BasicGrenade.Activate(params, abilityDefs)

	-- checks
	if params.KeyState == "InputBegan" then params.CanRun = true end
    if params.KeyState == "InputEnded" then params.CanRun = false return end
    if not Cooldown.Server_IsCooled(params) then params.CanRun = false return end
    if abilityDefs.RequireToggle_On then
        if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then params.CanRun = false return end
    end

    Cooldown.Server_SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)

    -- block input
    require(Knit.PowerUtils.BlockInput).AddBlock(params.InitUserId, "BasicGrenade", 1.5)

    -- tween hitbox
    BasicGrenade.Run_Server(params, abilityDefs)

end

--// Execute
function BasicGrenade.Execute(params, abilityDefs)

    -- tween effects
	BasicGrenade.Run_Effects(params, abilityDefs)

end


--// --------------------------------------------------------------------
--// Ability Functions
--// --------------------------------------------------------------------

function BasicGrenade.Run_Server(params, abilityDefs)

    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

    -- get the abilitymod
    local abilityMod = require(abilityDefs.AbilityMod)

    --- make a new grenade
    local newGrenade = abilityMod.new(initPlayer)

    -- launch it
    abilityMod.Server_Launch(initPlayer, newGrenade)

    -- play the animation
    abilityMod.PlayAnimation(initPlayer)

    -- detonate it
    spawn(function()
        wait(newGrenade.DetonationDelay)

        -- add all players in range
        for _,player in pairs(Players:GetPlayers()) do
            if player:DistanceFromCharacter(newGrenade.MainPart.Position) <= newGrenade.HitRadius then
                table.insert(newGrenade.HitCharacters, player.Character)
            end
        end

        -- add all Mobs in range
        for _,mob in pairs(Knit.Services.MobService.SpawnedMobs) do
            local distance = (mob.Model.HumanoidRootPart.Position - newGrenade.MainPart.Position).magnitude
            if distance <= newGrenade.HitRadius then
                table.insert(newGrenade.HitCharacters, mob.Model)
            end
        end

        -- run the Server_Explode function
        abilityMod.Server_Explode(initPlayer, newGrenade)
        
        -- hit all the characters
        for _,hitCharacter in pairs(newGrenade.HitCharacters) do

            -- get the most up-to-date hiteffects
            abilityDefs.HitEffects = abilityMod.GetHitEffects(initPlayer, hitCharacter, newGrenade)
 
            -- apply the hit effects
            Knit.Services.PowersService:RegisterHit(initPlayer, hitCharacter, abilityDefs)
        end

        -- cleanup
        newGrenade.MainPart:Destroy()
        newGrenade = nil

    end)

    -- add it to params for the later phases    
    params.Grenade = newGrenade 
        
end

function BasicGrenade.Run_Effects(params, abilityDefs)

    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

    -- launch it
    local abilityMod = require(abilityDefs.AbilityMod)
    abilityMod.Client_Launch(initPlayer, params.Grenade)

    -- wait for detonation
    spawn(function()
        wait(params.Grenade.DetonationDelay)
        abilityMod.Client_Explode(initPlayer, params.Grenade)
    
    end)

end

return BasicGrenade


