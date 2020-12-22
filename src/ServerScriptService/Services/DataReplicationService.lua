-- Data Replcaition Service
-- PDab
-- 11/4/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local DataReplicationService = Knit.CreateService { Name = "DataReplicationService", Client = {}}

--// UpdateCategory - updates a sigle cateory by overwriting value sor careting objects as needed
function DataReplicationService:UpdateCategory(player, categoryName)

    -- gate player data, return if the category doesnt exist
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    if not playerData[categoryName] then
        print("No playerdata with that category nae to replicate")
        return
    end

    -- get the players folder, create it if it doesnt exist
    local playerFolder = ReplicatedStorage.ReplicatedPlayerData:FindFirstChild(player.UserId)
    if not playerFolder then
        playerFolder = Instance.new("Folder")
        playerFolder.Name = player.UserId
        playerFolder.Parent = ReplicatedStorage.ReplicatedPlayerData
    end

    -- get the data category folder or make it if it doesnt exist
    local categoryFolder = playerFolder:FindFirstChild(categoryName)
    if not categoryFolder then
        categoryFolder = Instance.new("Folder")
        categoryFolder.Name = categoryName
        categoryFolder.Parent = playerFolder
    end

    -- General Update
    if categoryName == "General" then
        for key,value in pairs(playerData[categoryName]) do
            local NewValueObject = require(Knit.Shared.Utils).NewValueObject(key,value,categoryFolder)
        end
    end
    
    -- Character Update
    if categoryName == "Character" then
        for key,value in pairs(playerData[categoryName]) do
            local NewValueObject = require(Knit.Shared.Utils).NewValueObject(key,value,categoryFolder)
        end
    end

    -- ItemInventory Update
    if categoryName == "ItemInventory" then
        for key,value in pairs(playerData[categoryName]) do

            -- check for existign value object
            local existingObject
            for _,valueObject in pairs(categoryFolder:GetChildren()) do
                if valueObject.Name == key then
                    existingObject = valueObject
                    break
                end
            end

            -- if the object exists, update it and if not then make it
            if existingObject ~= nil then
                existingObject.Value = value
            else
                local NewValueObject = require(Knit.Shared.Utils).NewValueObject(key,value,categoryFolder)
            end
        end
    end

    -- ArrowInventory Update
    if categoryName == "ArrowInventory" then
        for arrowNumber,arrowTable in pairs(playerData[categoryName]) do

            -- check for existign arrow object
            local folderExists = false
            for _,arrowFolder in pairs(categoryFolder:GetChildren()) do
                if arrowFolder.Name == tostring(arrowNumber) then
                    folderExists = true
                    break
                end
            end

            -- if the object exists do nothing but add new arrows
            if folderExists == true then
                --print("arrow already exists in the folder")
            else
                --make a folder to hold the data for this arrow
                local newFolder = Instance.new("Folder")
                newFolder.Name = arrowNumber
                newFolder.Parent = categoryFolder

                -- create values in the folder
                for key,value in pairs(arrowTable) do
                    local NewValueObject = require(Knit.Shared.Utils).NewValueObject(key,value,newFolder)
                end
            end 
        end
    end
end

--// PlayerAdded
function DataReplicationService:PlayerAdded(player)
    -- spawn any setup stuff so we dont yield
    spawn(function()

        -- make sure the players data is loaded
    local playerDataStatuses = ReplicatedStorage:WaitForChild("PlayerDataLoaded")
    local playerDataBoolean = playerDataStatuses:WaitForChild(player.UserId)
    repeat wait(1) until playerDataBoolean.Value == true -- wait until the value is true, this is set by PlayerDataService when the data is fully loaded for this player
    
    -- build the categories
    self:UpdateCategory(player, "General")
    self:UpdateCategory(player, "Character")
    self:UpdateCategory(player, "ItemInventory")
    self:UpdateCategory(player, "ArrowInventory")

    end)
end

--// KnitStart
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