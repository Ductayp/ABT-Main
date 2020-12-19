-- Replcaition Controller - this is acomnpanion to ReplcaitionService
-- PDab
-- 12/18/2020

--// THIS IS INCOMPLETE AND NOT WORKING, ITS HERE INCASE WE WANT TO DO IT!

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local ReplicationController = Knit.CreateController { Name = "ReplicationController" }

local ReplicaController = require(ReplicatedStorage:FindFirstChild("ReplicaController", true))

-- instance references
local MainGui = Players.LocalPlayer.PlayerGui:WaitForChild("MainGui")
local ValueObjectFolder = ReplicatedStorage.ReplicatedPlayerData:WaitForChild(Players.LocalPlayer.UserId)

function ReplicationController:PlayerAdded(player)

    ReplicaController.ReplicaOfClassCreated(player.UserId, function(replica)
        print("TestReplica received! Value:", replica.Data.Value)
    
        replica:ListenToChange({"Value"}, function(new_value)
            print("Value changed:", new_value)
        end)
    end)
    
end


function ReplicationController:KnitStart()
    ReplicaController.RequestData()
end

function ReplicationController:KnitInit()
    Players.PlayerAdded:Connect(function(player)
        self:PlayerAdded(player)
    end)
end

return ReplicationController
