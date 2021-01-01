-- GUI controller
-- PDab
-- 12 / 15/ 2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local PlayerGui = Players.LocalPlayer.PlayerGui
local TweenService = game:GetService("TweenService")


-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local GuiController = Knit.CreateController { Name = "GuiController" }
local GuiService = Knit.GetService("GuiService")
local InventoryService = Knit.GetService("InventoryService")
local PowersService = Knit.GetService("PowersService")
local GamePassService = Knit.GetService("GamePassService")

-- Knit modules
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)

-- Gui Defs
local mainGui = PlayerGui:WaitForChild("MainGui", 120)
local defs = {}


--// ====================================================================================================================================
--//  BOTTOM GUI
--// ====================================================================================================================================

--// DEFS - BOTTOM GUI ------------------------------------------------------------
defs.Bottom_Gui = {
    Current_Power = mainGui.BottomGui:FindFirstChild("Current_Power", true)
}


--// Setup_PowerButton ------------------------------------------------------------
function GuiController:Setup_PowerButton()

    --local mainGui = Players.LocalPlayer.PlayerGui:WaitForChild("MainGui")
    local powerButtonFrame = mainGui:FindFirstChild("PowerButtons",true)

    for _,button in pairs(powerButtonFrame:GetDescendants()) do
        if button:IsA("TextButton") then
            button.Activated:Connect(function()
                Knit.Controllers.InputController:SendToPowersService({InputId = button.Name, KeyState = "InputBegan"})
            end)
        end
    end
end

--// UpdateCharacter ------------------------------------------------------------
function GuiController:Update_Character(data)
    defs.Bottom_Gui.Current_Power.Text = data.CurrentPower
end


--// ====================================================================================================================================
--//  LEFT GUI
--// ====================================================================================================================================

--// DEFS - LEFT GUI ------------------------------------------------------------
defs.LeftGui = {
    Cash_Value = mainGui.LeftGui:FindFirstChild("Cash_Value", true),
    Buttons = {
        MainMenu_Button = mainGui.LeftGui:FindFirstChild("MainMenu_Button", true),
        Arrow_Button = mainGui.LeftGui:FindFirstChild("Arrow_Button", true),
        Storage_Button = mainGui.LeftGui:FindFirstChild("Storage_Button", true),
    },
}

--// Setup_LeftGui() ------------------------------------------------------------
function GuiController:Setup_LeftGui()

    -- connect the clickies
    defs.LeftGui.Buttons.MainMenu_Button.Activated:Connect(function()
        self:ActivatePanel(defs.MainWindow, defs.MainWindow.Panels.Item_Panel)
    end)

    defs.LeftGui.Buttons.Arrow_Button.Activated:Connect(function()
        self:ActivatePanel(defs.MainWindow, defs.MainWindow.Panels.Arrow_Panel)
    end)

    defs.LeftGui.Buttons.Storage_Button.Activated:Connect(function()
        self:ActivatePanel(defs.MainWindow, defs.MainWindow.Panels.Storage_Panel)
    end)
end

--// UpdateCash ------------------------------------------------------------
function GuiController:Update_Cash(value)
    if value ~= nil then
        defs.LeftGui.Cash_Value.Text = value
    end
end


--// ====================================================================================================================================
--//  WINDOW GUI
--// ====================================================================================================================================

--// DEFS - WINDOW GUI ------------------------------------------------------------
defs.MainWindow = {}
defs.MainWindow.Window = mainGui.Windows:FindFirstChild("MainWindow", true)
defs.MainWindow.Buttons = {
        Item_Button = defs.MainWindow.Window:FindFirstChild("Item_Button", true),
        Storage_Button = defs.MainWindow.Window:FindFirstChild("Storage_Button", true),
        Arrow_Button = defs.MainWindow.Window:FindFirstChild("Arrow_Button", true),
        Shop_Button = defs.MainWindow.Window:FindFirstChild("Shop_Button", true),
        Code_Button = defs.MainWindow.Window:FindFirstChild("Code_Button", true),
        Setting_Button = defs.MainWindow.Window:FindFirstChild("Setting_Button", true),
        Close_Button = defs.MainWindow.Window:FindFirstChild("CloseButton", true)
    }
defs.MainWindow.Panels = {
        Arrow_Panel = defs.MainWindow.Window:FindFirstChild("Arrow_Panel", true),
        Code_Panel = defs.MainWindow.Window:FindFirstChild("Code_Panel", true),
        Item_Panel = defs.MainWindow.Window:FindFirstChild("Item_Panel", true),
        Shop_Panel = defs.MainWindow.Window:FindFirstChild("Shop_Panel", true),
        Storage_Panel = defs.MainWindow.Window:FindFirstChild("Storage_Panel", true),
        Setting_Panel = defs.MainWindow.Window:FindFirstChild("Setting_Panel", true)
    }

--// Setup_MainWindow ------------------------------------------------------------
function GuiController:Setup_MainWindow()

    -- just be sure main window is off
    defs.MainWindow.Window.Visible = false

    -- connect buttons
    defs.MainWindow.Buttons.Close_Button.Activated:Connect(function()
        defs.MainWindow.Window.Visible = false
    end)

    defs.MainWindow.Buttons.Item_Button.Activated:Connect(function()
        self:ActivatePanel(defs.MainWindow,defs.MainWindow.Panels.Item_Panel)
    end)

    defs.MainWindow.Buttons.Arrow_Button.Activated:Connect(function()
        self:ActivatePanel(defs.MainWindow,defs.MainWindow.Panels.Arrow_Panel)
    end)

    defs.MainWindow.Buttons.Storage_Button.Activated:Connect(function()
        self:ActivatePanel(defs.MainWindow,defs.MainWindow.Panels.Storage_Panel)
    end)

    defs.MainWindow.Buttons.Shop_Button.Activated:Connect(function()
        self:ActivatePanel(defs.MainWindow,defs.MainWindow.Panels.Shop_Panel)
    end)

    defs.MainWindow.Buttons.Code_Button.Activated:Connect(function()
        self:ActivatePanel(defs.MainWindow,defs.MainWindow.Panels.Code_Panel)
    end)

    defs.MainWindow.Buttons.Setting_Button.Activated:Connect(function()
        self:ActivatePanel(defs.MainWindow,defs.MainWindow.Panels.Setting_Panel)
    end)

end

--// ActivateWindow ------------------------------------------------------------
function GuiController:ActivateWindow(windowDef,panelDef)

    -- turn off all panels, then turn on the one we want to start on
    for i,v in pairs(windowDef.Panels) do
        v.Visible = false
    end
    panelDef.Visible = true

    -- toggle the window 
    if windowDef.Window.Visible then
        windowDef.Window.Visible = false
    else
        windowDef.Window.Visible = true
    end
end

--// ActivatePanel
function GuiController:ActivatePanel(windowDef,panelDef)

    -- make sure the window is on
    if windowDef.Window.Visible == false then
        windowDef.Window.Visible = true
    end

    -- turn off all panels, then turn on the one we want to start on
    for i,v in pairs(windowDef.Panels) do
        v.Visible = false
    end
    panelDef.Visible = true

end

--// ====================================================================================================================================
--//  ARROW PANEL
--// ====================================================================================================================================

--// DEFS - ARROW PANEL ------------------------------------------------------------
defs.ArrowPanel = {
    Scrolling_Frame = defs.MainWindow.Panels.Arrow_Panel:FindFirstChild("ScrollingFrame", true),
    Item_Template = defs.MainWindow.Panels.Arrow_Panel:FindFirstChild("ItemTemplate", true),
    UseArrowFrame = defs.MainWindow.Panels.Arrow_Panel:FindFirstChild("UserArrowPanels"),
    UseArrowPanels = {
        Default_Panel = defs.MainWindow.Panels.Arrow_Panel:FindFirstChild("Default_Panel", true),
        UniversalArrow_Common = defs.MainWindow.Panels.Arrow_Panel:FindFirstChild("UniversalArrow_Common", true),
        UniversalArrow_Rare = defs.MainWindow.Panels.Arrow_Panel:FindFirstChild("UniversalArrow_Rare", true),
        UniversalArrow_Legendary = defs.MainWindow.Panels.Arrow_Panel:FindFirstChild("UniversalArrow_Legendary", true),
    },
    UseArrowButtons = {
        UniversalArrow_Common = defs.MainWindow.Panels.Arrow_Panel:FindFirstChild("UseArrow_Universal_Common", true),
        UniversalArrow_Rare = defs.MainWindow.Panels.Arrow_Panel:FindFirstChild("UseArrow_Universal_Rare", true),
        UniversalArrow_Legendary = defs.MainWindow.Panels.Arrow_Panel:FindFirstChild("UseArrow_Universal_Legendary", true),
    }
}

--// Setup_ArrowPanel ------------------------------------------------------------
function GuiController:Setup_ArrowPanel()
    defs.ArrowPanel.Item_Template.Visible = false

    -- connect Use Arrow buttons
    defs.ArrowPanel.UseArrowButtons.UniversalArrow_Common.Activated:Connect(function()
            params = {}
            params.Type = "UniversalArrow"
            params.Rarity = "Common"
            button = defs.ArrowPanel.UseArrowButtons.UniversalArrow_Common
            self:Request_UseArrow(params,button)
    end)
    defs.ArrowPanel.UseArrowButtons.UniversalArrow_Rare.Activated:Connect(function()
        params = {}
        params.Type = "UniversalArrow"
        params.Rarity = "Rare"
        button = defs.ArrowPanel.UseArrowButtons.UniversalArrow_Rare
        self:Request_UseArrow(params,button)
    end)
    defs.ArrowPanel.UseArrowButtons.UniversalArrow_Legendary.Activated:Connect(function()
        params = {}
        params.Type = "UniversalArrow"
        params.Rarity = "Legendary"
        button = defs.ArrowPanel.UseArrowButtons.UniversalArrow_Legendary
        self:Request_UseArrow(params,button)
    end)
end

--// Update_ArrowPanel ------------------------------------------------------------
function GuiController:Update_ArrowPanel(data)

    -- destroy all arrows int he scrolling frame
    for _,object in pairs(defs.ArrowPanel.Scrolling_Frame:GetChildren()) do
        if object.Name == "arrowItem" then
            object:Destroy()
        end
    end

    -- turn off all right panels and show default panel
    for i,v in pairs(defs.ArrowPanel.UseArrowFrame:GetChildren()) do
        if v:IsA("Frame") then
        v.Visible = false
        end
    end
    defs.ArrowPanel.UseArrowPanels.Default_Panel.Visible = true


    -- build all the arrows and put them in the scrollign frame
    for i,arrow in pairs(data) do

        -- make a new list item
        local newListItem = defs.ArrowPanel.Item_Template:Clone()
        newListItem.Parent = defs.ArrowPanel.Scrolling_Frame
        newListItem.Visible = true
        newListItem.Name = "arrowItem"

        -- change text
        local textLabel = newListItem:FindFirstChild("Arrow_Name", true)
        textLabel.Text = arrow.ArrowName

        -- set some values based on rarity
        local icon = newListItem:FindFirstChild("Arrow_Icon", true)
        local targetPanel
        if arrow.Rarity == "Common" then
            targetPanel = defs.ArrowPanel.UseArrowPanels.UniversalArrow_Common
        elseif arrow.Rarity == "Rare" then
            icon.ImageColor3 = Color3.new(10/255, 202/255, 0/255)
            textLabel.TextColor3 = Color3.new(10/255, 202/255, 0/255)
            targetPanel = defs.ArrowPanel.UseArrowPanels.UniversalArrow_Rare
        elseif arrow.Rarity == "Legendary" then
            icon.ImageColor3 = Color3.new(255/255, 149/255, 43/255)
            textLabel.TextColor3 = Color3.new(255/255, 149/255, 43/255)
            targetPanel = defs.ArrowPanel.UseArrowPanels.UniversalArrow_Legendary
        end

        -- connect the click to open the arrow panel
        newListItem.Activated:Connect(function()

            -- turn off all the use arrow panels
            for i,v in pairs(defs.ArrowPanel.UseArrowFrame:GetChildren()) do
                if v:IsA("Frame") then
                v.Visible = false
                end
            end

            targetPanel.Visible = true
        end)
    end

    -- finally, update the ScrollingFrame CanvasSize to match the UiListLayout
    defs.ArrowPanel.Scrolling_Frame.CanvasSize = UDim2.new(0, 0, 0, defs.ArrowPanel.Scrolling_Frame.UIListLayout.AbsoluteContentSize.Y)
end

--// Request_UseArrow ------------------------------------------------------------
function GuiController:Request_UseArrow(params,button)
    local currentPower = PowersService:GetCurrentPower()
    if currentPower == "Standless" then
        InventoryService:UseArrow(params)
    else
        print("USE ARROW BUTTON: You Must Be Standless")
        spawn(function()
            local buttonColor = button.BorderColor3
            local buttonText = button.Text
            local textColor = button.TextColor3
            local buttonSize = button.Size

            button.BorderColor3 = Color3.new(255/255, 0/255, 0/255)
            button.Text = "MUST BE STANDLESS"
            button.TextColor3 = Color3.new(255/255, 0/255, 0/255)
            button.Size = button.Size + UDim2.new(0,0,.5,0)
            button.Active = false

            wait(3)

            button.BorderColor3 = buttonColor
            button.Text = buttonText
            button.TextColor3 = textColor
            button.Size = buttonSize
            button.Active = true
        end)
    end
end

--// ====================================================================================================================================
--//  STAND STORAGE PANEL
--// ====================================================================================================================================

--// DEFS - Storage PANEL ------------------------------------------------------------
defs.StoragePanel = {}
defs.StoragePanel.Panel = mainGui.Windows:FindFirstChild("Storage_Panel", true)
defs.StoragePanel.DefaultCard = defs.StoragePanel.Panel:FindFirstChild("Default_Card", true)
defs.StoragePanel.Stand_Icons = mainGui.Stand_Icons

-- scrolling frame 
defs.StoragePanel.ItemTemplate = defs.StoragePanel.Panel:FindFirstChild("Item_Template", true)
defs.StoragePanel.ScrollingFrame = defs.StoragePanel.Panel:FindFirstChild("Scrolling_Frame", true)

-- stand card
defs.StoragePanel.StandCard = defs.StoragePanel.Panel:FindFirstChild("Stand_Card", true)
defs.StoragePanel.StandIconFrame = defs.StoragePanel.Panel:FindFirstChild("Stand_Icon_Frame", true)
defs.StoragePanel.StandName = defs.StoragePanel.Panel:FindFirstChild("Stand_Name", true)
defs.StoragePanel.StandRarity = defs.StoragePanel.Panel:FindFirstChild("Stand_Rarity", true)
defs.StoragePanel.Level = defs.StoragePanel.Panel:FindFirstChild("Stand_Level", true)
defs.StoragePanel.XpBar = defs.StoragePanel.Panel:FindFirstChild("Xp_Bar", true)
defs.StoragePanel.BaseValue = defs.StoragePanel.Panel:FindFirstChild("Base_Value", true)
defs.StoragePanel.TotalSlots = defs.StoragePanel.Panel:FindFirstChild("Total_Slots", true)
defs.StoragePanel.UsedSlots = defs.StoragePanel.Panel:FindFirstChild("Used_Slots", true)
defs.StoragePanel.ButtonPanelCurrent = defs.StoragePanel.Panel:FindFirstChild("ButtonPanel_Current", true)
defs.StoragePanel.ButtonPanelStored = defs.StoragePanel.Panel:FindFirstChild("ButtonPanel_Stored", true)

-- buttons
defs.StoragePanel.Button_CurrentStand = defs.StoragePanel.Panel:FindFirstChild("Button_CurrentStand", true)
defs.StoragePanel.Button_BuyStorage = defs.StoragePanel.Panel:FindFirstChild("Button_BuyStorage", true)
defs.StoragePanel.Button_EvolveStand = defs.StoragePanel.Panel:FindFirstChild("Button_EvolveStand", true)
defs.StoragePanel.Button_StoreStand = defs.StoragePanel.Panel:FindFirstChild("Button_StoreStand", true)
defs.StoragePanel.Button_SacrificeStand = defs.StoragePanel.Panel:FindFirstChild("Button_SacrificeStand", true)
defs.StoragePanel.Button_EquipStand = defs.StoragePanel.Panel:FindFirstChild("Button_EquipStand", true)




--// Setup_StandPanel ------------------------------------------------------------
function GuiController:Setup_StoragePanel()
    print("GuiController:Setup_StoragePanel()")

    -- make stand item template not visible
    defs.StoragePanel.ItemTemplate.Visible = false
    defs.StoragePanel.StandCard.Visible = false
    defs.StoragePanel.DefaultCard.Visible = true

    -- BUTTON - Current Stand
    defs.StoragePanel.Button_CurrentStand.Activated:Connect(function()
        print(defs.StoragePanel.Button_CurrentStand)
        self:Show_StandCard(defs.StoragePanel.Button_CurrentStand) -- Show_StandCard method uses value objects inside the button, these arre defined in the Update of the panel
    end)

    -- BUTTON - Buy Storage
    defs.StoragePanel.Button_BuyStorage.Activated:Connect(function()
        print(defs.StoragePanel.Button_BuyStorage)
    end)


end

--// Setup_StandButton
function GuiController:Setup_StandButton(list_Item, data, GUID)

    -- dont do this setup if the player is standless
    if data.Power == "Standless" then
        return
    end

    -- setup value objects
    local findPowerModule = Knit.Powers:FindFirstChild(data.Power)
    if findPowerModule then
        local powerModule = require(findPowerModule)

        -- GUID value object - GUID is the unique identifier for this stand
        local GUIDValue_Object = list_Item:FindFirstChild("GUIDValue_Object", true)
        if not GUIDValue_Object then
            GUIDValue_Object = utils.NewValueObject("GUIDValue_Object", GUID, list_Item)
        else
            GUIDValue_Object.Value = GUID
        end

        -- id value
        local idValue_Object = list_Item:FindFirstChild("idValue_Object", true)
        if not idValue_Object then
            idValue_Object = utils.NewValueObject("idValue_Object", data.Power, list_Item)
        else
            idValue_Object.Value = data.Power
        end

        -- name value
        local nameValue_Object = list_Item:FindFirstChild("nameValue_Object", true)
        if not nameValue_Object then
            nameValue_Object = utils.NewValueObject("nameValue_Object", powerModule.Defs.PowerName, list_Item)
        else
            nameValue_Object.Value = powerModule.Defs.PowerName
        end

        -- xp value
        local xpValue_Object = list_Item:FindFirstChild("xpValue_Object", true)
        if not xpValue_Object then
            xpValue_Object = utils.NewValueObject("xpValue_Object", data.Xp, list_Item)
        else
            xpValue_Object.Value = data.Xp
        end

        -- rarity value
        local rarityValue_Object = list_Item:FindFirstChild("rarityValue_Object", true)
        if not rarityValue_Object then
            rarityValue_Object = utils.NewValueObject("rarityValue_Object", data.Rarity, list_Item)
        else
            rarityValue_Object.Value = data.Rarity
        end

        -- base sacrifice value
        local sacrificeValue_Object = list_Item:FindFirstChild("sacrificeValue_Object", true)
        if not sacrificeValue_Object then
            sacrificeValue_Object = utils.NewValueObject("sacrificeValue_Object", powerModule.Defs.BaseSacrificeValue, list_Item)
        else
            sacrificeValue_Object.Value = powerModule.Defs.BaseSacrificeValue
        end

        -- stand icon value
        local iconName = data.Power .. "_" .. data.Rarity
        local iconValue_Object = list_Item:FindFirstChild("iconValue_Object", true)
        if not iconValue_Object then
            iconValue_Object = Instance.new("ObjectValue")
            iconValue_Object.Name = "iconValue_Object"
            iconValue_Object.Value = defs.StoragePanel.Stand_Icons:FindFirstChild(iconName)
            iconValue_Object.Parent = list_Item
        else
            iconValue_Object.Value = defs.StoragePanel.Stand_Icons:FindFirstChild(iconName)
        end

        -- setup the list_Item text stuff
        if list_Item:FindFirstChild("List_Item_StandName", true) then
            local listItemName = list_Item:FindFirstChild("List_Item_StandName", true)
            listItemName.Text = powerModule.Defs.PowerName
            if data.Rarity == "Common" then
                listItemName.TextColor3 = Color3.new(239/255, 239/255, 239/255)
            elseif data.Rarity == "Rare" then
                listItemName.TextColor3 = Color3.new(10/255, 202/255, 0/255)
            elseif data.Rarity == "Legendary" then
                listItemName.TextColor3 = Color3.new(255/255, 149/255, 43/255)
            end
        end

        if list_Item:FindFirstChild("List Item_StandLevel", true) then
            local level = self:GetLevelFromXp(data.Xp)
            list_Item:FindFirstChild("List Item_StandLevel", true).Text = tostring(level)
        end

        list_Item.Activated:Connect(function()
            self:Show_StandCard(list_Item)
        end)

    end
end

--// Update_StandPanel ------------------------------------------------------------
function GuiController:Update_StoragePanel(characterData, storageData)

    defs.StoragePanel.StandCard.Visible = false
    defs.StoragePanel.DefaultCard.Visible = true

    -- update the max slots and used slots
    local counter = 0 
    if storageData.StoredStands ~= nil then
        for _,v in pairs(storageData.StoredStands) do
            counter = counter + 1
        end
    end
    defs.StoragePanel.TotalSlots.Text = storageData.MaxSlots
    defs.StoragePanel.UsedSlots.Text = counter

    -- setup the current stand button
    if characterData.CurrentPower == "Standless" then
        
        -- the setup doesnt run when this button is standless, so we need to set the text here
        local textLabel = defs.StoragePanel.Button_CurrentStand:FindFirstChild("List_Item_StandName", true)
        textLabel.Text = "Standless"
        textLabel.TextColor3 = Color3.new(239/255, 239/255, 239/255)

        -- deactivate the button
        defs.StoragePanel.Button_CurrentStand.Active = false

    else
        print("NOT standless!")
        -- make it active if the player has a stand
        defs.StoragePanel.Button_CurrentStand.Active = true
    end

    -- setup the current stand button
    local currentStandData = {}
    currentStandData.Power = characterData.CurrentPower
    currentStandData.Rarity = characterData.CurrentPowerRarity
    currentStandData.Xp = characterData.CurrentPowerXp
    self:Setup_StandButton(defs.StoragePanel.Button_CurrentStand, currentStandData)

    
    -- clear out the list
    for _,object in pairs(defs.StoragePanel.ScrollingFrame:GetChildren()) do
        if object.Name == "standItem" then
            object:Destroy()
        end
    end

    -- add stored stands to the list
    if storageData.StoredStands ~= nil then
        for GUID,stand in pairs(storageData.StoredStands) do

            -- make a new list item
            local newListItem = defs.StoragePanel.ItemTemplate:Clone()
            newListItem.Parent = defs.StoragePanel.ScrollingFrame
            newListItem.Visible = true
            newListItem.Name = "standItem"

            print("Stand",GUID,stand)

            self:Setup_StandButton(newListItem, stand, GUID)
            
        end
    end

end

--// Show_StandCard
function GuiController:Show_StandCard(button)

    -- set the icon
    local newIcon -- decalre it up here, yup
    if button.iconValue_Object.Value == nil then
        -- print its nil!
    else
        newIcon = button.iconValue_Object.Value:Clone()
        newIcon.BorderSizePixel = 4
        newIcon.Parent = defs.StoragePanel.StandIconFrame
        newIcon.Visible = true
    end

    -- set name and rarity
    defs.StoragePanel.StandName.Text = button.nameValue_Object.Value
    defs.StoragePanel.StandRarity.Text = button.rarityValue_Object.Value
    if button.rarityValue_Object.Value == "Common" then
        defs.StoragePanel.StandRarity.TextColor3 = Color3.new(239/255, 239/255, 239/255)
    elseif button.rarityValue_Object.Value == "Rare" then
        defs.StoragePanel.StandRarity.TextColor3 = Color3.new(10/255, 202/255, 0/255)
    elseif button.rarityValue_Object.Value == "Legendary" then
        defs.StoragePanel.StandRarity.TextColor3 = Color3.new(255/255, 149/255, 43/255)
    end

    -- set level and xp bar
    local level, remainingPercent = self:GetLevelFromXp(button.xpValue_Object.Value)
    defs.StoragePanel.Level.Text = tostring(level)
    local width = remainingPercent / 100
    defs.StoragePanel.XpBar.Size = UDim2.new(width, defs.StoragePanel.XpBar.Size.X.Offset, defs.StoragePanel.XpBar.Size.Y.Scale, defs.StoragePanel.XpBar.Size.Y.Offset)

    -- set base value
    defs.StoragePanel.BaseValue.Text = button.sacrificeValue_Object.Value

    
    -- the the Visible settings at the end
    defs.StoragePanel.StandCard.Visible = true
    defs.StoragePanel.DefaultCard.Visible = false

    -- setup the button panel
    if button.Name == "Button_CurrentStand" then
        defs.StoragePanel.ButtonPanelCurrent.Visible = true
        defs.StoragePanel.ButtonPanelStored.Visible = false

        defs.StoragePanel.Button_StoreStand.Active = true
        defs.StoragePanel.Button_SacrificeStand.Active = true

        defs.StoragePanel.Button_EquipStand.Active = false
        defs.StoragePanel.Button_EvolveStand.Active = false
    else
        defs.StoragePanel.ButtonPanelCurrent.Visible = false
        defs.StoragePanel.ButtonPanelStored.Visible = true

        defs.StoragePanel.Button_StoreStand.Active = false
        defs.StoragePanel.Button_SacrificeStand.Active = false

        defs.StoragePanel.Button_EquipStand.Active = true
        defs.StoragePanel.Button_EvolveStand.Active = true
    end

    -- BUTTON - Evolve Stand
    defs.StoragePanel.Button_EvolveStand.Activated:Connect(function()
        print(defs.StoragePanel.Button_EvolveStand)
    end)

    -- BUTTON - Store Stand
    defs.StoragePanel.Button_StoreStand.Activated:Connect(function()
        InventoryService:StoreStand()
    end)

    -- BUTTON - Sacrifice Stand
    defs.StoragePanel.Button_SacrificeStand.Activated:Connect(function()
        print(defs.StoragePanel.Button_SacrificeStand)
        InventoryService:SacrificeStand(buttons.GUIDValue_Object.Value) -- send the GUID of the stand shown
    end)

    -- BUTTON - Equip Stand
    defs.StoragePanel.Button_EquipStand.Activated:Connect(function()
        print(defs.StoragePanel.Button_EquipStand)
    end)

end

--// Request_EquipStand ------------------------------------------------------------
function GuiController:Request_EquipStand()

end

--// Request_EvolveStand ------------------------------------------------------------
function GuiController:Request_EvolveStand()

end

--// Request_SellStand ------------------------------------------------------------
function GuiController:Request_SellStand()

end

--// ====================================================================================================================================
--//  OVERLAY - STAND REVEAL
--// ====================================================================================================================================

--// DEFS - OVERLAY - STAND REVEAL ------------------------------------------------------------
defs.Stand_Reveal = {
    Main_Frame = mainGui.Overlays:FindFirstChild("Stand_Reveal", true),
    Asset_Folder = mainGui.Overlays.Stand_Reveal:FindFirstChild("Assets", true),
    Temp_Assets = mainGui.Overlays.Stand_Reveal:FindFirstChild("TempAssets", true),
    Elements = {
        Button_Frame = mainGui.Overlays.Stand_Reveal:FindFirstChild("Button_Frame", true),
        Icon_Frame = mainGui.Overlays.Stand_Reveal:FindFirstChild("Icon_Frame", true),
        Storage_Warning = mainGui.Overlays.Stand_Reveal:FindFirstChild("Storage_Warning", true),
        Stand_Name = mainGui.Overlays.Stand_Reveal:FindFirstChild("Stand_Name", true),
        Stand_Rarity = mainGui.Overlays.Stand_Reveal:FindFirstChild("Stand_Rarity", true),
        Rays_1 = mainGui.Overlays.Stand_Reveal:FindFirstChild("Rays_1", true),
        Rays_2 = mainGui.Overlays.Stand_Reveal:FindFirstChild("Rays_2", true),
        Rays_3 = mainGui.Overlays.Stand_Reveal:FindFirstChild("Rays_3", true),
        Burst_1 = mainGui.Overlays.Stand_Reveal:FindFirstChild("Burst_1", true),
        Burst_2 = mainGui.Overlays.Stand_Reveal:FindFirstChild("Burst_2", true),
        Balls_1 = mainGui.Overlays.Stand_Reveal:FindFirstChild("Balls_1", true),
        Balls_2 = mainGui.Overlays.Stand_Reveal:FindFirstChild("Balls_2", true),
    },
    Buttons = {
        Equip_Button = mainGui.Overlays.Stand_Reveal:FindFirstChild("Equip_Button", true),
        Store_Button = mainGui.Overlays.Stand_Reveal:FindFirstChild("Store_Button", true),
        MobileStorage_BuyButton = mainGui.Overlays.Stand_Reveal:FindFirstChild("MobileStorage_Buy_Button", true),
    }
}


--// Setup_StandReveal ------------------------------------------------------------
function GuiController:Setup_StandReveal()

    -- be sure the stand reveal is closed
    defs.Stand_Reveal.Main_Frame.Visible = false

    -- also be sure all elements have visibility off, we can turn them on one by one
    for _,element in pairs(defs.Stand_Reveal.Elements) do
        element.Visible = false
    end

    -- setup the buttons
    defs.Stand_Reveal.Buttons.Equip_Button.Activated:Connect(function()
        self:StandReveal_ActivateClose()
    end)
    defs.Stand_Reveal.Buttons.Store_Button.Activated:Connect(function()
        self:StandReveal_ActivateQuickStore()
    end)
    defs.Stand_Reveal.Buttons.MobileStorage_BuyButton.Activated:Connect(function()
        GamePassService:Prompt_GamePassPurchase("MobileStandStorage")
    end)

end

--// StandReveal_QuickStore ------------------------------------------------------------
function GuiController:StandReveal_ActivateQuickStore()


    if GamePassService:Has_GamePass("MobileStandStorage") then
        self:Request_StoreStand()
        self:StandReveal_ActivateClose()
    else
        self:StandReveal_StorageWarning()
    end
    
end

--// Update_StandReveal ------------------------------------------------------------
function GuiController:Update_StandReveal(data)

    -- get the module for the stand that just got revealed, also the players CurrentStand, we need this to get the actual name
    local currentPowerModule = Knit.Powers:FindFirstChild(data.CurrentPower)
    local powerModule = require(currentPowerModule)

    -- set things based on rarity
    defs.Stand_Reveal.Elements.Stand_Name.Text = powerModule.Defs.PowerName
    defs.Stand_Reveal.Elements.Stand_Rarity.Text = data.CurrentPowerRarity
    if data.CurrentPowerRarity == "Common" then
        defs.Stand_Reveal.Elements.Stand_Rarity.TextColor3 = Color3.new(255/255, 255/255, 255/255)
    elseif data.CurrentPowerRarity == "Rare" then
        defs.Stand_Reveal.Elements.Stand_Rarity.TextColor3 = Color3.new(10/255, 202/255, 0/255)
    elseif data.CurrentPowerRarity == "Legendary" then
        defs.Stand_Reveal.Elements.Stand_Rarity.TextColor3 = Color3.new(255/255, 149/255, 43/255)
    end

    -- clear old icons out of the container
    defs.Stand_Reveal.Elements.Icon_Frame.Icon_Container:ClearAllChildren()

    print("Poop",data.CurrentPower)

    -- clone in a new icon
    --local newIcon = mainGui.Stand_Icons:FindFirstChild(data.CurrentPower):Clone()
    local standIcon = data.CurrentPower .. "_" .. data.CurrentPowerRarity
    local newIcon = mainGui.Stand_Icons:FindFirstChild(standIcon):Clone()
    newIcon.Visible = true
    newIcon.Parent = defs.Stand_Reveal.Elements.Icon_Frame.Icon_Container

    self:StandReveal_RevealStand()

end

--// Show_StandReveal ------------------------------------------------------------
function GuiController:StandReveal_RevealStand()

    -- create some new animation objects, so we leave to originals in place
    local newRay_1 = defs.Stand_Reveal.Elements.Rays_1:Clone()
    local newRay_2 = defs.Stand_Reveal.Elements.Rays_2:Clone()
    local newRay_3 = defs.Stand_Reveal.Elements.Rays_3:Clone()
    local newRay_4 = defs.Stand_Reveal.Elements.Rays_3:Clone()

    local newBurst_1 = defs.Stand_Reveal.Elements.Burst_1:Clone()
    local newBurst_2 = defs.Stand_Reveal.Elements.Burst_2:Clone()

    local newBalls_1 = defs.Stand_Reveal.Elements.Balls_1:Clone()
    local newBalls_2 = defs.Stand_Reveal.Elements.Balls_2:Clone()

    newRay_1.Parent = defs.Stand_Reveal.Temp_Assets
    newRay_2.Parent = defs.Stand_Reveal.Temp_Assets
    newRay_3.Parent = defs.Stand_Reveal.Temp_Assets
    newRay_4.Parent = defs.Stand_Reveal.Temp_Assets
    newBurst_1.Parent = defs.Stand_Reveal.Temp_Assets
    newBurst_2.Parent = defs.Stand_Reveal.Temp_Assets
    newBalls_1.Parent = defs.Stand_Reveal.Temp_Assets
    newBalls_2.Parent = defs.Stand_Reveal.Temp_Assets

    -- save some final sizes for elements
    local finalIconFrame_Size = defs.Stand_Reveal.Elements.Icon_Frame.Size
    local finalName_Size = defs.Stand_Reveal.Elements.Stand_Name.Size
    local finalRays_1_Size = defs.Stand_Reveal.Elements.Rays_1.Size
    local finalRays_2_Size = defs.Stand_Reveal.Elements.Rays_2.Size
    local finalRays_3_Size = defs.Stand_Reveal.Elements.Rays_3.Size
    local finalRays_4_Size = defs.Stand_Reveal.Elements.Rays_3.Size
    local finalBurst_1_Size = defs.Stand_Reveal.Elements.Burst_1.Size
    local finalBurst_2_Size = defs.Stand_Reveal.Elements.Burst_2.Size
    local finalBalls_1_Size = defs.Stand_Reveal.Elements.Balls_1.Size
    local finalBalls_2_Size = defs.Stand_Reveal.Elements.Balls_2.Size

    --now lets make some smaller so we can pop them
    defs.Stand_Reveal.Elements.Icon_Frame.Size = UDim2.new(0, 0, 0, 0)
    defs.Stand_Reveal.Elements.Stand_Name.Size = UDim2.new(0, 0, 0, 0)
    newRay_1.Size = UDim2.new(0, 0, 0, 0)
    newRay_2.Size = UDim2.new(0, 0, 0, 0)
    newRay_3.Size = UDim2.new(0, 0, 0, 0)
    newRay_4.Size = UDim2.new(0, 0, 0, 0)
    newBurst_1.Size = UDim2.new(2, 0, 2, 0)
    newBurst_2.Size = UDim2.new(0, 0, 0, 0)
    newBalls_1.Size = UDim2.new(2, 0, 2, 0)
    newBalls_2.Size = UDim2.new(0, 0, 0, 0)

    -- tweens 
    local tweenInfo_Size = TweenInfo.new(.5,Enum.EasingStyle.Bounce)

    -- icon and text
    local sizeTween_IconFrame = TweenService:Create(defs.Stand_Reveal.Elements.Icon_Frame,tweenInfo_Size,{Size = finalIconFrame_Size})
    local sizeTween_Name = TweenService:Create(defs.Stand_Reveal.Elements.Stand_Name,tweenInfo_Size,{Size = finalName_Size})

    -- Rays_1
    local sizeTween_Rays_1 = TweenService:Create(newRay_1,tweenInfo_Size,{Size = finalRays_1_Size})
    local spinTween_Rays_1 = TweenService:Create(newRay_1,TweenInfo.new(40,Enum.EasingStyle.Linear),{Rotation = 359})

    -- Ray_2
    local sizeTween_Rays_2 = TweenService:Create(newRay_2,tweenInfo_Size,{Size = finalRays_2_Size})
    local spinTween_Rays_2 = TweenService:Create(newRay_2,TweenInfo.new(60,Enum.EasingStyle.Linear),{Rotation = -359})

    -- Ray_3
    local sizeTween_Rays_3 = TweenService:Create(newRay_3,tweenInfo_Size,{Size = finalRays_3_Size})
    local spinTween_Rays_3 = TweenService:Create(newRay_3,TweenInfo.new(10,Enum.EasingStyle.Linear),{Rotation = 359})

    -- Ray_3
    local sizeTween_Rays_4 = TweenService:Create(newRay_4,tweenInfo_Size,{Size = finalRays_4_Size})
    local spinTween_Rays_4 = TweenService:Create(newRay_4,TweenInfo.new(10,Enum.EasingStyle.Linear),{Rotation = -359})

    -- newBurst_1
    local sizeTween_newBurst_1 = TweenService:Create(newBurst_1,TweenInfo.new(2,Enum.EasingStyle.Elastic),{Size = finalBurst_1_Size})
    local spinTween_newBurst_1 = TweenService:Create(newBurst_1,TweenInfo.new(5,Enum.EasingStyle.Linear),{Rotation = -359})

    -- newBalls_1
    local sizeTween_newBalls_1 = TweenService:Create(newBalls_1,tweenInfo_Size,{Size = finalBalls_1_Size})
    local spinTween_newBalls_1 = TweenService:Create(newBalls_1,TweenInfo.new(10,Enum.EasingStyle.Linear),{Rotation = 359})

    -- newBurst_2
    local sizeTween_newBurst_2 = TweenService:Create(newBurst_2,TweenInfo.new(1,Enum.EasingStyle.Elastic),{Size = finalBurst_2_Size})
    local spinTween_newBurst_2 = TweenService:Create(newBurst_2,TweenInfo.new(60,Enum.EasingStyle.Linear),{Rotation = 359})

    -- newBalls_2
    local sizeTween_newBalls_2 = TweenService:Create(newBalls_2,tweenInfo_Size,{Size = finalBalls_2_Size})
    local spinTween_newBalls_2 = TweenService:Create(newBalls_2,TweenInfo.new(180,Enum.EasingStyle.Linear),{Rotation = -359})

    -- completed event
    spinTween_Rays_1.Completed:Connect(function(playbackState)
        if playbackState == Enum.PlaybackState.Completed then
            self:StandReveal_ActivateClose()
        end
    end)

    spawn(function()

        -- make some things visible
        defs.Stand_Reveal.Main_Frame.Visible = true
        newBurst_1.Visible = true
        newBalls_1.Visible = true
        newRay_3.Visible = true
        newRay_4.Visible = true

        -- start the initial tweens
        sizeTween_Rays_3:Play()
        spinTween_Rays_3:Play()
        sizeTween_Rays_4:Play()
        spinTween_Rays_4:Play()
        sizeTween_newBurst_1:Play()
        sizeTween_newBalls_1:Play()
        spinTween_newBurst_1:Play()
        spinTween_newBalls_1:Play()

        wait(1.5)

        -- more makign of things visible
        defs.Stand_Reveal.Elements.Icon_Frame.Visible = true
        defs.Stand_Reveal.Elements.Button_Frame.Visible = true
        defs.Stand_Reveal.Elements.Stand_Name.Visible = true
        defs.Stand_Reveal.Elements.Stand_Rarity.Visible = true
        newRay_1.Visible = true
        newRay_2.Visible = true
        newBurst_2.Visible = true
        newBalls_2.Visible = true

        sizeTween_IconFrame:Play()
        sizeTween_Name:Play()

        sizeTween_Rays_1:Play()
        sizeTween_Rays_2:Play()
        spinTween_Rays_1:Play()
        spinTween_Rays_2:Play()

        sizeTween_newBurst_2:Play()
        spinTween_newBurst_2:Play()

        sizeTween_newBalls_2:Play()
        spinTween_newBalls_2:Play()

        newBurst_1:Destroy()
        newBalls_1:Destroy()
        newRay_3:Destroy()
        newRay_4:Destroy()
    
    end)

end

--// Close_StandReveal ------------------------------------------------------------
function GuiController:StandReveal_ActivateClose()

    defs.Stand_Reveal.Temp_Assets:ClearAllChildren()

    -- make it invisible
    defs.Stand_Reveal.Main_Frame.Visible = false 

    -- also be sure all elements have visibility off, we can turn them on one by one
    for _,element in pairs(defs.Stand_Reveal.Elements) do
        element.Visible = false
    end

    
    --defs.Stand_Reveal.Elements.Storage_Warning.Visible = false
end

--// StandReveal_ActivateMobileStorageFrame
function GuiController:StandReveal_StorageWarning()

    -- stroe the destination position
    local finalPosition = defs.Stand_Reveal.Elements.Storage_Warning.Position

    -- move it over and mae it visible
    defs.Stand_Reveal.Elements.Storage_Warning.Position = defs.Stand_Reveal.Elements.Storage_Warning.Position + UDim2.new(1,0,0,0)
    defs.Stand_Reveal.Elements.Storage_Warning.Visible = true

    -- setup tween
    local moveTween = TweenService:Create(defs.Stand_Reveal.Elements.Storage_Warning,TweenInfo.new(.5),{Position = finalPosition})
    moveTween:Play()

    spawn(function()

        local originalSize = defs.Stand_Reveal.Buttons.Store_Button.Size
        local originalColor = defs.Stand_Reveal.Buttons.Store_Button.TextColor3
        local originalText = defs.Stand_Reveal.Buttons.Store_Button.Text
        local originalBackgroundColor = defs.Stand_Reveal.Buttons.Store_Button.BackgroundColor3

        defs.Stand_Reveal.Buttons.Store_Button.Size = defs.Stand_Reveal.Buttons.Store_Button.Size + UDim2.new(.01,0,.01,0)
        defs.Stand_Reveal.Buttons.Store_Button.BackgroundColor3 = Color3.new(45/255, 45/255, 45/255)
        defs.Stand_Reveal.Buttons.Store_Button.TextColor3 = Color3.new(255/255, 0/255, 0/255)
        defs.Stand_Reveal.Buttons.Store_Button.Text = "NOPE"
        defs.Stand_Reveal.Buttons.Store_Button.Active = false

        wait(3)

        defs.Stand_Reveal.Buttons.Store_Button.Size = originalSize
        defs.Stand_Reveal.Buttons.Store_Button.BackgroundColor3 = originalBackgroundColor
        defs.Stand_Reveal.Buttons.Store_Button.TextColor3 = originalColor
        defs.Stand_Reveal.Buttons.Store_Button.Text = originalText
        defs.Stand_Reveal.Buttons.Store_Button.Active = true


    end)

end


--// ====================================================================================================================================
--//  GENERAL UTILITY
--// ====================================================================================================================================

--// Request_GuiUpdate ------------------------------------------------------------
function GuiController:Request_GuiUpdate(requestName)
    GuiService:Request_GuiUpdate(requestName)
end

function GuiController:GetLevelFromXp(xpNumber)

    local xpPerLevel = 3600

    local rawLevel = xpNumber / xpPerLevel
    local actualLevel = math.floor(rawLevel)

    local remainingXp = (xpNumber - (actualLevel * xpPerLevel))
    local percentageRemaining = (remainingXp / xpPerLevel * 100)

    return actualLevel, percentageRemaining

end

--// ====================================================================================================================================
--//  KNIT
--// ====================================================================================================================================

--// KnitStart ------------------------------------------------------------
function GuiController:KnitStart()

    -- do some setups
    self:Setup_PowerButton()
    self:Setup_LeftGui()
    self:Setup_MainWindow()
    self:Setup_ArrowPanel()
    self:Setup_StandReveal()
    self:Setup_StoragePanel()

    -- request Gui Updates
    self:Request_GuiUpdate("ArrowPanel")
    self:Request_GuiUpdate("Cash")
    self:Request_GuiUpdate("Character")
    self:Request_GuiUpdate("StoragePanel")


    -- connect events
    GuiService.Event_Update_ArrowPanel:Connect(function(data)
        self:Update_ArrowPanel(data)
    end)

    GuiService.Event_Update_Cash:Connect(function(value)
        self:Update_Cash(value)
    end)

    GuiService.Event_Update_Character:Connect(function(data)
        self:Update_Character(data)
    end)

    GuiService.Event_Update_StandReveal:Connect(function(data)
        self:Update_StandReveal(data)
    end)

    GuiService.Event_Update_StoragePanel:Connect(function(characterData, storageData)
        self:Update_StoragePanel(characterData, storageData)
    end)

end

--// KnitInit ------------------------------------------------------------
function GuiController:KnitInit()

end


return GuiController