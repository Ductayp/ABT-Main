--Depth of Field Effect
-- PDab
-- 12- 13-2020

-- applies a simple depth of field effect, has default params and can be given a duration

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)


local DepthOfField = {}

function DepthOfField.Server_ApplyEffect(initPlayer,hitCharacter, params)

    local player = utils.GetPlayerFromCharacter(hitCharacter)
    if player then
        Knit.Services.PowersService:RenderHitEffect_AllPlayers(player,"DepthOfField",params)
    end

end

function DepthOfField.Client_RenderEffect(params)

    spawn(function()

        local newDepthOfField = ReplicatedStorage.EffectParts.Effects.DepthOfField.Default:Clone()
        newDepthOfField.Name = "newDepthOfField"
        newDepthOfField.Parent = Lighting

        Debris:AddItem(newDepthOfField,params.Duration)

    end)
end


return DepthOfField