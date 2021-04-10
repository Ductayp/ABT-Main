-- DestroyEffectParts

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local DestroyEffectParts = {}

function DestroyEffectParts.Server_ApplyEffect(initPlayer, hitCharacter, params)

    local hitPlayer = utils.GetPlayerFromCharacter(hitCharacter)
    if hitPlayer then
        Knit.Services.PowersService:ForceRemoveStand(hitPlayer)
    end
    
    params.HitCharacter = hitCharacter
    Knit.Services.PowersService:RenderHitEffect_AllPlayers("DestroyEffectParts", params)
end

function DestroyEffectParts.Client_RenderEffect(params)


 
end


return DestroyEffectParts