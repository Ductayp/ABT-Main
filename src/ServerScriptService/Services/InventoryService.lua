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

    --print("InventoryService:Give_Currency(player, key, value, source)", player, key, value, source)

    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    if not playerData then return end

    -- do the 2x modifiers only if these didnt come from a dev product
    if source ~= "GamePassService" and source ~= "Admin" then 

        -- Double cash if they have the gamepass
        if key == "Cash" then
            local multiplier = require(Knit.StateModules.Multiplier_Cash).GetTotalMultiplier(player)
            value = value * multiplier
        end

        -- Double sould orbs if they have the gamepass
        if key == "SoulOrbs" then
            local multiplier = require(Knit.StateModules.Multiplier_Orbs).GetTotalMultiplier(player)
            value = value * multiplier
        end
    else
        -- Bought currency as a dev product, gamepass mutlipliers do not work!
    end

    -- add it to the playerData
    playerData.Currency[key] += value

    -- update the gui
    Knit.Services.GuiService:Update_Gui(player, "Currency")
    Knit.Services.GuiService:Update_Gui(player, "CraftingWindow")

end

--// Give_Item ---------------------------------------------------------------------------------------------------------------------------
function InventoryService:Give_Item(player, key, quantity)
    
    -- get player data
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    if not playerData then return end
    
    --print("Give_Item(player, key, quantity)", player, key, quantity)

    -- get the defs
    local itemDefs = require(Knit.Defs.ItemDefs)
    local thisItemDef = itemDefs[key]

    -- if theres no item with this key, then return
    if not thisItemDef then
        warn("NO ITEM WITH THIS KEY: InventoryService:Give_Item(player, key, quantity)", player, key, quantity)
        return
    end

    -- if the data key is nil, make an entry in the table
    if playerData.ItemInventory[key] == nil then
        playerData.ItemInventory[key] = 0
    end

    -- increment the key
    playerData.ItemInventory[key] += quantity

    -- update item panel
    Knit.Services.GuiService:Update_Gui(player, "ItemsWindow")
    Knit.Services.GuiService:Update_Gui(player, "CraftingWindow")

end


--// Give_Xp
function InventoryService:Give_Xp(player, xpValue)

    -- check if player has any bonuses
    local multiplier = require(Knit.StateModules.Multiplier_Experience).GetTotalMultiplier(player)

    -- multiply the value
    xpValue = xpValue * multiplier

    -- get player data
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    if not playerData then return end

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
    local maxExperience = powerModule.Defs.MaxXp[playerData.CurrentStand.Rank]
    if currentExperience >= maxExperience then
        playerData.CurrentStand.Xp = maxExperience
        maxXpReached = true
        xpValue = 0
    elseif xpValue > maxExperience - currentExperience then
        xpValue = maxExperience - playerData.CurrentStand.Xp
    end

    playerData.CurrentStand.Xp += xpValue

    Knit.Services.GuiService:Update_Gui(player, "StandData")
    Knit.Services.GuiService:Update_Gui(player, "StoragePanel")

    if maxXpReached then
        local notificationParams = {}
        notificationParams.Icon = "XP"
        notificationParams.Text = "MAX XP for this stand. Time to EVOLVE!"
        Knit.Services.GuiService:Update_Notifications(player, notificationParams)
    end
    
end

--// USeItem
function InventoryService:UseItem(player, key)

    local returnMessage

    -- get player data
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    if not playerData then return end

    -- check if the player has the item to use
    if playerData.ItemInventory[key] == nil or playerData.ItemInventory[key] < 1 then
        local returnMessage = "None Owned"
        return returnMessage
    end

    local itemDefs = require(Knit.Defs.ItemDefs)
    local thisItem = itemDefs[key]
    if not thisItem then
        local returnMessage = "ItemDoesntExist"
        return returnMessage
    end

    if thisItem.Type == "Collectable" then
        local returnMessage = "Can't Use This"
        return returnMessage
    end

    if thisItem.Type == "Evolution" then

        -- check in player is standless
        if playerData.CurrentStand.Power ~= "Standless" then
            local returnMessage = "Must Be Standless"
            return returnMessage
        end

        if not thisItem.GivePower then 
            local returnMessage = "Can't Use This"
            return returnMessage
        end

        spawn(function()
            if thisItem.GivePower == "Stand" then
                self:GenerateNewStand(player)
                return
            else
                self:GiveSpecialPower(player, thisItem)
                return
            end
        end)

        playerData.ItemInventory[key] += - 1

        Knit.Services.GuiService:Update_Gui(player, "ItemsWindow")
        Knit.Services.GuiService:Update_Gui(player, "CraftingWindow")

        local returnMessage = "Used Arrow"
        return returnMessage

    end

    if thisItem.Type == "Special" then

        if key == "GoldStar" then

            if playerData.CurrentStand.Power == "Standless" then
                local returnMessage = "You are Standless"
                return returnMessage
            end

            local currentExperience = playerData.CurrentStand.Xp
            local powerModule = require(Knit.Powers[playerData.CurrentStand.Power])
            local maxExperience = powerModule.Defs.MaxXp[playerData.CurrentStand.Rank]
            
            if currentExperience < maxExperience then
                local returnMessage = "Not Enough Experience"
                return returnMessage
            end

            local newRank
            if playerData.CurrentStand.Rank == 1 then
                newRank = 2
            elseif playerData.CurrentStand.Rank == 2 then
                newRank = 3
            elseif playerData.CurrentStand.Rank == 3 then
                returnMessage = "Already Max Rank"
                return returnMessage
            end

            playerData.ItemInventory.GoldStar += -1

    
            local standData = {}
            standData.Power = playerData.CurrentStand.Power
            standData.Rank = newRank
            standData.Xp = 0
            standData.GUID = playerData.CurrentStand.GUID
            Knit.Services.PowersService:SetCurrentPower(player, standData)
            
            Knit.Services.GuiService:Update_Gui(player, "CraftingWindow")
            Knit.Services.GuiService:Update_Gui(player, "ItemsWindow")

            returnMessage = "Success!"
            return returnMessage

        else

            -- actual evolution items go here
            print(player, ": Evolution item, not ready yet!")
            local returnMessage = "Evolution"
            return returnMessage

        end

    end

end

function InventoryService:GiveSpecialPower(player, itemDef)

    print("GIVE SPECIAL", player, itemDef)

    local sceneParams = {}
    sceneParams.TargetPlayer = player
    sceneParams.Stage = "Run"
    sceneParams.SceneName = itemDef.CutScene
    Knit.Services.CutSceneService:LoadScene_AllPlayers(sceneParams)

    local newParams = {}
    newParams.Power = itemDef.GivePower
    newParams.Rank = 1
    newParams.Xp = 0
    newParams.GUID = HttpService:GenerateGUID(false)
    Knit.Services.PowersService:SetCurrentPower(player, newParams)

end

--// GenerateNewStand
function InventoryService:GenerateNewStand(player)

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

    -- if player has the gamepass for arrow luck, give them a chance at better Rank
    local thisRank
    local rand = math.random(1, 1000) / 10
    if Knit.Services.GamePassService:Has_GamePass(player, "ArrowLuck") then
        if rand <= 85 then
            thisRank = 1 -- the default
        elseif rand <= 97 then
            thisRank = 2
        else
            thisRank = 3
        end
    else
        thisRank = 1 -- the default
    end

    -- set the current power
    local sceneParams = {}
    sceneParams.Stage = "Run"
    sceneParams.SceneName = "UseArrow"
    Knit.Services.CutSceneService:LoadScene_SinglePlayer(player, sceneParams)

    local newParams = {}
    newParams.Power = pickedStand
    newParams.Rank = thisRank
    newParams.Xp = 0
    newParams.GUID = HttpService:GenerateGUID(false)
    Knit.Services.PowersService:SetCurrentPower(player, newParams)

    -- fire Show_StandReveal to the player
    revealParams = {}
    revealParams.AllStands = arrowOpenDefs
    revealParams.RevealDelay = 3
    Knit.Services.GuiService:Update_Gui(player, "StandReveal", revealParams)

end


--// SellStand ---------------------------------------------------------------------------------------------------------------------------
function InventoryService:SellStand(player, GUID)

    -- return is GUID is nil
    if not GUID then
        return
    end

    -- get player data
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    if not playerData then return end

    -- check if the equipped stand is thie one we are selling
    if playerData.CurrentStand.Power ~= "Standless" then
        if GUID == playerData.CurrentStand.GUID then

            Knit.Services.PowersService:SetCurrentPower(player, {Power = "Standless"})
            Knit.Services.GuiService:Update_Gui(player, "StoragePanel")

            return
        end
    end

    -- check if the stand is in storage and sell if it is
    for index, standData in pairs(playerData.StandStorage.StoredStands) do
        if GUID == standData.GUID then

            table.remove(playerData.StandStorage.StoredStands, index)
            Knit.Services.GuiService:Update_Gui(player, "StoragePanel")

            return
        end
    end

end


--// StoreStand ---------------------------------------------------------------------------------------------------------------------------
function InventoryService:StoreStand(player, GUID)

    -- sanity check to see if player has access
    local hasGamePass = Knit.Services.GamePassService:Has_GamePass(player, "MobileStandStorage")
    local isInZone = Knit.Services.ZoneService:IsPlayerInZone(player, "StorageZone")
    if hasGamePass or isInZone then
        --print("You can manage the stands, homie!")
    else
        --print("You cant MANAGE STAND: Either no Mobile Storage or you are not at Puccis")
        return
    end

    -- get player data
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    if not playerData then return end

    -- if the ucrrent power is standless, we dont store it obviously!
    if playerData.CurrentStand.Power == "Standless" then
        return
    end

    -- store the current stand in the player has space
    if playerData.StandStorage.SlotsUnlocked > #playerData.StandStorage.StoredStands then
        table.insert(playerData.StandStorage.StoredStands, 1, playerData.CurrentStand)
        Knit.Services.PowersService:SetCurrentPower(player, {Power = "Standless"})
    else
        --warn("no space in storage for this stand")
        return
    end

    Knit.Services.GuiService:Update_Gui(player, "StoragePanel")
end

--// EquipStand ---------------------------------------------------------------------------------------------------------------------------
function InventoryService:EquipStand(player, GUID)

    -- sanity check to see if player has access
    local hasGamePass = Knit.Services.GamePassService:Has_GamePass(player, "MobileStandStorage")
    local isInZone = Knit.Services.ZoneService:IsPlayerInZone(player, "StorageZone")
    if hasGamePass or isInZone then
        --print("You can manage the stands, homie!")
    else
        --print("You cant MANAGE STAND: Either no Mobile Storage or you are not at Puccis")
        return
    end

    -- get player data
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    if not playerData then return end

    -- save the current stand in a variable to store it after we equip the new one
    local tempStoredStand = playerData.CurrentStand

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
    if not playerData then return end

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

--// CraftItem
function InventoryService:CraftItem(player, params)

    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    if not playerData then return end

    local returnMessage = "FAIL" -- default message

    local thisRecipe = require(Knit.Defs.CraftingDefs)[params.ReceipeKey]
    if not thisRecipe then
        warn("Crafting Recipe not found")
    end

    -- check if player has all ingredients
    local canCraft = true
    for _, inputItem in pairs(thisRecipe.InputItems) do

        if inputItem.Key == "Cash" or inputItem.Key == "SoulOrbs" then
            if playerData.Currency[inputItem.Key] < inputItem.Value then
                canCraft = false
                break
            end
        else
            if playerData.ItemInventory[inputItem.Key] < inputItem.Value then
                canCraft = false
                break
            end
        end
    end

    -- if canCraft then do the crafting
    if canCraft then

        for _, inputItem in pairs(thisRecipe.InputItems) do
            if inputItem.Key == "Cash" or inputItem.Key == "SoulOrbs" then
                playerData.Currency[inputItem.Key] = playerData.Currency[inputItem.Key] - inputItem.Value
            else
                playerData.ItemInventory[inputItem.Key] = playerData.ItemInventory[inputItem.Key] - inputItem.Value
            end
        end

        for _, outputItem in pairs(thisRecipe.OutputItems) do
            
            if outputItem.Key == "Cash" or outputItem.Key == "SoulOrbs" then
                playerData.Currency[outputItem.Key] += outputItem.Value
            else
                if not playerData.ItemInventory[outputItem.Key] then
                    playerData.ItemInventory[outputItem.Key] = 0
                end
                playerData.ItemInventory[outputItem.Key] += outputItem.Value
            end

            -- update notifications
            local notificationParams = {}
            notificationParams.Icon = "Item"
            notificationParams.Text = "You Crafted: " .. outputItem.Name
            Knit.Services.GuiService:Update_Notifications(player, notificationParams)

        end

        returnMessage = "SUCCESS"
    end

    if not canCraft then
        returnMessage = "MISSING ITEMS"
    end

    --Knit.Services.GuiService:Update_Gui(player, "StoragePanel")
    Knit.Services.GuiService:Update_Gui(player, "Currency")
    Knit.Services.GuiService:Update_Gui(player, "ItemsWindow")
    Knit.Services.GuiService:Update_Gui(player, "CraftingWindow")


    
    return returnMessage

end

--// NPCTransaction
function InventoryService:NPCTransaction(player, params)

    print("InventoryService:NPCTransaction", player, params)

    local dialogueModule = require(Knit.DialogueModules[params.ModuleName])
    if not dialogueModule then return end
    local transactionDef = dialogueModule.Shop[params.TransactionKey]
    if not transactionDef then return end

    local inputKey = transactionDef.Input.Key
    local inputValue = transactionDef.Input.Value
    local outputKey = transactionDef.Output.Key
    local outputValue = transactionDef.Output.Value

    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    if not playerData then return end

    print("YEET", player, params)

    -- check if player has enough of the input
    local success = false
    if inputKey == "Cash" or inputKey == "SoulOrbs"then
        if playerData.Currency[inputKey] >= inputValue then
            playerData.Currency[inputKey] = playerData.Currency[inputKey] - inputValue
            success = true
        end
    else
        if playerData.ItemInventory[inputKey] ~= nil then
            if playerData.ItemInventory[inputKey] >= inputValue then
                playerData.ItemInventory[inputKey] = playerData.ItemInventory[inputKey] - inputValue
                success = true
            end
        end
    end

    -- if success, give the output stuff
    if success then
        if outputKey == "Cash" or outputKey == "SoulOrbs" then
            playerData.Currency[outputKey] = playerData.Currency[outputKey] + outputValue
        else
            if playerData.ItemInventory[outputKey] == nil then
                playerData.ItemInventory[outputKey] = 0
            end
            playerData.ItemInventory[outputKey] = playerData.ItemInventory[outputKey] + outputValue
        end

        Knit.Services.GuiService:Update_Gui(player, "StoragePanel")
        Knit.Services.GuiService:Update_Gui(player, "Currency")
        Knit.Services.GuiService:Update_Gui(player, "ItemsWindow")
    end

    return success

end

--// ShopTransaction
function InventoryService:ShopTransaction(player, params)

    --print("InventoryService:ShopTransaction", player, params)

    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    if not playerData then return end

    local shopModule = require(params.ShopModule)
    if not shopModule then return end

    local transactionDef = shopModule.ShopItems[params.TransactionId]
    if not transactionDef then return end

    local inputKey = transactionDef.InputKey
    local inputValue = transactionDef.InputValue
    local outputKey = transactionDef.OutputKey
    local outputValue = transactionDef.OutputValue

    local success = false
    if inputKey == "Cash" or inputKey == "SoulOrbs"then
        if playerData.Currency[inputKey] >= inputValue then
            playerData.Currency[inputKey] = playerData.Currency[inputKey] - inputValue
            success = true
        end
    else
        if playerData.ItemInventory[inputKey] ~= nil then
            if playerData.ItemInventory[inputKey] >= inputValue then
                playerData.ItemInventory[inputKey] = playerData.ItemInventory[inputKey] - inputValue
                success = true
            end
        end
    end

    -- if success, give the output stuff
    if success then

        if outputKey == "Cash" or outputKey == "SoulOrbs" then
            playerData.Currency[outputKey] = playerData.Currency[outputKey] + outputValue
        else
            if playerData.ItemInventory[outputKey] == nil then
                playerData.ItemInventory[outputKey] = 0
            end
            playerData.ItemInventory[outputKey] = playerData.ItemInventory[outputKey] + outputValue
        end

        Knit.Services.GuiService:Update_Gui(player, "StoragePanel")
        Knit.Services.GuiService:Update_Gui(player, "Currency")
        Knit.Services.GuiService:Update_Gui(player, "ItemsWindow")
    end

    return success

end

--// GetCurrencyData ---------------------------------------------------------------------------------------------------------------------------
function InventoryService:GetCurrencyData(player)

    -- get player data
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    if not playerData then return end
    
    local currencyData = playerData.Currency

    print(playerData)
    print(currencyData)

    return currencyData
end

---------------------------------------------------------------------------------------------
--// CLIENT METHODS
---------------------------------------------------------------------------------------------

--// Client:UseItem
function InventoryService.Client:UseSpecial(player, key)
    self.Server:UseSpecial(player, key)
end

--// Client:UseItem
function InventoryService.Client:UseItem(player, key)
    local returnMessage = self.Server:UseItem(player, key)
    return returnMessage
end

--// Client:CraftItem
function InventoryService.Client:CraftItem(player, params)
    local returnMessage = self.Server:CraftItem(player, params)
    return returnMessage
end

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
    local results = self.Server:BuyStorage(player)
    return results
end

--// Client:GetCurrencyData
function InventoryService.Client:GetCurrencyData(player)
    local currencyData = self.Server:GetCurrencyData(player)
    return currencyData
end

--// Client:NPCTransaction
function InventoryService.Client:NPCTransaction(player, params)
    local success = self.Server:NPCTransaction(player, params)
    return success
end

--// Client:ShopTransaction
function InventoryService.Client:ShopTransaction(player, params)
    local success = self.Server:ShopTransaction(player, params)
    return success
end

--// Client:UpgradeStandRank
function InventoryService.Client:UpgradeStandRank(player, standGUID)
    local result = self.Server:UpgradeStandRank(player, standGUID)
    return result
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