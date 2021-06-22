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

local RunFunction = {}

function RunFunction.Server_ApplyEffect(initPlayer, hitCharacter, params)

    if params.RunOn == "Server" then

        local thisScript = require(params.Script)
        thisScript[params.FunctionName](params.FunctionParams)
    end

    if params.RunOn == "Client" then
        Knit.Services.PowersService:RenderHitEffect_AllPlayers("RunFunction", params)
    end
    
end

function RunFunction.Client_RenderEffect(params)

    local thisScript = require(params.Script)
    thisScript[params.FunctionName](params.FunctionParams)

end


return RunFunction