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

local KnockBack = {}

function KnockBack.Server_ApplyEffect(initPlayer, hitCharacter, params)

    -- just a final check to be sure were hitting a humanoid
    if hitCharacter:FindFirstChild("Humanoid") then

        -- body mover settings
        local velocityX
        local velocityZ
        local velocityY
        if params.LookVector then
            velocityX = params.LookVector.X * params.Force
            velocityZ = params.LookVector.Z * params.Force
        else
            local baseCFrame = initPlayer.Character.HumanoidRootPart.CFrame
            velocityX = baseCFrame.LookVector.X * params.Force
            velocityZ = baseCFrame.LookVector.Z * params.Force

        end
        if params.ForceY then
            velocityY = params.ForceY
        else
            velocityY = 20
        end

        -- add the body mover
        local newBodyVelocity = Instance.new("BodyVelocity")
        newBodyVelocity.MaxForce = Vector3.new(500000,500000,500000)
        newBodyVelocity.P = 1000000
        newBodyVelocity.Velocity =  Vector3.new(velocityX,velocityY,velocityZ)
        newBodyVelocity.Parent = hitCharacter.HumanoidRootPart

        if params.Duration then
            Debris:AddItem(newBodyVelocity,params.Duration)
        else
            Debris:AddItem(newBodyVelocity, 0.2)
        end
        
        
        -- send the visual effects to all clients
        params.HitCharacter = hitCharacter
        Knit.Services.PowersService:RenderHitEffect_AllPlayers("KnockBack",params)
    end

end

function KnockBack.Client_RenderEffect(params)

    -- trails
    local trail_1 = ReplicatedStorage.EffectParts.Effects.KnockBack.KnockBackTrail:Clone()
    --local trail_2 = ReplicatedStorage.EffectParts.Effects.KnockBack.KnockBackTrail:Clone()
    trail_1.Parent = params.HitCharacter.UpperTorso
    --trail_2.Parent = params.HitCharacter.Head
    trail_1.CFrame = params.HitCharacter.UpperTorso.CFrame
    --trail_2.CFrame = params.HitCharacter.Head.CFrame
    utils.EasyWeld(trail_1,params.HitCharacter.UpperTorso,trail_1)
    --utils.EasyWeld(trail_2,params.HitCharacter.Head,trail_2)

    Debris:AddItem(trail_1,1)
    --Debris:AddItem(trail_2,1)

    -- particles
    local newParticle = ReplicatedStorage.EffectParts.Effects.KnockBack.ParticleEmitter:Clone()
    newParticle.Parent = params.HitCharacter.UpperTorso
    Debris:AddItem(newParticle,5)

    spawn(function()
        wait(2)
        newParticle.Rate = 0
    end)
    

end


return KnockBack