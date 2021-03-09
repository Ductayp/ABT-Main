-- Inventory Service
-- PDab
-- 12/20/2020

-- this service is the single source of managing player inventory for adding and removing items
-- it connects to modifier service so if a plyer has a modifier such as 2x Cash, sending the playeer 10 cash through a method here will give them 20
-- this service also manages container size, so a player may not add items to a container that does not have any spaces left. 

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

--// Give_Currency ---------------------------------------------------------------------------------------------------------------------------
function InventoryService:Give_Currency(player, key, value, source)

    print("InventoryService:Give_Currency(player, key, value, source)", player, key, value, source)

    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

    -- do the 2x modifiers only if these didnt come from a dev product
    if source ~= "GamePassService" then 

        -- Double cash if they have the gamepass
        if key == "Cash" then
            local multiplier = require(Knit.StateModules.Multiplier_Cash).GetTotalMultiplier(player)
            value = value * multiplier
            print("multiplier is: ", multiplier)
            print("value is: ", value)
        end

        -- Double sould orbs if they have the gamepass
        if key == "SoulOrbs" then
            local multiplier = require(Knit.StateModules.Multiplier_Orbs).GetTotalMultiplier(player)
            value = value * multiplier
            print("multiplier is: ", multiplier)
            print("value is: ", value)
        end
    else
        print("Bought currency as a dev product, gamepass mutlipliers do not work!")
    end

    -- add it to the playerData
    playerData.Currency[key] += value

    -- update the gui
    Knit.Services.GuiService:Update_Gui(player, "Currency")

    local notificationParams = {}
    notificationParams.Icon = key
    notificationParams.Text = "You got: " .. tostring(value) .. " " .. key
    Knit.Services.GuiService:Update_Notifications(player, notificationParams)

end

--// Give_Item ---------------------------------------------------------------------------------------------------------------------------
function InventoryService:Give_Item(player, key, quantity)
    
    -- get player data
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

    -- get the defs
    local itemDefs = require(Knit.InventoryModules.ItemDefs)
    local thisItemDef = itemDefs[key]

    -- if theres no item with this key, then return
    if not thisItemDef then
        print("NO ITEM WITH THIS KEY")
        return
    end

    -- if the data key is nil, make an entry in the table
    if playerData.ItemInventory[key] == nil then
        print("playerData", playerData)
        print("key", key)
        playerData.ItemInventory[key] = 0
    end

    -- increment the key
    playerData.ItemInventory[key] += quantity

    -- update notifications
    local notificationParams = {}
    notificationParams.Icon = "Item"
    notificationParams.Text = "You got: " .. tostring(quantity) .. " " .. thisItemDef.Name
    Knit.Services.GuiService:Update_Notifications(player, notificationParams)

    -- update item panel
    Knit.Services.GuiService:Update_Gui(player, "ItemPanel")

end

function InventoryService:UseItem(player, key)
    print(player, " is trying to use: ", key)
end

function InventoryService.Client:UseItem(player, key)
    self.Server:UseItem(player, key)
end

--// UseArrow ---------------------------------------------------------------------------------------------------------------------------
function InventoryService:UseArrow(player)

    -- get player data
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

    -- check in player is standless
    if playerData.CurrentStand.Power == "Standless" then
        -- yes we can get a new stand!
    else
        print("you must be standless to use an arrow!")
        return
    end

    -- check if the player has an arrow to use
    if playerData.ItemInventory.Arrow == nil or playerData.ItemInventory.Arrow < 1 then
        print("tried to use arrow but there is no arrow in the players data")
        return
    end

    -- remove arrow and update GUI to remove arrow
    playerData.ItemInventory.Arrow = playerData.ItemInventory.Arrow - 1
    Knit.Services.GuiService:Update_Gui(player, "ItemPanel")

    -- get the arrow defs
    local arrowDefs = require(Knit.InventoryModules.ArrowDefs)

    -- add stands to weighted table
    local pickTable = {}
    for name, weight in pairs(arrowDefs) do
        for count = 1, weight do
            table.insert(pickTable,name)
        end
    end

    -- pick the stand
    local randomPick = math.random(1,#pickTable)
    local pickedStand = pickTable[randomPick]

    -- if player has the gamepass for arrow luck, give them a chance at better rarity
    local thisRarity
    local rand = math.random(1, 1000) / 10
    if Knit.Services.GamePassService:Has_GamePass(player, "ArrowLuck") then
        print("YES: arrow luck pass")
        if rand <= 90 then
            thisRarity = "Common" -- the default
        elseif rand <= 99 then
            thisRarity = "Rare"
        else
            thisRarity = "Legendary"
        end
    else
        print("NO: arrow luck pass")
        if rand <= 95 then
            thisRarity = "Common" -- the default
        elseif rand <= 99.5 then
            thisRarity = "Rare"
        else
            thisRarity = "Legendary"
        end
    end

    print("RAND: ", rand)
    print("thisRarity", thisRarity)

    local newParams = {}
    newParams.Power = pickedStand
    newParams.Rarity = thisRarity
    newParams.Xp = 1
    newParams.GUID = HttpService:GenerateGUID(false)

    -- set the current power
    Knit.Services.PowersService:SetCurrentPower(player,newParams)

    -- fire Show_StandReveal to the player
    Knit.Services.GuiService:Update_Gui(player, "StandReveal")

end

--// GiveBoost ---------------------------------------------------------------------------------------------------------------------------
function InventoryService:Give_Boost(player, key, duration)

        -- get player data
        local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
        if not playerData then return end

        local entry = {}
        entry.Key = key
        entry.Duration = duration

        table.insert(playerData.BoostInventory, entry)

        print(playerData.BoostInventory)

end

--// StoreStand ---------------------------------------------------------------------------------------------------------------------------
function InventoryService:StoreStand(player)

    -- sanity check to see if player has access
    local hasAcces = require(Knit.StateModules.StandStorageAccess).HasAccess(player)
    if Knit.Services.GamePassService:Has_GamePass(player, "MobileStandStorage") or hasAcces == true then
        -- yup were good
    else
        -- nope were not good
        return
    end

    -- get player data
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

        print("INventoryService",playerData.StandStorage.StoredStands)
        
        -- give the player the Standless power
        local newParams = {}
        newParams.Power = "Standless"
        Knit.Services.PowersService:SetCurrentPower(player, newParams)

        -- update the GUI
        --Knit.Services.GuiService:Update_Gui(player, "StoragePanel")

    end
end

--// GetStandValue ---------------------------------------------------------------------------------------------------------------------------
function InventoryService:GetStandValue(player, GUID)

    -- this methods returns this value, after its modified
    local finalValue = 0

    -- get player data
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

    --find the stand by GUID and set some variable we need
    local thisPower
    local thisIndex
    local thisXp
    local thisRarity
    for index,stand in pairs(playerData.StandStorage.StoredStands) do
        if stand.GUID == GUID then
            thisPower = stand.Power
            thisIndex = index
            thisXp = stand.Xp
            thisRarity = stand.Rarity
            break
        end
    end

    if thisPower then
        local findPowerModule = Knit.Powers:FindFirstChild(thisPower)
        if findPowerModule then
            local powerModule = require(findPowerModule)
    
            -- get the values
            local level = Knit.Services.PowersService:GetLevelFromXp(thisXp, thisRarity)
            finalValue = level * powerModule.Defs.SacrificeValue[thisRarity]
        end
    end

    return finalValue
end

--// SacrificeStand ---------------------------------------------------------------------------------------------------------------------------
function InventoryService:SacrificeStand(player, GUID)

    -- sanity check to see if player has access
    local hasAcces = require(Knit.StateModules.StandStorageAccess).HasAccess(player)
    if Knit.Services.GamePassService:Has_GamePass(player, "MobileStandStorage") or hasAcces == true then
        -- yup were good
    else
        -- nope were not good
        return
    end

    -- get player data
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

    -- get the stands value
    value = self:GetStandValue(player, GUID)

    -- give the currency
    self:Give_Currency(player, "SoulOrbs", value, "Sacrifice")

    -- remove the stand from storage
    for index,stand in pairs(playerData.StandStorage.StoredStands) do
        if stand.GUID == GUID then
            table.remove(playerData.StandStorage.StoredStands, index)
            break
        end
    end

    -- update the GUI
    Knit.Services.GuiService:Update_Gui(player, "StoragePanel")
    Knit.Services.GuiService:Update_Gui(player, "Currency")

end

--// EquipStand ---------------------------------------------------------------------------------------------------------------------------
function InventoryService:EquipStand(player, GUID)

    -- sanity check to see if player has access
    local hasAcces = require(Knit.StateModules.StandStorageAccess).HasAccess(player)
    if Knit.Services.GamePassService:Has_GamePass(player, "MobileStandStorage") or hasAcces == true then
    else
        print("You cant equip a stand: Either no Mobile Storage or you are not at Puccis")
        return
    end

    -- get player data
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

    -- save the current stand in a variable to store it after we equip the new one
    local tempStoredStand = playerData.CurrentStand

    --find the stand by GUID and set some variable we need
    for index,stand in pairs(playerData.StandStorage.StoredStands) do
        if stand.GUID == GUID then

            -- remove the old stand form storage
            table.remove(playerData.StandStorage.StoredStands, index)

            -- set the new stand
            Knit.Services.PowersService:SetCurrentPower(player, stand)

            -- store the tempStored stand
            if tempStoredStand.Power ~= "Standless" then
                table.insert(playerData.StandStorage.StoredStands, tempStoredStand)
            end
            break
        end
    end

    -- update the GUI
    --Knit.Services.GuiService:Update_Gui(player, "StoragePanel")

end

--// BuyStorage ---------------------------------------------------------------------------------------------------------------------------
function InventoryService:BuyStorage(player, params)

    -- get player data
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

    if playerData.Currency.Cash >= params.Cost then
        playerData.Currency.Cash = playerData.Currency.Cash - params.Cost
        playerData.StandStorage.MaxSlots += params.Slots
    end

    -- update the GUI
    Knit.Services.GuiService:Update_Gui(player, "StoragePanel")
    Knit.Services.GuiService:Update_Gui(player, "Currency")

end

--// GetCurrencyData ---------------------------------------------------------------------------------------------------------------------------
function InventoryService:GetCurrencyData(player)

    -- get player data
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    local currencyData = playerData.Currency

    print(playerData)
    print(currencyData)

    return currencyData
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

--// Client:GetStandValue
function InventoryService.Client:GetStandValue(player, GUID)
    local finalValue = self.Server:GetStandValue(player, GUID)
    return finalValue
end

--// Client:EquipStand
function InventoryService.Client:EquipStand(player, GUID)
    self.Server:EquipStand(player, GUID)
end

--// Client:UseArrow
function InventoryService.Client:UseArrow(player, params)
    self.Server:UseArrow(player, params)
end

--// Client:BuyStorage
function InventoryService.Client:BuyStorage(player, params)
    self.Server:BuyStorage(player, params)
end

--// Client:GetCurrencyData
function InventoryService.Client:GetCurrencyData(player)
    local currencyData = self.Server:GetCurrencyData(player)
    return currencyData
end


---------------------------------------------------------------------------------------------
--// KNIT
---------------------------------------------------------------------------------------------

--// KnitStart
function InventoryService:KnitStart()

end

--// KnitInit
function InventoryService:KnitInit()

end


return InventoryService