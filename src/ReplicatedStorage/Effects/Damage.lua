-- Damage Effect
-- PDab
-- 12-4-2020

-- applies both pracitcal effects such as actual damage in numbers as well as the visual effects

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)


local Damage = {}

function Damage.Server_ApplyDamage(initCharacter,hitCharacter,params)

    -- check if the initCharacter is owned by a player
    local initPlayer
    for _, player in pairs(Players:GetPlayers()) do
		if player.Character == initCharacter then
			initPlayer = player
		end
    end

    -- default actualDamage for NPCs and other sources BESIDES players
    local actualDamage = params.Damage
    
    -- if it is a player, lets get any modifiers they might have (right now this is a placeholder until we make ModifierService)
    if initPlayer ~= nil then
        -- get modifiers here,maybe from Modifier service
        local modifier = 0 -- temporary value here, late on we will have an actual check
        actualDamage = params.Damage + modifier
    end

    -- just a final check to be sure were hitting a humanoid
    if hitCharacter.Parent:FindFirstChild("Humanoid") then
        hitCharacter.Humanoid:TakeDamage(actualDamage)
    end

end

function Damage.Client_DamageEffects(initCharacter,hitCharacter,params)

end


return Damage