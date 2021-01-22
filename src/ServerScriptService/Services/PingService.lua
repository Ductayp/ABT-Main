-- Ping Service
-- PDab
-- 12/20/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local PingService = Knit.CreateService { Name = "PingService", Client = {}}
local RemoteEvent = require(Knit.Util.Remote.RemoteEvent)

-- modules
local pingTime = require(Knit.Shared.PingTime)
local utils = require(Knit.Shared.Utils)

-- variables
local pingUpdateTime = 1

function PingService:GetPing(player)
    return pingTime[player]
end


--// UpdatePingLoop
function PingService:UpdatePingLoop()

    spawn(function()
        while true do
            for _,player in pairs(Players:GetPlayers()) do
                ReplicatedStorage.PlayerPings[player.UserId].Value = pingTime[player]
            end
            wait(pingUpdateTime)
        end
    end) 
end


--// PlayerAdded
function PingService:PlayerAdded(player)
    
    local pingFolder = ReplicatedStorage:FindFirstChild("PlayerPings")
    if not pingFolder then
        pingFolder = Instance.new("Folder")
        pingFolder.Name = "PlayerPings"
        pingFolder.Parent = ReplicatedStorage
    end

    local playerValue = Instance.new("NumberValue")
    playerValue.Name = player.UserId
    playerValue.Parent = pingFolder
    playerValue.Value = 0

end

--// PlayerRemoved
function PingService:PlayerRemoved(player)
    ReplicatedStorage.PlayerPings[player.UserId]:Destroy()
end


--// KnitStart
function PingService:KnitStart()

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

        -- start the loop
        self:UpdatePingLoop()
end

--// KnitInit
function PingService:KnitInit()

end


return PingService