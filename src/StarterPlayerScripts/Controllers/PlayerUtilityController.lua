-- PlayerUtilityController

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local PlayerUtilityController = Knit.CreateController { Name = "PlayerUtilityController" }
local PlayerUtilityService = Knit.GetService("PlayerUtilityService")
local pingTime = require(Knit.Shared.PingTime)
local utils = require(Knit.Shared.Utils)

PlayerUtilityController.PlayerAnimations = {} -- PLayerUtilityService populates a players entries everyt ime it loads animations

--// GetPing - gets the local players ping
function PlayerUtilityController:GetPing()

    local playerValueObject = ReplicatedStorage.PlayerPings[Players.LocalPlayer.UserId]
    return playerValueObject.Value
end


function PlayerUtilityController:KnitStart()
    Players.LocalPlayer.CameraMaxZoomDistance = 30
end

function PlayerUtilityController:KnitInit()

    PlayerUtilityService.Event_PlayerUtility:Connect(function(animationsTable, two)
        -- empty remote event
    end)
end

return PlayerUtilityController