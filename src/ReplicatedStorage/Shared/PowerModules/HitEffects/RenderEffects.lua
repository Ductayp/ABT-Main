-- RenderEffects

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local RenderEffects = {}

function RenderEffects.Server_ApplyEffect(initPlayer, hitCharacter, params)

    Knit.Services.PowersService:RenderHitEffect_AllPlayers("RenderEffects", params)

end

function RenderEffects.Client_RenderEffect(params)

    for _, effect in pairs(params) do
        local thisScript = require(effect.Script)
        thisScript[effect.Function](effect.Arguments)
    end
    
end


return RenderEffects