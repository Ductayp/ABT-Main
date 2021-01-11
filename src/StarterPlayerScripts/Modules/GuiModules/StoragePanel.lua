-- Storage Panel
-- PDab
-- 1/2/2021

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local InventoryService = Knit.GetService("InventoryService")
local GamePassService = Knit.GetService("GamePassService")
local PowersService = Knit.GetService("PowersService")

-- utils
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)

-- Constants
local GUI_COLOR = {
    COMMON = Color3.new(239/255, 239/255, 239/255),
    RARE = Color3.new(10/255, 202/255, 0/255),
    LEGENDARY = Color3.new(255/255, 149/255, 43/255)
}

local StoragePanel = {}

-- variables
StoragePanel.StandCardGUID = nil -- this gets set when a player clicks a stand button to show a stand card. Its used in buttons to send the viewed stand for actions

--// DEFS - Storage PANEL ------------------------------------------------------------
--StoragePanel = {}
StoragePanel.Panel = mainGui.Windows:FindFirstChild("Storage_Panel", true)
StoragePanel.DefaultCard = StoragePanel.Panel:FindFirstChild("Default_Card", true)
StoragePanel.Stand_Icons = mainGui.Stand_Icons

-- scrolling frame 
StoragePanel.ItemTemplate = StoragePanel.Panel:FindFirstChild("Item_Template", true)
StoragePanel.ScrollingFrame = StoragePanel.Panel:FindFirstChild("Scrolling_Frame", true)

-- stand card
StoragePanel.StandCard = StoragePanel.Panel:FindFirstChild("Stand_Card", true)
StoragePanel.StandIconFrame = StoragePanel.Panel:FindFirstChild("Stand_Icon_Frame", true)
StoragePanel.StandName = StoragePanel.Panel:FindFirstChild("Stand_Name", true)
StoragePanel.StandRarity = StoragePanel.Panel:FindFirstChild("Stand_Rarity", true)
StoragePanel.Level = StoragePanel.Panel:FindFirstChild("Stand_Level", true)
StoragePanel.XpBar = StoragePanel.Panel:FindFirstChild("Xp_Bar", true)
StoragePanel.BaseValue = StoragePanel.Panel:FindFirstChild("Base_Value", true)
StoragePanel.TotalSlots = StoragePanel.Panel:FindFirstChild("Total_Slots", true)
StoragePanel.UsedSlots = StoragePanel.Panel:FindFirstChild("Used_Slots", true)
StoragePanel.ButtonPanelCurrent = StoragePanel.Panel:FindFirstChild("ButtonPanel_Current", true)
StoragePanel.ButtonPanelStored = StoragePanel.Panel:FindFirstChild("ButtonPanel_Stored", true)

-- buttons
StoragePanel.Button_CurrentStand = StoragePanel.Panel:FindFirstChild("Button_CurrentStand", true)
StoragePanel.Button_BuyStorage = StoragePanel.Panel:FindFirstChild("Button_BuyStorage", true)
StoragePanel.Button_EvolveStand = StoragePanel.Panel:FindFirstChild("Button_EvolveStand", true)
StoragePanel.Button_StoreStand = StoragePanel.Panel:FindFirstChild("Button_StoreStand", true)
StoragePanel.Button_SacrificeStand = StoragePanel.Panel:FindFirstChild("Button_SacrificeStand", true)
StoragePanel.Button_EquipStand = StoragePanel.Panel:FindFirstChild("Button_EquipStand", true)

-- confirmation pop up
StoragePanel.Confirmation_Frame = mainGui.Windows:FindFirstChild("SacrificePopUp", true)
StoragePanel.Confirmation_StandName = StoragePanel.Confirmation_Frame:FindFirstChild("Stand_Name", true)
StoragePanel.Confirmation_StandLevel = StoragePanel.Confirmation_Frame:FindFirstChild("Stand_Level", true)
StoragePanel.Confirmation_BaseValue = StoragePanel.Confirmation_Frame:FindFirstChild("Base_Value", true)
StoragePanel.Confirmation_TotalValue = StoragePanel.Confirmation_Frame:FindFirstChild("Total_Value", true)
StoragePanel.Confirmation_Button_DoubleOrbsPass = StoragePanel.Confirmation_Frame:FindFirstChild("Button_DoubleOrbsPass", true)
StoragePanel.Confirmation_Button_Cancel = StoragePanel.Confirmation_Frame:FindFirstChild("Button_Cancel", true)
StoragePanel.Confirmation_Button_Sacrifice = StoragePanel.Confirmation_Frame:FindFirstChild("Button_Sacrifice", true)

-- Storage Warning
StoragePanel.Warning_Frame = mainGui.Windows:FindFirstChild("StorageWarningPopUp", true)
StoragePanel.Warning_MobileBuyButton = StoragePanel.Warning_Frame:FindFirstChild("Button_MobileStorage", true)
StoragePanel.Warning_CloseButton = StoragePanel.Warning_Frame:FindFirstChild("Button_Close", true)


--// Setup_StandPanel ------------------------------------------------------------
function StoragePanel.Setup()

    -- make  popups not visible
    StoragePanel.Confirmation_Frame.Visible = false
    StoragePanel.Warning_Frame.Visible = false

    -- make stand item template not visible
    StoragePanel.ItemTemplate.Visible = false
    StoragePanel.StandCard.Visible = false
    StoragePanel.DefaultCard.Visible = true

    -- BUTTON - Buy Storage
    StoragePanel.Button_BuyStorage.Activated:Connect(function()
        print("beep beep!")
    end)

    -- BUTTON - Evolve Stand
    StoragePanel.Button_EvolveStand.Activated:Connect(function()
        print("yeeeeeehhoooo!!")
        spawn(function()

            local originalText = StoragePanel.Button_EvolveStand.Text
            local originalBorderColor = StoragePanel.Button_EvolveStand.BorderColor3
            local originalTextColor = StoragePanel.Button_EvolveStand.TextColor3 

            StoragePanel.Button_EvolveStand.Text = "COMING SOON"
            StoragePanel.Button_EvolveStand.BorderColor3 = Color3.new(255/255, 0/255, 0/255)
            StoragePanel.Button_EvolveStand.TextColor3 = Color3.new(255/255, 0/255, 0/255)
            StoragePanel.Button_EvolveStand.Active = false

            wait(3)

            StoragePanel.Button_EvolveStand.Text = originalText
            StoragePanel.Button_EvolveStand.BorderColor3 = originalBorderColor
            StoragePanel.Button_EvolveStand.TextColor3 = originalTextColor
            StoragePanel.Button_EvolveStand.Active = true

        end)
    end)

    -- BUTTON - Store Stand
    StoragePanel.Button_StoreStand.Activated:Connect(function()

        local hasAcces = require(Knit.StateModules.StandStorageAccess).HasAccess(Players.LocalPlayer)

        if GamePassService:Has_GamePass("MobileStandStorage") or hasAcces == true then
            InventoryService:StoreStand()
        else
            Knit.Controllers.GuiController.InventoryWindow.Window.Visible = false
            StoragePanel.Warning_Frame.Visible = true
        end
    end)

    -- BUTTON - Sacrifice Stand
    StoragePanel.Button_SacrificeStand.Activated:Connect(function()
        StoragePanel.Confirmation_Frame.Visible = true
        Knit.Controllers.GuiController.InventoryWindow.Window.Visible = false
    end)

    -- BUTTON - Equip Stand
    StoragePanel.Button_EquipStand.Activated:Connect(function()

        local hasAcces = require(Knit.StateModules.StandStorageAccess).HasAccess(Players.LocalPlayer)

        if GamePassService:Has_GamePass("MobileStandStorage") or hasAcces == true then
            InventoryService:EquipStand(StoragePanel.StandCardGUID)
        else
            Knit.Controllers.GuiController.InventoryWindow.Window.Visible = false
            StoragePanel.Warning_Frame.Visible = true
        end
    end)

    -- BUTTON - Confirmation - Sacrifice
    StoragePanel.Confirmation_Button_Sacrifice.Activated:Connect(function()

        local hasAcces = require(Knit.StateModules.StandStorageAccess).HasAccess(Players.LocalPlayer)

        if GamePassService:Has_GamePass("MobileStandStorage") or hasAcces == true then
            InventoryService:SacrificeStand(StoragePanel.StandCardGUID)
            StoragePanel.Confirmation_Frame.Visible = false
            Knit.Controllers.GuiController.InventoryWindow.Window.Visible = true
        else
            Knit.Controllers.GuiController.InventoryWindow.Window.Visible = false
            StoragePanel.Confirmation_Frame.Visible = false
            StoragePanel.Warning_Frame.Visible = true
        end
    end)

    -- BUTTON - Confirmation - Cancel
    StoragePanel.Confirmation_Button_Cancel.Activated:Connect(function()
        StoragePanel.Confirmation_Frame.Visible = false
        Knit.Controllers.GuiController.InventoryWindow.Window.Visible = true
    end)

    -- BUTTON - Confirmation - Double Orb Pass
    StoragePanel.Confirmation_Button_DoubleOrbsPass.Activated:Connect(function()
        GamePassService:Prompt_GamePassPurchase("MobileStandStorage")
    end)

    -- BUTTON - Warning - Close
    StoragePanel.Warning_CloseButton.Activated:Connect(function()
        StoragePanel.Warning_Frame.Visible = false
        StoragePanel.Confirmation_Frame.Visible = false
        Knit.Controllers.GuiController.InventoryWindow.Window.Visible = true
    end)

    -- BUTTON - Warning - MobileBuyButton
    StoragePanel.Warning_MobileBuyButton.Activated:Connect(function()
        GamePassService:Prompt_GamePassPurchase("MobileStandStorage")
    end)
end


--// Update_StandPanel ------------------------------------------------------------
function StoragePanel.Update(currentStand, storageData)

    StoragePanel.StandCard.Visible = false
    StoragePanel.DefaultCard.Visible = true

    -- update the max slots and used slots
    local counter = 0 
    if storageData.StoredStands ~= nil then
        for _,v in pairs(storageData.StoredStands) do
            counter = counter + 1
        end
    end
    StoragePanel.TotalSlots.Text = storageData.MaxSlots
    StoragePanel.UsedSlots.Text = counter

    -- get rid of the old tempoirary Current Power buttons
    for _,object in pairs(StoragePanel.Button_CurrentStand.Parent:GetChildren()) do
        if object.Name == "TempButton" then
            object:Destroy()
        end
    end

    -- setup the Current Power button
    if currentStand.Power == "Standless" then

        -- button settings
        StoragePanel.Button_CurrentStand.Visible = true
        StoragePanel.Button_CurrentStand.Active = false

        -- the setup doesnt run when this button is standless, so we need to set the text here
        local textLabel = StoragePanel.Button_CurrentStand:FindFirstChild("List_Item_StandName", true)
        textLabel.Text = "Standless"
        textLabel.TextColor3 = Color3.new(239/255, 239/255, 239/255)

    else
        -- button settings
        StoragePanel.Button_CurrentStand.Active = false
        StoragePanel.Button_CurrentStand.Visible = false

        -- clone a new button and destroy old one to get rid of old conneciton. BUH BYE MEMEORY LEAKS!
        local newButton = StoragePanel.Button_CurrentStand:Clone()
        local newButtonParent = StoragePanel.Button_CurrentStand.Parent

        -- set it up
        newButton.Parent = newButtonParent
        newButton.Active = true
        newButton.Visible = true
        newButton.Name = "TempButton"

        -- do the setup
        StoragePanel.Build_StandButton(newButton, currentStand, "CurrentStand")

    end

    
    -- clear out the list of objects from last time
    for _,object in pairs(StoragePanel.ScrollingFrame:GetChildren()) do
        if object.Name == "standItem" then
            object:Destroy()
        end
    end

    -- add stored stands to the list
    if storageData.StoredStands ~= nil then
        for index,stand in pairs(storageData.StoredStands) do

            -- make a new list item
            local newListItem = StoragePanel.ItemTemplate:Clone()
            newListItem.Parent = StoragePanel.ScrollingFrame
            newListItem.Visible = true
            newListItem.Name = "standItem"

            StoragePanel.Build_StandButton(newListItem, stand, "StoredStand")
            
        end
    end

end

--// Build_StandButton
function StoragePanel.Build_StandButton(list_Item, standData, buttonType)

    local findPowerModule = Knit.Powers:FindFirstChild(standData.Power)
    if findPowerModule then

        -- require it
        local powerModule = require(findPowerModule)

        -- rarity based stuff
        if list_Item:FindFirstChild("List_Item_StandName", true) then
            local listItemName = list_Item:FindFirstChild("List_Item_StandName", true)
            listItemName.Text = powerModule.Defs.PowerName
            if standData.Rarity == "Common" then
                listItemName.TextColor3 = GUI_COLOR.COMMON
            elseif standData.Rarity == "Rare" then
                listItemName.TextColor3 = GUI_COLOR.RARE
            elseif standData.Rarity == "Legendary" then
                listItemName.TextColor3 = GUI_COLOR.LEGENDARY
            end
        end

        -- set the level on the list item
        local listItemLevel = list_Item:FindFirstChild("List_Item_StandLevel", true)
        if listItemLevel then
            local level = PowersService:GetLevelFromXp(standData.Xp, standData.Rarity)
            listItemLevel.Text = tostring(level)
        end

        -- add the icon to the standData
        standData.Icon = StoragePanel.Stand_Icons:FindFirstChild(standData.Power .. "_" .. standData.Rarity)

        -- add sacrifice value to the standData
        standData.BaseValue = powerModule.Defs.SacrificeValue[standData.Rarity]
        --standData.BaseValue = powerModule.Defs.BaseSacrificeValue

        -- add the actual name to the standData
        standData.Name = powerModule.Defs.PowerName

        -- connect the button click
        list_Item.Activated:Connect(function()
            StoragePanel.Show_StandCard(standData, buttonType)
        end)

    end
end

--// Show_StandCard
function StoragePanel.Show_StandCard(standData, buttonType)

    StoragePanel.StandCardGUID = standData.GUID

    -- delete the old icons
    for _,object in pairs(StoragePanel.StandIconFrame:GetChildren()) do
        if object.name == "TempIcon" then
            object:Destroy()
        end
    end

    -- set icon
    local newIcon = standData.Icon:Clone()
    newIcon.BorderSizePixel = 4
    newIcon.Parent = StoragePanel.StandIconFrame
    newIcon.Visible = true
    newIcon.Name = "TempIcon"

    -- confirmation popup - turn off all the a raity bonus info panels
    local allBonus_info = {StoragePanel.RarityBonus_Common,StoragePanel.RarityBonus_Rare,StoragePanel.RarityBonus_Legendary}
    for _,frame in pairs(allBonus_info) do
        frame.Visible = false
    end

    -- set name and rarity
    StoragePanel.StandName.Text = standData.Name
    StoragePanel.StandRarity.Text = standData.Rarity
    if standData.Rarity == "Common" then
        StoragePanel.StandRarity.TextColor3 = GUI_COLOR.COMMON
    elseif standData.Rarity == "Rare" then
        StoragePanel.StandRarity.TextColor3 = GUI_COLOR.RARE
    elseif standData.Rarity == "Legendary" then
        StoragePanel.StandRarity.TextColor3 = GUI_COLOR.LEGENDARY
    end

    -- set level and xp bar
    local level, remainingPercent = PowersService:GetLevelFromXp(standData.Xp, standData.Rarity)
    print(level, remainingPercent)
    StoragePanel.Level.Text = tostring(level)
    local width = math.floor((remainingPercent / 100) + 1)
    StoragePanel.XpBar.Size = UDim2.new(width, StoragePanel.XpBar.Size.X.Offset, StoragePanel.XpBar.Size.Y.Scale, StoragePanel.XpBar.Size.Y.Offset)

    -- set base value
    StoragePanel.BaseValue.Text = standData.BaseValue

    -- confirmation popup - setup
    StoragePanel.Confirmation_StandName.Text = standData.Name
    StoragePanel.Confirmation_StandLevel.Text = tostring(level)
    StoragePanel.Confirmation_BaseValue.Text = standData.BaseValue
    StoragePanel.Confirmation_TotalValue.Text = InventoryService:GetStandValue(StoragePanel.StandCardGUID)

    -- setup the button panel
    if buttonType == "CurrentStand" then
        StoragePanel.ButtonPanelCurrent.Visible = true
        StoragePanel.ButtonPanelStored.Visible = false

        StoragePanel.Button_StoreStand.Active = true
        StoragePanel.Button_EvolveStand.Active = true

        StoragePanel.Button_SacrificeStand.Active = false
        StoragePanel.Button_EquipStand.Active = false
        
    else
        StoragePanel.ButtonPanelCurrent.Visible = false
        StoragePanel.ButtonPanelStored.Visible = true

        StoragePanel.Button_StoreStand.Active = false
        StoragePanel.Button_EvolveStand.Active = false

        StoragePanel.Button_SacrificeStand.Active = true
        StoragePanel.Button_EquipStand.Active = true
    end

    -- the the Visible settings at the end
    StoragePanel.StandCard.Visible = true
    StoragePanel.DefaultCard.Visible = false

end


return StoragePanel