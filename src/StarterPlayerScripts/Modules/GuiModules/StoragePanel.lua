-- Storage Panel
-- PDab
-- 1/2/2021

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)

local StoragePanel = {}

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
function StoragePanel:Setup_StoragePanel()
    print("GuiController:Setup_StoragePanel()")

    -- make stand item template not visible
    defs.StoragePanel.ItemTemplate.Visible = false
    defs.StoragePanel.StandCard.Visible = false
    defs.StoragePanel.DefaultCard.Visible = true

    -- BUTTON - Buy Storage
    defs.StoragePanel.Button_BuyStorage.Activated:Connect(function()
        print(defs.StoragePanel.Button_BuyStorage)
    end)

    -- BUTTON - Evolve Stand
    defs.StoragePanel.Button_EvolveStand.Activated:Connect(function()
        print(defs.StoragePanel.Button_EvolveStand)
    end)

    -- BUTTON - Store Stand
    defs.StoragePanel.Button_StoreStand.Activated:Connect(function()
        InventoryService:StoreStand() -- you can only store the active stand, so we dont need to send any data here
    end)

    -- BUTTON - Sacrifice Stand
    defs.StoragePanel.Button_SacrificeStand.Activated:Connect(function()
        -- InventoryService:SacrificeStand(standCardGUID) -- send the GUID of the stand shown on the stand card
    end)

    -- BUTTON - Equip Stand
    defs.StoragePanel.Button_EquipStand.Activated:Connect(function()
        print(defs.StoragePanel.Button_EquipStand)
    end)
end

--// Setup_StandButton
function StoragePanel:Setup_StandButton(list_Item, standData, buttonType)

    local findPowerModule = Knit.Powers:FindFirstChild(standData.Power)
    if findPowerModule then

        -- require it
        local powerModule = require(findPowerModule)

        -- setup the list_Item text stuff
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
            local level = powerUtils.GetLevelFromXp(standData.Xp)
            listItemLevel.Text = tostring(level)
        end

        -- add the icon to the standData
        standData.Icon = defs.StoragePanel.Stand_Icons:FindFirstChild(standData.Power .. "_" .. standData.Rarity)

        -- add sacrifice value to teh standData
        standData.BaseValue = powerModule.Defs.BaseSacrificeValue

        -- add the actual name to the standData
        standData.Name = powerModule.Defs.PowerName

        -- connect the button click
        list_Item.Activated:Connect(function()
            self:Show_StandCard(standData, buttonType)
        end)

    end
end

--// Update_StandPanel ------------------------------------------------------------
function StoragePanel:Update_StoragePanel(currentStand, storageData)

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

    -- get rid of the old tempoirary Current Power buttons
    for _,object in pairs(defs.StoragePanel.Button_CurrentStand.Parent:GetChildren()) do
        if object.Name == "TempButton" then
            object:Destroy()
        end
    end

    -- setup the Current Power button
    if currentStand.Power == "Standless" then

        -- button settings
        defs.StoragePanel.Button_CurrentStand.Visible = true
        defs.StoragePanel.Button_CurrentStand.Active = false

        -- the setup doesnt run when this button is standless, so we need to set the text here
        local textLabel = defs.StoragePanel.Button_CurrentStand:FindFirstChild("List_Item_StandName", true)
        textLabel.Text = "Standless"
        textLabel.TextColor3 = Color3.new(239/255, 239/255, 239/255)

    else
        -- button settings
        defs.StoragePanel.Button_CurrentStand.Active = false
        defs.StoragePanel.Button_CurrentStand.Visible = false

        -- clone a new button and destroy old one to get rid of old conneciton. BUH BYE MEMEORY LEAKS!
        local newButton = defs.StoragePanel.Button_CurrentStand:Clone()
        local newButtonParent = defs.StoragePanel.Button_CurrentStand.Parent

        -- set it up
        newButton.Parent = newButtonParent
        newButton.Active = true
        newButton.Visible = true
        newButton.Name = "TempButton"

        -- do the setup
        self:Setup_StandButton(newButton, currentStand, "CurrentStand")

    end

    
    -- clear out the list of objects from last time
    for _,object in pairs(defs.StoragePanel.ScrollingFrame:GetChildren()) do
        if object.Name == "standItem" then
            object:Destroy()
        end
    end

    -- add stored stands to the list
    if storageData.StoredStands ~= nil then
        for index,stand in pairs(storageData.StoredStands) do

            -- make a new list item
            local newListItem = defs.StoragePanel.ItemTemplate:Clone()
            newListItem.Parent = defs.StoragePanel.ScrollingFrame
            newListItem.Visible = true
            newListItem.Name = "standItem"

            self:Setup_StandButton(newListItem, stand, "StoredStand")
            
        end
    end
end

--// Show_StandCard
function StoragePanel:Show_StandCard(standData, buttonType)

    standCardGUID = standData.GUID

    -- delete the old icons
    for _,object in pairs(defs.StoragePanel.StandIconFrame:GetChildren()) do
        if object.name == "TempIcon" then
            object:Destroy()
        end
    end

    -- set icon
    newIcon = standData.Icon:Clone()
    newIcon.BorderSizePixel = 4
    newIcon.Parent = defs.StoragePanel.StandIconFrame
    newIcon.Visible = true
    newIcon.Name = "TempIcon"

    -- set name and rarity
    defs.StoragePanel.StandName.Text = standData.Name
    defs.StoragePanel.StandRarity.Text = standData.Rarity
    if standData.Rarity == "Common" then
        defs.StoragePanel.StandRarity.TextColor3 = GUI_COLOR.COMMON
    elseif standData.Rarity == "Rare" then
        defs.StoragePanel.StandRarity.TextColor3 = GUI_COLOR.RARE
    elseif standData.Rarity == "Legendary" then
        defs.StoragePanel.StandRarity.TextColor3 = GUI_COLOR.LEGENDARY
    end

    -- set level and xp bar
    local level, remainingPercent = powerUtils.GetLevelFromXp(standData.Xp)
    defs.StoragePanel.Level.Text = tostring(level)
    local width = remainingPercent / 100
    defs.StoragePanel.XpBar.Size = UDim2.new(width, defs.StoragePanel.XpBar.Size.X.Offset, defs.StoragePanel.XpBar.Size.Y.Scale, defs.StoragePanel.XpBar.Size.Y.Offset)

    -- set base value
    defs.StoragePanel.BaseValue.Text = standData.BaseValue

    -- setup the button panel
    if buttonType == "CurrentStand" then
        defs.StoragePanel.ButtonPanelCurrent.Visible = true
        defs.StoragePanel.ButtonPanelStored.Visible = false

        defs.StoragePanel.Button_StoreStand.Active = true
        defs.StoragePanel.Button_EvolveStand.Active = true

        defs.StoragePanel.Button_SacrificeStand.Active = false
        defs.StoragePanel.Button_EquipStand.Active = false
        
    else
        defs.StoragePanel.ButtonPanelCurrent.Visible = false
        defs.StoragePanel.ButtonPanelStored.Visible = true

        defs.StoragePanel.Button_StoreStand.Active = false
        defs.StoragePanel.Button_EvolveStand.Active = false

        defs.StoragePanel.Button_SacrificeStand.Active = true
        defs.StoragePanel.Button_EquipStand.Active = true
    end

    -- the the Visible settings at the end
    defs.StoragePanel.StandCard.Visible = true
    defs.StoragePanel.DefaultCard.Visible = false

end

--// Request_EquipStand ------------------------------------------------------------
function StoragePanel:Request_EquipStand()

end

--// Request_EvolveStand ------------------------------------------------------------
function StoragePanel:Request_EvolveStand()

end

--// Request_SellStand ------------------------------------------------------------
function StoragePanel:Request_SellStand()

end


return StoragePanel