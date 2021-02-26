-- ItemSpawnController

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local ItemSpawnController = Knit.CreateController { Name = "ItemSpawnController" }
local ItemSpawnService = Knit.GetService("ItemSpawnService")

local utils = require(Knit.Shared.Utils)

function ItemSpawnController:ItemSpawned(params)

    print(params)

end

--// PlayerAdded
function ItemSpawnController:PlayerAdded(player)

end

--// PlayerRemoved
function ItemSpawnController:PlayerRemoved(player)

end


--// KnitStart
function ItemSpawnController:KnitStart()

    print("ItemSpawnService", ItemSpawnService)

    -- cnnect events
    ItemSpawnService.Item_Spawned:Connect(function(params)
        self:ItemSpawned(params)
    end)

end

--// KnitInit
function ItemSpawnController:KnitInit()

end

return ItemSpawnController