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
local HttpService = game:GetService("HttpService")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local InventoryService = Knit.CreateService { Name = "InventoryService", Client = {}}
local RemoteEvent = require(Knit.Util.Remote.RemoteEvent)

-- modules
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)

-- Sacrifice Constants
local SACRIFICE_BONUS_COMMON = 0 -- none
local SACRIFICE_BONUS_RARE = 1
local SACRIFICE_BONUS_LEGENDARY = 5

--// GiveItemToPlayer
function InventoryService:GiveItemToPlayer(player, params)

    -- get the players data
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

    -- Regular Items
    if params.DataCategory == "ItemInventory" then

        -- give the default value of 1 or give the amount in params.Value
        local value = 1 
        if params.Value then
            value = params.Value
        end

        --check if we have a range of values possible, if so, valulate it
        if params.MinValue ~= nil and params.MaxValue ~= nil then
            value = math.random(params.MinValue,params.MaxValue)
        end

        -- add the value to the players data
        if not playerData.ItemInventory[params.DataKey] then
            playerData.ItemInventory[params.DataKey] = 0
        end

        if Knit.Services.GamePassService:Has_GamePass(player, "DoubleCash") then
            value = value * 2
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
    if playerData.CurrentStand.Power == "Standless" then
        -- yes we can get a new stand!
    else
        print("you must be standless to use an arrow!")
        return
    end


    -- check if the player has this arrow
    for index,dataArrow in pairs(playerData.ArrowInventory) do
        if dataArrow.Type == params.Type then
            if dataArrow.Rarity == params.Rarity then

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

                print("NOW YOU GET A STANDO!")
                local newParams = {}
                newParams.Power = pickedStand
                newParams.Rarity = params.Rarity
                newParams.Xp = 1
                newParams.GUID = HttpService:GenerateGUID(false)

                Knit.Services.PowersService:GivePower(player,newParams)

                -- fire Show_StandReveal to the player, we do this after we set the data because the Gui pudates based on current data
                Knit.Services.GuiService:Update_Gui(player, "StandReveal")

                return
            end
        end
    end
end

--// StoreStand
function InventoryService:StoreStand(player)

    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

    if playerData.CurrentStand.Power == "Standless" then
        print("You cant store STANDLESS, you noob!")
        return
    end

    -- count the number of stands stored
    local count = 0
    for _,stand in pairs(playerData.StandStorage.StoredStands) do
        count = count + 1
    end

    -- only store if theres room left
    if count < playerData.StandStorage.MaxSlots then

        -- insert the stand into storage
        table.insert(playerData.StandStorage.StoredStands, playerData.CurrentStand)
        --playerData.StandStorage.StoredStands[playerData.CurrentStand.GUI] = playerData.CurrentStand
        
        -- give the player the Standless power
        local newParams = {}
        newParams.Power = "Standless"
        Knit.Services.PowersService:GivePower(player, newParams)

    end
end

--// SacrificeStand
function InventoryService:SacrificeStand(player, GUID)

    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

    --find the stand by GUID and set some variable we need
    local thisIndex
    for index,stand in pairs(playerData.StandStorage.StoredStands) do
        if stand.GUID == GUID then
            thisPower = stand.Power
            thisIndex = index
            thisXp = stand.Xp
            thisRarity = stand.Rarity
            break
        end
    end

    -- remove the stand from storage
    table.remove(playerData.StandStorage.StoredStands, thisIndex)

    local findPowerModule = Knit.Powers:FindFirstChild(thisPower)
    if findPowerModule then
        powerModule = require(findPowerModule)

        -- get the values
        local level = powerUtils.GetLevelFromXp(thisXp)
        local unmodifiedValue = level * powerModule.Defs.BaseSacrificeValue
        print(powerModule.Defs.BaseSacrificeValue)
        print("unmodifiedValue",unmodifiedValue)
        local finalValue = 0
        if thisRarity == "Common" then
            finalValue = unmodifiedValue + (unmodifiedValue * SACRIFICE_BONUS_COMMON)
        elseif thisRarity == "Rare" then
            finalValue = unmodifiedValue + (unmodifiedValue * SACRIFICE_BONUS_RARE)
        elseif thisRarity == "Legendary" then
            finalValue = unmodifiedValue + (unmodifiedValue * SACRIFICE_BONUS_LEGENDARY)
        end

        local params = {}
        params.DataCategory = "ItemInventory"
        params.DataKey = "SoulOrb"
        params.Value = finalValue

        print("finaValue",finalValue)
        
        self:GiveItemToPlayer(player, params)

        print(playerData)
        
    end

    -- update the GUI
    Knit.Services.GuiService:Update_Gui(player, "StoragePanel")

end

---------------------------------------------------------------------------------------------
--// CLIENT METHODS
---------------------------------------------------------------------------------------------

--// Client:StoreStand
function InventoryService.Client:StoreStand(player)
    self.Server:StoreStand(player)
end

--// Client:SacrificeStand
function InventoryService.Client:SacrificeStand(player, GUID)
    self.Server:SacrificeStand(player, GUID)
end


--// KnitStart
function InventoryService:KnitStart()

end

--// KnitInit
function InventoryService:KnitInit()

end


return InventoryService