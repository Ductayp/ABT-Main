-- Inventory Service
-- PDab
-- 12/20/2020

-- this service is the single source of managing player inventory covering adding and removing items
-- it connects to modifier service so if a plyer has a modifier such as 2x Cash, sending the playeer 10 cash through a method here will give them 20
-- this service also manages container size, so a player may nto add items to a container that does not have any spaces left. 

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local InventoryService = Knit.CreateService { Name = "InventoryService", Client = {}}
local RemoteEvent = require(Knit.Util.Remote.RemoteEvent)

-- modules
local utils = require(Knit.Shared.Utils)

function InventoryService:GiveItemToPlayer(player, params)

    -- get the players data
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

    -- Regular Items
    if params.DataCategory == "ItemInventory" then

        -- by default, when you pick up an item, you get 1 of them
        local value = 1 

        --check if we have a range of values possible, if so, valulate it
        if params.MinValue and params.MaxValue then
            value = math.random(params.MinValue,params.MaxValue)
        end

        -- add the value to the players data
        if not playerData.ItemInventory[params.DataKey] then
            playerData.ItemInventory[params.DataKey] = 0
        end
        playerData.ItemInventory[params.DataKey] += value
        Knit.Services.DataReplicationService:UpdateCategory(player, params.DataCategory)

    end

    -- Arrows
    if params.DataCategory == "ArrowInventory" then

        local thisArrow = {}
        thisArrow.Type = params.DataKey
        thisArrow.Rarity = params.Rarity
        thisArrow.ArrowName = params.ArrowName

        table.insert(playerData.ArrowInventory, thisArrow)
        Knit.Services.DataReplicationService:UpdateCategory(player, params.DataCategory)

    end
end

function InventoryService:RemoveItemFromPlayer(player, params)

    -- get the players data
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

    if params.DataCategory == "ItemInvetory" then

    end

    if params.DataCategory == "ArrowInventory" then

    end


end


--// KnitStart
function InventoryService:KnitStart()

end

--// KnitInit
function InventoryService:KnitInit()

end


return InventoryService