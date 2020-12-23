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

--// GiveItemToPlayer
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

    end

    -- Cash - fire Gui Updates
    if params.DataKey == "Cash" then
        Knit.Services.GuiService:Update_Gui(player, "Cash")
    end

    -- Arrows
    if params.DataCategory == "ArrowInventory" then

        local thisArrow = {}
        thisArrow.Type = params.DataKey
        thisArrow.Rarity = params.Rarity
        thisArrow.ArrowName = params.ArrowName

        table.insert(playerData.ArrowInventory, thisArrow)
        Knit.Services.GuiService:Update_Gui(player, "ArrowPanel")
        
    end
end

--// RemoveItemFromPlayer
function InventoryService:RemoveItemFromPlayer(player, params)

    -- get the players data
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

    if params.DataCategory == "ItemInvetory" then

    end

    if params.DataCategory == "ArrowInventory" then

    end


end

--// UseArrow
function InventoryService.Client:UseArrow(player, params)

    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

    -- check in player is standless
    if playerData.Character.CurrentPower == "Standless" then
        -- yes we can get a new stand!
    else
        print("you must be standless to use an arrow!")
        return
    end


    -- check if the player has this arrow
    for index,dataArrow in pairs(playerData.ArrowInventory) do
        if dataArrow.Type == params.Type then
            if dataArrow.Rarity == params.Rarity then
                --hasArrow = true
                print("NOW YOU GET A STANDO!")

                -- remove arrow and update GUI to remove arrow
                table.remove(playerData.ArrowInventory, index) -- remove the arrow
                Knit.Services.GuiService:Update_Gui(player, "ArrowPanel")

                -- get the arrow defs
                local arrowDefs = require(Knit.InventoryModules.ArrowDefs)
                local thisArrowDef = arrowDefs[params.Type]
                
                -- add stands to weighted table
                local pickTable = {}
                for name,weight in pairs(thisArrowDef) do
                    for count = 1,weight do
                        table.insert(pickTable,name)
                    end
                end

                local randomPick = math.random(1,#pickTable)
                local pickedStand = pickTable[randomPick]

                print(pickedStand)

                --self:GiveStand(player, params)

                return

            end
        end
    end

    --[[
    -- remove the arrow and do all the STUFF
    if hasArrow == true then
        
        Knit.Services.GuiService:Update_ArrowPanel(player) -- update the gui
        print("NOW YOU GET A STANDO!")
        local arrowDefs = require(Knit.InventoryModules.ArrowDefs)
        local thisArrowDef = arroweDefs[params.Type]
        self:GiveStand(player, params)
    end
    ]]--

end

--// GiveStand
function InventoryService:GiveStand(player, params)

end


--// KnitStart
function InventoryService:KnitStart()

end

--// KnitInit
function InventoryService:KnitInit()

end


return InventoryService