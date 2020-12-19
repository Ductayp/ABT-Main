-- Replcaition Service - thi sis a wrapper for ReplicaService
-- PDab
-- 12/18/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local ReplicationService = Knit.CreateService { Name = "ReplicationService", Client = {}}

-- stuff
local ReplicaService = require(script.ReplicaService)

function ReplicationService:PlayerAdded(player)

    spawn(function()

        -- make sure the players data is loaded
        local playerDataStatuses = ReplicatedStorage:WaitForChild("PlayerDataLoaded")
        local playerDataBoolean = playerDataStatuses:WaitForChild(player.UserId)
        repeat wait(1) until playerDataBoolean.Value == true -- wait until the value is true

        -- getplayer data
        local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

        --
        ReplicaService.NewReplica({ClassToken = ReplicaService.NewClassToken(player.UserId), Data = playerData, Replication = "All",})
        print("Yeet added it!")

    end)
   


end




--// KnitInit
function ReplicationService:KnitInit()

    Players.PlayerAdded:Connect(function(player)
        self:PlayerAdded(player)
    end)
end


return ReplicationService