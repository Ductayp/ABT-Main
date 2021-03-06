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

-- modules
local utils = require(Knit.Shared.Utils)

-- constants
local INITIAL_WAIT = 5
local SPAWN_LOOP_TIME = 10

-- variables & stuff :)
ItemSpawnService.CanSpawn = false
ItemSpawnService.Spawners = {} -- an array that holds all spawners

--------------------------------------------------------------------------------------------------------------------------
--// SPAWNER ---------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------

--// DoSpawns --------------------------------------------------------------------------------------------
function ItemSpawnService:DoSpawns()


    for _, spawnerModule in pairs(script.ItemSpawnModules:GetChildren()) do

        -- reuqire this module
        local thisSpawnerModule = require(spawnerModule)
        
        -- if this spawnerModule is not reached maxed spawns, then do a spawn
        if thisSpawnerModule.TotalSpawned < thisSpawnerModule.MaxSpawned then

            local openSpawners = {}
            for _, spawner in pairs(thisSpawnerModule.Spawners:GetChildren()) do

                local isSpawned = spawner:GetAttribute("ItemSpawned")

                if not isSpawned then
                    spawner:SetAttribute("ItemSpawned", false)
                    isSpawned = false
                end

                if isSpawned == false then
                    table.insert(openSpawners, spawner)
                end
            end

            -- pick a spawner from the table
            local rand = math.random(1, #openSpawners)
            local pickedSpawner = openSpawners[rand]

            -- get the total weights
            local totalWeight = 0
            for key, tableObject in pairs(thisSpawnerModule.Items) do
                totalWeight = totalWeight + tableObject.Weight
            end

            -- pick an item based on weights
            local Chance = math.random(1,totalWeight)
            local Counter = 0
            local pickedItem
            for key, itemDefs in pairs(thisSpawnerModule.Items) do
                Counter = Counter + itemDefs.Weight
                if Chance <= Counter then
                    pickedItem = itemDefs -- sets the picked item as the table of values of that object
                    break
                end
            end

            -- spawn the item
            self:SpawnItem(pickedSpawner, pickedItem, thisSpawnerModule)

            -- clear the variable when we are done
            openSpawners = nil
        end
    end

end

--// SpawnItem --------------------------------------------------------------------------------------------
function ItemSpawnService:SpawnItem(spawner, itemDefs, spawnerModule)

    -- spawn item
    local item = itemDefs.Model:Clone()
    item.Parent = Workspace.SpawnedItems
    item.CFrame = spawner.CFrame

    -- set BodyMovers
    local bodyPosition = item:FindFirstChild("BodyPosition")
    if bodyPosition then
        bodyPosition.Position = spawner.Position
        item.Anchored = false
    end

    -- clone the beam
    local newBeam = ReplicatedStorage.EffectParts.ItemFinder.ItemBeam:Clone()
    newBeam.Parent = item
    newBeam.Enabled = false

    -- set MapZone for item
    item:SetAttribute("MapZone", spawnerModule.MapZone)

    -- increment the spawn groups counter
    spawnerModule.TotalSpawned = spawnerModule.TotalSpawned + 1

    spawner:SetAttribute("ItemSpawned", true)

    -- create a new TouchInterest
    local connection = item.Touched:Connect(function(hit)
        if hit.Parent:FindFirstChild("Humanoid") then
            local player = utils.GetPlayerFromCharacter(hit.Parent)
            if player then

                self:GiveItem(player, itemDefs.Params)
                self:DestroyItem(item)

                spawner:SetAttribute("ItemSpawned", false)

                spawnerModule.TotalSpawned = spawnerModule.TotalSpawned - 1

            end
        end
    end)

end
    

--// DestroyItem --------------------------------------------------------------------------------------------
function ItemSpawnService:DestroyItem(item)

    item:FindFirstChild("TouchInterest"):Destroy()
    item:FindFirstChild("ItemBeam"):Destroy()

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
        Knit.Services.InventoryService:Give_Xp(player, value)

    elseif itemParams.DataCategory == "Currency" then
        Knit.Services.InventoryService:Give_Currency(player, itemParams.DataKey, value, "ItemSpawn")

        local itemDefs = require(Knit.Defs.ItemDefs)
        local thisItemDef = itemDefs[itemParams.DataKey]

        local currencyName
        local iconName
        if itemParams.DataKey == "Cash" then
            currencyName = "Cash"
            iconName = "Cash"
        elseif itemParams.DataKey == "SoulOrbs" then
            currencyName = "Soul Orbs"
            iconName = "Orbs"
        end

        -- update notifications
        local notificationParams = {}
        notificationParams.Icon = "Item"
        notificationParams.Text = "Found Currency:<br/>" .. currencyName .. " x" .. tostring(value)
        Knit.Services.GuiService:Update_Notifications(player, notificationParams)

    elseif itemParams.DataCategory == "Item" then
        Knit.Services.InventoryService:Give_Item(player, itemParams.DataKey, value)

        local itemDefs = require(Knit.Defs.ItemDefs)
        local thisItemDef = itemDefs[itemParams.DataKey]

        -- update notifications
        local notificationParams = {}
        notificationParams.Icon = "Item"
        notificationParams.Text = "Found an Item:<br/>" .. thisItemDef.Name .. " x" .. tostring(value)
        Knit.Services.GuiService:Update_Notifications(player, notificationParams)

    elseif itemParams.DataCategory == "Boost" then
        if itemParams.Random then
            local randomPick = math.random(1, #itemParams.PickList)
            local pickedBoost = itemParams.PickList[randomPick]
            Knit.Services.BoostService:AddBoost(player, pickedBoost.Key, pickedBoost.Duration)

            -- update notifications
            local notificationParams = {}
            notificationParams.Icon = "Boost"
            notificationParams.Text = "You got BOOST: " .. pickedBoost.Duration .. " seconds of " .. pickedBoost.Name
            Knit.Services.GuiService:Update_Notifications(player, notificationParams)
        end
    else    
        warn("This spawn item had no matching DataCategory. ItemSpawnService:GiveItem(player, itemParams)", player, itemParams)
    end
    
end

--[[
--------------------------------------------------------------------------------------------------------------------------
--// ITEM FINDER ---------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------

--// Toggle_Finder --------------------------------------------------------------------------------------------
function ItemSpawnService:Toggle_Finder(player, boolean)

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
]]--


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
    spawnedItemsFolder.Parent = Workspace
    spawnedItemsFolder:SetAttribute("IgnoreProjectiles", true)

end

return ItemSpawnService