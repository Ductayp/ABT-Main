-- Data Replcaition Service
-- PDab
-- 11/4/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- requires not inside Knit framework
local dataService = require(game:GetService("ServerScriptService").GameFiles.External.DataService)

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local DataReplicationService = Knit.CreateService { Name = "DataReplicationService", Client = {}}



--// UpdateAll -- updates all the values from datastores
function DataReplicationService:UpdateAll(player)
    print("replicate it!")
    local replicatedFolder = ReplicatedStorage:WaitForChild("ReplicatedPlayerData")
    local playerFolder replicatedFolder:WaitForChild(player.UserId)
    
    local playerData = dataService.GetPlayerData(player)
    print(playerData)
    for i,v in pairs(playerData) do
        print(i,v)
    end
    --[[
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
            thisValueObject = utils.NewValueObject(key,value,playerFolder)
        else
            thisValueObject.Value = value
        end
    end
    ]]--
end

function DataReplicationService:PlayerAdded(player)
    local newFolder = Instance.new("Folder")
    newFolder.Name = player.UserId
    newFolder.Parent = ReplicatedStorage:WaitForChild("ReplicatedPlayerData")
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