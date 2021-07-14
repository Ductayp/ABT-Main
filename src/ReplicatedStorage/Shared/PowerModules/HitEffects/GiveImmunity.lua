-- GiveImmunity

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local GiveImmunity = {}

function GiveImmunity.Server_ApplyEffect(initPlayer, hitCharacter, effectParams, hitParams)

    if not hitCharacter then return end
    if not hitCharacter:FindFirstChild("HumanoidRootPart") then return end

    if hitParams.IsMob then

        require(Knit.MobUtils.Immunity).Give_Duration(hitParams.MobId, effectParams.AbilityName, effectParams.Duration)
        
    else

    end



end

function GiveImmunity.Client_RenderEffect(params)


end


return GiveImmunity