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
    if params.DataCategory == "Currency" then

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

        -- do the 2x modifiers only if these didnt come from a dev product
        if params.Source ~= "GamePassService" then 

            -- Double cash if they have the gamepass
            if params.DataKey == "Cash" then
                if Knit.Services.GamePassService:Has_GamePass(player, "DoubleCash") then
                    value = value * 2
                end
            end

            -- Double sould orbs if they have the gamepass
            if params.DataKey == "SoulOrbs" then
                if Knit.Services.GamePassService:Has_GamePass(player, "DoubleOrbs") then
                    value = value * 2
                end
            end
        end

        playerData.Currency[params.DataKey] += value

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

    -- Gui Updates
    -- Cash 
    if params.DataKey == "Cash" then
        Knit.Services.GuiService:Update_Gui(player, "Currency")
    end
    if params.DataKey == "SoulOrbs" then
        Knit.Services.GuiService:Update_Gui(player, "Currency")
    end

end

--// UseArrow
function InventoryService:UseArrow(player, params)

    -- get player data
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

                -- set teh current power
                Knit.Services.PowersService:SetCurrentPower(player,newParams)

                -- fire Show_StandReveal to the player, we do this after we set the data because the Gui pudates based on current data
                Knit.Services.GuiService:Update_Gui(player, "StandReveal")

                return
            end
        end
    end

end

--// StoreStand
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
        --playerData.StandStorage.StoredStands[playerData.CurrentStand.GUI] = playerData.CurrentStand
        
        -- give the player the Standless power
        local newParams = {}
        newParams.Power = "Standless"
        Knit.Services.PowersService:SetCurrentPower(player, newParams)

    end
end

--// GetStandValue
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
            local level = powerUtils.GetLevelFromXp(thisXp)
            finalValue = level * powerModule.Defs.SacrificeValue[thisRarity]
        end
    end

    return finalValue
end

--// SacrificeStand
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

    -- give the soul orbs to player
    local params = {}
    params.DataCategory = "Currency"
    params.DataKey = "SoulOrbs"
    params.Value = self:GetStandValue(player, GUID)
    self:GiveItemToPlayer(player, params)

    -- remove the stand from storage
    for index,stand in pairs(playerData.StandStorage.StoredStands) do
        if stand.GUID == GUID then
            table.remove(playerData.StandStorage.StoredStands, index)
            break
        end
    end

    -- update the GUI
    Knit.Services.GuiService:Update_Gui(player, "StoragePanel")

end

--// EquipStand
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

            -- set the new stand
            print(stand)
            Knit.Services.PowersService:SetCurrentPower(player, stand)

            -- remove the old stand form storage
            table.remove(playerData.StandStorage.StoredStands, index)

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

--// BuyStorage
function InventoryService:BuyStorage(player, params)

    -- get player data
    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

    if playerData.Currency.Cash >= params.Cost then
        playerData.StandStorage.MaxSlots += params.Slots
    end

    -- update the GUI
    Knit.Services.GuiService:Update_Gui(player, "StoragePanel")

end

--// GetCurrencyData
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




--// KnitStart
function InventoryService:KnitStart()

end

--// KnitInit
function InventoryService:KnitInit()

end


return InventoryService