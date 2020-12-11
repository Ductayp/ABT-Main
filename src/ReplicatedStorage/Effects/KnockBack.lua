-- KNock Back Effect
-- PDab
-- 12-9-2020

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


local KnockBack = {}

function KnockBack.Server_ApplyEffect(hitCharacter,params)

    print("lets go!!!")

    -- just a final check to be sure were hitting a humanoid
    if hitCharacter:FindFirstChild("Humanoid") then

        local velocityX = params.LookVector.X * params.Force
        local velocityZ = params.LookVector.Z * params.Force
        local velocityY = 5

        -- add the body mover
        local newBodyVelocity = Instance.new("BodyVelocity")
        newBodyVelocity.MaxForce = Vector3.new(500000,500000,500000)
        newBodyVelocity.P = 1000000
        newBodyVelocity.Velocity =  Vector3.new(velocityX,velocityY,velocityZ)
        newBodyVelocity.Parent = hitCharacter.HumanoidRootPart
        Debris:AddItem(newBodyVelocity,params.Duration)

        -- send the visual effects to all clients
        local effectParams = {}
        effectParams.HitCharacter = hitCharacter
        effectParams.Duration = params.Duration
        Knit.Services.PowersService:RenderEffect_AllPlayers("KnockBack",effectParams)
    end

end

function KnockBack.Client_RenderEffect(params)

    local newParticle = ReplicatedStorage.EffectParts.Effects.KnockBack.ParticleEmitter:Clone()
    newParticle.Parent = params.HitCharacter.UpperTorso
    Debris:AddItem(newParticle,5)

    spawn(function()
        wait(2)
        newParticle.Rate = 0
    end)
end


return KnockBack