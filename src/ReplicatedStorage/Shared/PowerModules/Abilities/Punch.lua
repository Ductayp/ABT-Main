-- Punch Ability
-- PDab
-- 12-1-2020

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local Players = game:GetService("Players")
--local Debris = game:GetService("Debris")
--local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
--local utils = require(Knit.Shared.Utils)
--local ManageStand = require(Knit.Abilities.ManageStand)

-- variables
local lastPunch = "Punch_2"

local Punch = {}

function Punch.Activate(initPlayer,params)

    if lastPunch == "Punch_1" then
        Knit.Services.PowersService.PlayerAnimations[initPlayer.UserId].Punch_2:Play()
        lastPunch = "Punch_2"
    else
        Knit.Services.PowersService.PlayerAnimations[initPlayer.UserId].Punch_1:Play()
        lastPunch = "Punch_1"
    end
    

end

function Punch.Execute(initPlayer,params)

    print("punch execute")

end

return Punch


