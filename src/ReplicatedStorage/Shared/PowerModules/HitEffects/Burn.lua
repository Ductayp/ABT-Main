-- Burn

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local Burn = {}

--// Server_ApplyEffect
function Burn.Server_ApplyEffect(initPlayer, hitCharacter, effectParams, hitParams)

    --print("Burn.Server_ApplyEffect", effectParams, hitParams)

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
    renderParams.Color = effectParams.Color
    Knit.Services.PowersService:RenderHitEffect_AllPlayers("Burn", renderParams)

end

--// Client_RenderEffect
function Burn.Client_RenderEffect(params)

    local particle = ReplicatedStorage.EffectParts.Effects.Burn:FindFirstChild("Orange") -- default color green
    if params.Color then
        particle = ReplicatedStorage.EffectParts.Effects.Burn:FindFirstChild(params.Color)
    end

    local newParticle = particle:Clone()

    newParticle.Parent = params.HitCharacter.HumanoidRootPart

    spawn(function()
        wait(params.Duration)
        newParticle.Rate = 0
        wait(5)
        newParticle:Destroy()
    end)

end

return Burn