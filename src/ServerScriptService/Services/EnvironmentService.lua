-- EnvironmentService
-- PDab
-- 2/12/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local EnvironmentService = Knit.CreateService { Name = "EnvironmentService", Client = {}}

-- modules
local utils = require(Knit.Shared.Utils)

-- variables
EnvironmentService.CurrentCycle = "Day"
EnvironmentService.CycleTime = 600 -- 10 minutes in seconds
EnvironmentService.TransitionTime = 20
EnvironmentService.DayTime = 14.6
EnvironmentService.NightTime = 4.6

--// TweenClockTime
function EnvironmentService:TweenClockTime(time)

    local timeTween = TweenService:Create(Lighting, TweenInfo.new(EnvironmentService.TransitionTime),{ClockTime = time})
    timeTween:Play()
end

--// DayNightCycle
function EnvironmentService:DayNightCycle()

    -- start the loop
    spawn(function()
        while true do
            wait(EnvironmentService.CycleTime)
            print("TimeCycle")
            if EnvironmentService.CurrentCycle == "Day" then
                self:TweenClockTime(EnvironmentService.NightTime)
                EnvironmentService.CurrentCycle = "Night"
            else
                self:TweenClockTime(EnvironmentService.DayTime)
                EnvironmentService.CurrentCycle = "Day"
            end
        end
    end)
end

--// PlayerAdded
function EnvironmentService:PlayerAdded(player)

end

--// PlayerRemoved
function EnvironmentService:PlayerRemoved(player)

end

--// KnitStart
function EnvironmentService:KnitStart()
    self:DayNightCycle()
end

--// KnitInit
function EnvironmentService:KnitInit()

    -- Player Added event
    Players.PlayerAdded:Connect(function(player)
        self:PlayerAdded(player)
    end)

    -- Player Added event for studio tesing, catches when a player has joined before the server fully starts
    for _, player in ipairs(Players:GetPlayers()) do
        self:PlayerAdded(player)
    end

    -- Player Removing event
    Players.PlayerRemoving:Connect(function(player)
        self:PlayerRemoved(player)
    end)


end


return EnvironmentService