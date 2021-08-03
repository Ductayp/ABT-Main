-- RunFunction

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local RunFunctions = {}

function RunFunctions.Server_ApplyEffect(initPlayer, hitCharacter, effectParams, hitParams)

    print("TEST YES", hitParams)

    for i, functionParams in pairs(effectParams) do

        functionParams.Arguments.HitCharacter = hitCharacter
        functionParams.Arguments.InitPlayer = initPlayer
        functionParams.Arguments.HitParams = hitParams

        spawn(function()
            if functionParams.RunOn == "Server" then

                local thisScript = require(functionParams.Script)
                thisScript[functionParams.FunctionName](functionParams.Arguments)
            end
    
            if functionParams.RunOn == "Client" then
    
                Knit.Services.PowersService:RenderHitEffect_AllPlayers("RunFunctions", functionParams)
    
            end
        end)

    end
    
end

function RunFunctions.Client_RenderEffect(params)

    local thisScript = require(params.Script)
    thisScript[params.FunctionName](params.Arguments)

end


return RunFunctions