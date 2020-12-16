-- Item Spawn Service
-- PDab
-- 12/14/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local ItemSpawnService = Knit.CreateService { Name = "ItemSpawnService", Client = {}}
local RemoteEvent = require(Knit.Util.Remote.RemoteEvent)

-- modules
local utils = require(Knit.Shared.Utils)

-- constants
local INITIAL_WAIT = 5
local SPAWN_LOOP_TIME = 1 -- is set at 1 for testing, but we should probbaly be much slower like 10 or more later on

-- variables & stuff :)
ItemSpawnService.CanSpawn = false
ItemSpawnService.SpawnerGroups = {} -- an array of folders in workspace that represent the Spawner Groups

function ItemSpawnService:DoSpawns()

    -- loop through all groups
    for _,groupFolder in pairs(ItemSpawnService.SpawnerGroups) do

        local findModule = Knit.ItemSpawnTables:FindFirstChild(groupFolder.Name) -- we have to be sure the folder has a matching module by name to prevent errors
        if findModule then
            local spawnTable = require(Knit.ItemSpawnTables[groupFolder.Name]) -- require the group table based on the folders name

            -- if the group hasnt reached is max spawned items, then we can spawn one
            local spawnedItems = groupFolder.SpawnedItems:GetChildren()
            local itemCount = #spawnedItems
            if itemCount < spawnTable.MaxSpawned then
                
                -- pick a random spawner from the group, using only spawner that are open
                local openSpawners = {}
                --local pickedSpawner = {}
                for _,spawner in pairs(groupFolder.Spawners:GetChildren()) do

                    local itemPointer = spawner:FindFirstChild("ItemPointer")
                    if not itemPointer then
                        itemPointer = Instance.new("ObjectValue")
                        itemPointer.Name = "ItemPointer"
                        itemPointer.Parent = spawner
                        itemPointer.Value = nil
                    end

                    -- only insert spawner with their itemPointer value as nil into a table
                    if itemPointer.Value == nil then
                        table.insert(openSpawners,spawner)
                    end
                    
                end

                -- now pick an open spawner fromt hat table and assign it tot he variable: pickedSpawner
                local randomPick = math.random(1,#openSpawners)
                local pickedSpawner = openSpawners[randomPick]


                -- if pickedSpawner is not nil, lets spawn an item
                if pickedSpawner ~= nil then

                    -- get the total weights
                    local totalWeight = 0
                    for key,value in pairs(spawnTable.Items) do
                        totalWeight = totalWeight + value
                    end

                    -- pick an item based on weights
                    local Chance = math.random(1,totalWeight)
                    local Counter = 0
                    local pickedItem
                    for key,value in pairs(spawnTable.Items) do
                        Counter = Counter + value
                        if Chance <= Counter then
                            pickedItem = key
                            break
                        end
                    end

                    -- spawn the item
                    self:SpawnItem(pickedSpawner, pickedItem, groupFolder)

                end
            end
        end
    end
end

function ItemSpawnService:SpawnItem(spawner,itemKey, groupFolder)

    print("spawning")

    -- spawn item
    local item = ReplicatedStorage.SpawnItems[itemKey]:Clone()
    item.Parent = groupFolder.SpawnedItems
    item.CFrame = spawner.CFrame

    -- set BodyMovers
    local bodyPosition = item:FindFirstChild("BodyPosition")
    if bodyPosition then
        bodyPosition.Position = spawner.Position
        item.Anchored = false
    end


    -- set pointer
    spawner.ItemPointer.Value = item

    -- create a new TouchInterest
    local connection = item.Touched:Connect(function(hit)

        if hit.Parent:FindFirstChild("Humanoid") then
            local player = utils.GetPlayerFromCharacter(hit.Parent)
            if player then

                local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
                if not playerData.ItemInvetory[itemKey] then
                    playerData.ItemInvetory[itemKey] = 0
                end
                playerData.ItemInvetory[itemKey] += 1

                Knit.Services.DataReplicationService:UpdateAll(player)

                spawner.ItemPointer.Value = nil

                item:Destroy()
            end
        end

    end)


end


--// KnitStart
function ItemSpawnService:KnitStart()

    -- a testing print
    --for i,v in pairs(ItemSpawnService.SpawnerGroups) do
        --print(i,v)
    --end

    -- main spawner loop
    spawn(function()
        -- initial wait before we begin spawning
        wait(INITIAL_WAIT)
        ItemSpawnService.CanSpawn = true

        while true do
            wait(SPAWN_LOOP_TIME)
            if ItemSpawnService.CanSpawn == true then
                self:DoSpawns()
            end
        end
    end)

end

--// KnitInit
function ItemSpawnService:KnitInit()

    for _,object in pairs(Workspace:GetDescendants()) do
        if object.Name == "ItemSpawnService" then
            for _,groupFolder in pairs(object:GetChildren()) do
                
                --put the folders in a table for processing later
                table.insert(ItemSpawnService.SpawnerGroups,groupFolder)

                local spawnedItemsFolder = Instance.new("Folder")
                spawnedItemsFolder.Name = "SpawnedItems"
                spawnedItemsFolder.Parent = groupFolder

                for _,spawner in pairs(groupFolder.Spawners:GetChildren()) do
                    if spawner:IsA("Part") then
                        spawner.Transparency = 1
                    end
                end
            end
        end
    end



end


return ItemSpawnService