-- RemoveStand

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local RemoveStand = {}

function RemoveStand.Server_ApplyEffect(initPlayer, hitCharacter, params)

    local hitPlayer = utils.GetPlayerFromCharacter(hitCharacter)
    if hitPlayer then
        Knit.Services.PowersService:ForceRemoveStand(hitPlayer)
        params.HitCharacter = hitCharacter
        --Knit.Services.PowersService:RenderHitEffect_AllPlayers("RemoveStand", params)
    end
    
end

function RemoveStand.Client_RenderEffect(params)


end


return RemoveStand