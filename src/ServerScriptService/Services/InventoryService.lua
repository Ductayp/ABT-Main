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
    local itemDefs = require(Knit.Defs.ItemDefs)
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


--// Give_Xp
function InventoryService:Give_Xp(player, xpValue)

    -- check if player has any bonuses
    local multiplier = require(Knit.StateModules.Multiplier_Experience).GetTotalMultiplier(player)
    print("XP Multiplier is: ", multiplier)

    -- multiply the value
    xpValue = xpValue * multiplier

    -- get player data
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

    -- check if player is standless, if they are return out of here
    if playerData.CurrentStand.Power == "Standless" then

        local notificationParams = {}
        notificationParams.Icon = "XP"
        notificationParams.Text = "You are STANDLESS:  ZERO XP gained"
        Knit.Services.GuiService:Update_Notifications(player, notificationParams)
        return
    end

    local maxXpReached = false
    local currentExperience = playerData.CurrentStand.Xp
    local powerModule = require(Knit.Powers[playerData.CurrentStand.Power])
    local maxExperience = powerModule.Defs.MaxXp[playerData.CurrentStand.Rarity]
    if currentExperience >= maxExperience then
        playerData.CurrentStand.Xp = maxExperience
        maxXpReached = true
        xpValue = 0
    elseif xpValue > maxExperience - currentExperience then
        xpValue = maxExperience - playerData.CurrentStand.Xp
    end

    playerData.CurrentStand.Xp += xpValue

    Knit.Services.GuiService:Update_Gui(player, "BottomGUI")
    Knit.Services.GuiService:Update_Gui(player, "StoragePanel")

    if maxXpReached then
        local notificationParams = {}
        notificationParams.Icon = "XP"
        notificationParams.Text = "MAX XP for this stand. Upgrade it to increase capacity"
        Knit.Services.GuiService:Update_Notifications(player, notificationParams)
    else
        local notificationParams = {}
        notificationParams.Icon = "XP"
        notificationParams.Text = "You got: " .. tostring(xpValue) .. " XP"
        Knit.Services.GuiService:Update_Notifications(player, notificationParams)
    end
    

end

--// USeItem
function InventoryService:UseItem(player, key)
    print(player, " is trying to use: ", key)
end

--// Client:UseItem
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
    local arrowOpenDefs = require(Knit.Defs.ArrowOpenDefs)

    -- add stands to weighted table
    local pickTable = {}
    for name, weight in pairs(arrowOpenDefs) do
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
        --print("YES: arrow luck pass")
        if rand <= 90 then
            thisRarity = "Common" -- the default
        elseif rand <= 99 then
            thisRarity = "Rare"
        else
            thisRarity = "Legendary"
        end
    else
        --print("NO: arrow luck pass")
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
    newParams.Xp = 0
    newParams.GUID = HttpService:GenerateGUID(false)

    -- set the current power
    Knit.Services.PowersService:SetCurrentPower(player, newParams)

    -- fire Show_StandReveal to the player
    Knit.Services.GuiService:Update_Gui(player, "StandReveal")

end

--// StoreStand ---------------------------------------------------------------------------------------------------------------------------
function InventoryService:StoreStand(player, GUID)

    -- sanity check to see if player has access
    local hasGamePass = Knit.Services.GamePassService:Has_GamePass(player, "MobileStandStorage")
    local isInZone = Knit.Services.ZoneService:IsPlayerInZone(player, "StorageZone")
    if not hasGamePass or isInZone then
        print("You cant MANAGE STAND: Either no Mobile Storage or you are not at Puccis")
        return
    end

    -- get player data
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

    -- if the ucrrent power is standless, we dont store it obviously!
    if playerData.CurrentStand.Power == "Standless" then
        return
    end

    -- store the current stand in the player has space
    if playerData.StandStorage.SlotsUnlocked > #playerData.StandStorage.StoredStands then
        table.insert(playerData.StandStorage.StoredStands, 1, playerData.CurrentStand)
        playerData.CurrentStand = {Power = "Standless"}
    else
        print("no space in storage for this stand")
        return
    end

    Knit.Services.GuiService:Update_Gui(player, "StoragePanel")
end

--// SellStand ---------------------------------------------------------------------------------------------------------------------------
function InventoryService:SellStand(player, GUID)

    -- return is GUID is nil
    if not GUID then
        return
    end

    -- sanity check to see if player has access
    local hasGamePass = Knit.Services.GamePassService:Has_GamePass(player, "MobileStandStorage")
    local isInZone = Knit.Services.ZoneService:IsPlayerInZone(player, "StorageZone")
    if not hasGamePass or isInZone then
        print("You cant MANAGE STAND: Either no Mobile Storage or you are not at Puccis")
        return
    end

    -- get player data
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

    -- check if the equipped stand is thie one we are selling
    if playerData.CurrentStand.Power ~= "Standless" then
        if GUID == playerData.CurrentStand.GUID then
            local sellValue = math.floor(playerData.CurrentStand.Xp / 100)
            self:Give_Currency(player, "SoulOrbs", sellValue, "SellStand")
            playerData.CurrentStand = {Power = "Standless"}
            Knit.Services.GuiService:Update_Gui(player, "StoragePanel")
            Knit.Services.GuiService:Update_Gui(player, "BottomGUI")
            return
        end
    end

    -- check if the stand is in storage and sell if it is
    for index, standData in pairs(playerData.StandStorage.StoredStands) do
        if GUID == standData.GUID then
            self:Give_Currency(player, "SoulOrbs", standData.Xp, "SellStand")
            table.remove(playerData.StandStorage.StoredStands, index)
            Knit.Services.GuiService:Update_Gui(player, "StoragePanel")
            Knit.Services.GuiService:Update_Gui(player, "BottomGUI")
            return
        end
    end

    --print("InventoryService:SellStand", player, GUID)
end

--// EquipStand ---------------------------------------------------------------------------------------------------------------------------
function InventoryService:EquipStand(player, GUID)

    -- sanity check to see if player has access
    local hasGamePass = Knit.Services.GamePassService:Has_GamePass(player, "MobileStandStorage")
    local isInZone = Knit.Services.ZoneService:IsPlayerInZone(player, "StorageZone")
    if not hasGamePass or isInZone then
        print("You cant MANAGE STAND: Either no Mobile Storage or you are not at Puccis")
        return
    end

    -- get player data
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

    -- save the current stand in a variable to store it after we equip the new one
    tempStoredStand = playerData.CurrentStand

    --find the stand by GUID and set some variable we need
    for index, stand in pairs(playerData.StandStorage.StoredStands) do
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
    Knit.Services.GuiService:Update_Gui(player, "StoragePanel")

end

--// BuyStorage ---------------------------------------------------------------------------------------------------------------------------
function InventoryService:BuyStorage(player)

    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    local standStorageDefs = require(Knit.Defs.StandStorageDefs)
    if playerData.StandStorage.SlotsUnlocked >= standStorageDefs.MaxSlots then
        print("You cant buy more slots than the max")
        return
    end

    local nextSlotId = tostring(playerData.StandStorage.SlotsUnlocked + 1)
    local nextSlotCost = standStorageDefs.SlotCosts[nextSlotId]

    local results
    if playerData.Currency.SoulOrbs >= nextSlotCost then
        playerData.Currency.SoulOrbs = playerData.Currency.SoulOrbs - nextSlotCost
        playerData.StandStorage.SlotsUnlocked += 1
        Knit.Services.GuiService:Update_Gui(player, "StoragePanel")
        Knit.Services.GuiService:Update_Gui(player, "Currency")
        results = "Sucess"
    else
        results = "CantAfford"
    end  

    print("SERVER RESULTS", results)
    return results
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

--// Client:SellStand
function InventoryService.Client:SellStand(player, GUID)
    self.Server:SellStand(player, GUID)
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
function InventoryService.Client:BuyStorage(player)
    results = self.Server:BuyStorage(player)
    return results
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