-- Item Spawn Service
-- PDab
-- 12/14/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local ItemSpawnService = Knit.CreateService { Name = "ItemSpawnService", Client = {}}
local RemoteEvent = require(Knit.Util.Remote.RemoteEvent)

-- events
ItemSpawnService.Client.Item_Spawned = RemoteEvent.new()

-- modules
local utils = require(Knit.Shared.Utils)

-- constants
local INITIAL_WAIT = 5
local SPAWN_LOOP_TIME = 20 

-- variables & stuff :)
ItemSpawnService.CanSpawn = false
ItemSpawnService.Spawners = {} -- an array that holds all spawners
--ItemSpawnService.SpawnerGroups = {} -- an array of folders in workspace that represent the Spawner Groups

--------------------------------------------------------------------------------------------------------------------------
--// SPAWNER ---------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------

--// DoSpawns --------------------------------------------------------------------------------------------
function ItemSpawnService:DoSpawns()

    --

    --[[
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

                -- now pick an open spawner from that table and assign it tot he variable: pickedSpawner
                local randomPick = math.random(1,#openSpawners)
                local pickedSpawner = openSpawners[randomPick]


                -- if pickedSpawner is not nil, lets spawn an item
                if pickedSpawner ~= nil then

                    -- get the total weights
                    local totalWeight = 0
                    for key,tableObject in pairs(spawnTable.Items) do
                        totalWeight = totalWeight + tableObject.Weight
                    end

                    -- pick an item based on weights
                    local Chance = math.random(1,totalWeight)
                    local Counter = 0
                    local pickedItem
                    for key,itemDefs in pairs(spawnTable.Items) do
                        Counter = Counter + itemDefs.Weight
                        if Chance <= Counter then
                            pickedItem = itemDefs -- sets the picked item as the table of values of that object
                            break
                        end
                    end

                    -- spawn the item
                    self:SpawnItem(pickedSpawner, pickedItem, groupFolder)

                end
            end
        end
    end
    ]]--
end

--// SpawnItem --------------------------------------------------------------------------------------------
function ItemSpawnService:SpawnItem(spawner, itemDefs, groupFolder)

    -- spawn item
    local item = itemDefs.Model:Clone()
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
                self:GiveItem(player, itemDefs.Params)
                self:DestroyItem(item)
                spawner.ItemPointer.Value = nil
                
            end
        end
    end)

    -- check which players has ItemFinderAccess and then fire event to them
    for _, player in pairs(Players) do
        if require(Knit.StateModules.ItemFinderAccess).HasAccess(player) then
            self.Client.Item_Spawned:Fire(player, item)
        end
    end


end
    

--// DestroyItem --------------------------------------------------------------------------------------------
function ItemSpawnService:DestroyItem(item)

    item:FindFirstChild("TouchInterest"):Destroy()

    item.Transparency = 1
    for _,v in pairs(item:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Transparency = 1
        end

        if v:IsA("ParticleEmitter") then
            v.Enabled = false
        end

        if v.Name == "Destroy_Particle" then
            spawn(function()
                v.Enabled = true
                wait(1)
                v.Enabled = false
            end)
        end
    end

    require(Knit.PowerUtils.WeldedSound).NewSound(item, ReplicatedStorage.Audio.ItemSpawnService.ItemPickup)

    Debris:AddItem(item, 10)
end

--// GiveItem --------------------------------------------------------------------------------------------
function ItemSpawnService:GiveItem(player, itemParams)

    -- always give at least 1 as the value
    local value = 1

    if itemParams.Value then
        value = itemParams.Value
    end

    --check if we have a range of values possible, if so, valuate it
    if itemParams.MinValue ~= nil and itemParams.MaxValue ~= nil then
        value = math.random(itemParams.MinValue, itemParams.MaxValue)
    end

    if itemParams.DataCategory == "StandExperience" then
        Knit.Services.PowersService:AwardXp(player, value)

    elseif itemParams.DataCategory == "Currency" then
        Knit.Services.InventoryService:Give_Currency(player, itemParams.DataKey, value, "ItemSpawn")

    elseif  itemParams.DataCategory == "Item" then
        Knit.Services.InventoryService:Give_Item(player, itemParams.DataKey, 1)
    else    
        print("This spawn item had no matching DataCategory. Nothing given to player")
    end
    
end

--------------------------------------------------------------------------------------------------------------------------
--// ITEM FINDER ---------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------

--// Toggle_Finder --------------------------------------------------------------------------------------------
function ItemSpawnService:Toggle_Finder(player, boolean)

    --[[
    -- get the players data
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

    -- check if player has the game pass
    if GamePassService:Has_GamePass(player, "ItemFinder") then
        print(player, " Has the Item Finder Pass!")
    else
        print(player, " NOPE! You dont have Item Finder Pass")
        playerData.ItemFinder.FinderOn = false -- set it false just to be sure
        return
    end

    -- set the boolean in the player data
    playerData.ItemFinder.FinderOn = boolean

    -- wait for the player character
    repeat wait() until player.Character

    -- create or destroy the attachment in the players HumanoidRootPart based on the boolean sent
    if boolean == true then
        local oldAttachment = player.Character:FindFirstChild("ItemFinder_Attachment", true)
        if oldAttachment then
            oldAttachment:Destroy()
        end
        local newAttachment = Instance.new("Attachment")
        newAttachment.Parent = player.Character.HumanoidRootPart
        newAttachment.Name = "ItemFinder_Attachment"
    else
        local oldAttachment = player.Character:FindFirstChild("ItemFinder_Attachment", true)
        if oldAttachment then
            oldAttachment:Destroy()
        end
    end
    ]]--

end

--//  Toggle_ItemInFinder --------------------------------------------------------------------------------------------
function ItemSpawnService:Toggle_ItemInFinder(player, itemKey)

 
end

--// Client:Toggle_Finder --------------------------------------------------------------------------------------------
function ItemSpawnService.Client:Toggle_Finder(player, boolean)
    self.Services:Toggle_Finder(player, boolean)
end

--//  Client:Toggle_ItemInFinder --------------------------------------------------------------------------------------------
function ItemSpawnService.Client:Toggle_ItemInFinder(player, itemKey)
    self.Services:Toggle_ItemInFinder(player, itemKey)
end

--------------------------------------------------------------------------------------------------------------------------
--// KNIT ---------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------

--// KnitStart -----------------------------------------------------------------------------------------------
function ItemSpawnService:KnitStart()

    -- main spawner loop
    spawn(function()

        -- initial wait before we begin spawning
        wait(INITIAL_WAIT)
        ItemSpawnService.CanSpawn = true

        while game:GetService("RunService").Heartbeat:Wait() do

            if ItemSpawnService.CanSpawn == true then
                self:DoSpawns()
            end

            wait(SPAWN_LOOP_TIME)
        end
    end)
end

--// KnitInit -----------------------------------------------------------------------------------------------
function ItemSpawnService:KnitInit()

    -- create a spawned items folder
    local spawnedItemsFolder = Instance.new("Folder")
    spawnedItemsFolder.Name = "SpawnedItems"
    spawnedItemsFolder.Parent = groupFolder

    -- setup all the spawners
    for _, instance in pairs(Workspace:GetDescendants()) do
        if instance.Name == "ItemSpawnService" then
            for _, groupFolder in pairs(object:GetChildren()) do
                for _, spawner in pairs(groupFolder:GetChildren()) do
                    if spawner:IsA("Part") then
                        spawner.Transparency = 1
                        spawner:SetAttribute("SpawnGroupId", groupFolder.Name)
                        spawner:SetAttribute("Spawned", false)
                        table.insert(ItemSpawnService.Spawners, spawner)
                    end
                end
            end
        end
    end

    --[[

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

    ]]--
end

return ItemSpawnService