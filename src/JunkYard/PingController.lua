-- PingController
-- PDab
-- 1/22/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")


-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local PingController = Knit.CreateController { Name = "PingController" }

-- Knit modules
local pingTime = require(Knit.Shared.PingTime)
local utils = require(Knit.Shared.Utils)

--// GetPing - gets the local players ping
function PingController:GetPing()

    local playerValueObject = ReplicatedStorage.PlayerPings[Players.LocalPlayer.UserId]
    return playerValueObject.Value
end


function PingController:KnitStart()
    
end

function PingController:KnitInit()

end

return PingController