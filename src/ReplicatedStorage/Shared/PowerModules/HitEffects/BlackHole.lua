-- BlackHole

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local BlackHole = {}

function BlackHole.Server_ApplyEffect(initPlayer, hitCharacter, params)

    local hitPlayer = utils.GetPlayerFromCharacter(hitCharacter)
    if hitPlayer then
        Knit.Services.PowersService:ForceRemoveStand(hitPlayer)
    end
    
    params.HitCharacter = hitCharacter
    Knit.Services.PowersService:RenderHitEffect_AllPlayers("BlackHole", params)
end

function BlackHole.Client_RenderEffect(params)

    if not params.HitCharacter then
        return
    end

    local effectHolder = ReplicatedStorage.EffectParts.Effects.BlackHole.Holder:Clone()
    effectHolder.CFrame = params.HitCharacter.HumanoidRootPart.CFrame
    effectHolder.Parent = Workspace.RenderedEffects

    effectHolder.BurstEmitter:Emit(200)
    
    for i,v in pairs(params.HitCharacter:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Decal") then
            if v.Name ~= "HumanoidRootPart" then
                v.Transparency = 1
            end
        end
    end

    wait(params.Duration)

    for i,v in pairs(params.HitCharacter:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Decal") then
            if v.Name ~= "HumanoidRootPart" then
                v.Transparency = 0
            end
        end
    end

    for i, v in pairs(effectHolder:GetChildren()) do
        if v:IsA("ParticleEmitter") then
            v.Enabled = false
        end
    end

    wait(5)
    effectHolder:Destroy()


 

end


return BlackHole