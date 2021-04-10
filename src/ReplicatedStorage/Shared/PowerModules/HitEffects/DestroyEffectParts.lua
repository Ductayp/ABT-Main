-- AngeloRock

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local AngeloRock = {}

function AngeloRock.Server_ApplyEffect(initPlayer, hitCharacter, params)

    local hitPlayer = utils.GetPlayerFromCharacter(hitCharacter)
    if hitPlayer then
        Knit.Services.PowersService:ForceRemoveStand(hitPlayer)
    end
    
    params.HitCharacter = hitCharacter
    Knit.Services.PowersService:RenderHitEffect_AllPlayers("AngeloRock", params)
end

function AngeloRock.Client_RenderEffect(params)

    if not params.HitCharacter then
        return
    end

    spawn(function()
        
        local effectHolder = ReplicatedStorage.EffectParts.Effects.AngeloRock.Holder:Clone()
        effectHolder.CFrame = params.HitCharacter.HumanoidRootPart.CFrame
        effectHolder.Parent = Workspace.RenderedEffects
        effectHolder.AngeloRock.Particles.BurstEmitter:Emit(200)
       

        effectHolder.AngeloRock.Transparency = 1
        local tweenIn_1 = TweenService:Create(effectHolder.AngeloRock, TweenInfo.new(.5),{Transparency = 0})
        tweenIn_1:Play()
    
        local hitPlayer = utils.GetPlayerFromCharacter(params.HitCharacter)
        if hitPlayer == Players.LocalPlayer then
            effectHolder.AngeloRock.CanCollide = false
        end

        wait(params.Duration)
        effectHolder.AngeloRock.Anchored = true
        local tweenOut_1 = TweenService:Create(effectHolder.AngeloRock, TweenInfo.new(1),{Size = Vector3.new(2,2,2)})
        local tweenOut_2 = TweenService:Create(effectHolder.AngeloRock, TweenInfo.new(1),{Position = effectHolder.AngeloRock.Position + Vector3.new(0,-10,0)})
        tweenOut_1:Play()
        tweenOut_2:Play()
        wait(2)
        effectHolder:Destroy()

    end)
 

end


return AngeloRock