-- Poison Effect
-- PDab
-- 12-4-2020

-- simply anchors the character in place and removes their key input for powers. Used in timestop or freeze attacks

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

-- effect part
local poisonParticle = ReplicatedStorage.EffectParts.Effects.Poison.PoisonParticle

local Poison = {}

function Poison.Server_ApplyEffect(initPlayer, hitCharacter, effectParams, hitParams)

    print("Poison.Server_ApplyEffect", effectParams, hitParams)

    -- just a final check to be sure were hitting a humanoid
    if hitCharacter:FindFirstChild("Humanoid") then

        -- multiply damage based on passed params
        local actualDamage = effectParams.Damage * hitParams.DamageMultiplier

        effectParams.HideEffects = true

        spawn(function()
            for count = 1, effectParams.TickCount do
                -- do the damage
                require(Knit.HitEffects.Damage).Server_ApplyEffect(initPlayer, hitCharacter, effectParams, hitParams)

                wait(effectParams.TickTime)
            end
        end) 
    end

    -- send the visual effects to all clients
    local renderParams = {}
    renderParams.HitCharacter = hitCharacter
    renderParams.Duration = effectParams.TickTime * effectParams.TickCount
    Knit.Services.PowersService:RenderEffect_AllPlayers("Poison", renderParams)

end

function Poison.Client_RenderEffect(params)
    
    local newParticle = poisonParticle:Clone()
    newParticle.Parent = params.HitCharacter.HumanoidRootPart

    spawn(function()

        wait(params.Duration)
        newParticle.Rate = 0
        wait(5)
        newParticle:Destroy()
    
    end)

end


return Poison