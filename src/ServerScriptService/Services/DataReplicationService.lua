-- Data Replcaition Service
-- PDab
-- 11/4/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local DataReplicationService = Knit.CreateService { Name = "DataReplicationService", Client = {}}


--// UpdateAll -- updates all the values from datastores
function DataReplicationService:UpdateAll(player)
    print("update all")
    local replicatedFolder = ReplicatedStorage:WaitForChild("ReplicatedPlayerData")
    local playerFolder = replicatedFolder:WaitForChild(player.UserId)
    
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    if playerData then

        -- loop through the playe data and get only keys and values, insert in new dictionary
        local keyTable = {}
        local function loop(playerData)
            for key, value in pairs(playerData) do
                if type(value) == 'table'  then
                    loop(value)
                else
                    keyTable[key] = value
                end
            end
        end
        loop(playerData)

        for key,value in pairs(keyTable) do
            local thisValueObject = playerFolder:FindFirstChild(key)
            if not thisValueObject then
                thisValueObject = require(Knit.Shared.Utils).NewValueObject(key,value,playerFolder)
            else
                thisValueObject.Value = value
            end
        end
    end

end

--// BuildDataTable - called once when the playuer joins, builds their entire data table
function DataReplicationService:BuildDataTable(player)

    -- make sure the players data is loaded
    local playerDataStatuses = ReplicatedStorage:WaitForChild("PlayerDataLoaded")
    local playerDataBoolean = playerDataStatuses:WaitForChild(player.UserId)
    repeat wait(1) until playerDataBoolean.Value == true -- wait until the value is true, this is set by PlayerDataService when the data is fully loaded for this player
    
    -- makea folder for the players data
    local playerFolder = Instance.new("Folder")
    playerFolder.Name = player.UserId
    playerFolder.Parent = ReplicatedStorage.ReplicatedPlayerData

    -- build the table
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
   
    -- create category folders
    for key, value in pairs(playerData) do
        if type(value) == 'table'  then
            newFolder = Instance.new("Folder")
            newFolder.Name = key
            newFolder.Parent = playerFolder
        end
    end

    -- build simple categroies
    local basicCategories = {"General","Character","ItemInventory"}
    for _,category in pairs(basicCategories) do
        for key,value in pairs(playerData[category]) do
            NewValueObject = require(Knit.Shared.Utils).NewValueObject(key,value,playerFolder[category])
        end
    end
end

function DataReplicationService:PlayerAdded(player)

    -- spawn any setup stuff so we dont yield
    spawn(function()
        self:BuildDataTable(player)
    end)
    
end

function DataReplicationService:KnitStart()

end

--// KnitInit - runs at server startup
function DataReplicationService:KnitInit()

    -- setup the folder in ReplcatedStorage
    local NewFolder = Instance.new("Folder")
	NewFolder.Name = "ReplicatedPlayerData"
    NewFolder.Parent = ReplicatedStorage

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
        ReplicatedStorage.ReplicatedPlayerData:FindFirstChild(player.UserId):Destroy()
    end)

end

return DataReplicationService