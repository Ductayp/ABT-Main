-- DamageOverTime

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local DamageOverTime = {}

function DamageOverTime.Server_ApplyEffect(initPlayer, hitCharacter, effectParams, hitParams)

    for count = 1, effectParams.TickCount do
        require(Knit.HitEffects.Damage).Server_ApplyEffect(initPlayer, hitCharacter, effectParams, hitParams)
        wait(effectParams.TickLength)
    end

end

function DamageOverTime.Client_RenderEffect(params)


end


return DamageOverTime