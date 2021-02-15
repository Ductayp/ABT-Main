-- PlayerUtilityController
-- PDab
-- 1/22/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")


-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local PlayerUtilityController = Knit.CreateController { Name = "PlayerUtilityController" }

-- Knit modules
local pingTime = require(Knit.Shared.PingTime)
local utils = require(Knit.Shared.Utils)

--// GetPing - gets the local players ping
function PlayerUtilityController:GetPing()

    local playerValueObject = ReplicatedStorage.PlayerPings[Players.LocalPlayer.UserId]
    return playerValueObject.Value
end


function PlayerUtilityController:KnitStart()
    Players.LocalPlayer.CameraMaxZoomDistance = 30
end

function PlayerUtilityController:KnitInit()

end

return PlayerUtilityController