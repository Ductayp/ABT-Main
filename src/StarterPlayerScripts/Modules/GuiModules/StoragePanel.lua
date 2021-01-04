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



--// Setup_StandPanel ------------------------------------------------------------
function StoragePanel.Setup()

    -- make stand item template not visible
    StoragePanel.ItemTemplate.Visible = false
    StoragePanel.StandCard.Visible = false
    StoragePanel.DefaultCard.Visible = true

    -- BUTTON - Buy Storage
    StoragePanel.Button_BuyStorage.Activated:Connect(function()
        print(StoragePanel.Button_BuyStorage)
    end)

    -- BUTTON - Evolve Stand
    StoragePanel.Button_EvolveStand.Activated:Connect(function()
        print(StoragePanel.Button_EvolveStand)
    end)

    -- BUTTON - Store Stand
    StoragePanel.Button_StoreStand.Activated:Connect(function()
        InventoryService:StoreStand() -- you can only store the active stand, so we dont need to send any data here
    end)

    -- BUTTON - Sacrifice Stand
    StoragePanel.Button_SacrificeStand.Activated:Connect(function()
        InventoryService:SacrificeStand(StoragePanel.StandCardGUID) -- send the GUID of the stand shown on the stand card
    end)

    -- BUTTON - Equip Stand
    StoragePanel.Button_EquipStand.Activated:Connect(function()
        print(StoragePanel.Button_EquipStand)
    end)
end

--// Setup_StandButton
function StoragePanel.Build_StandButton(list_Item, standData, buttonType)

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
        standData.Icon = StoragePanel.Stand_Icons:FindFirstChild(standData.Power .. "_" .. standData.Rarity)

        -- add sacrifice value to teh standData
        standData.BaseValue = powerModule.Defs.BaseSacrificeValue

        -- add the actual name to the standData
        standData.Name = powerModule.Defs.PowerName

        -- connect the button click
        list_Item.Activated:Connect(function()
            StoragePanel.Show_StandCard(standData, buttonType)
        end)

    end
end

--// Update_StandPanel ------------------------------------------------------------
function StoragePanel.Update(currentStand, storageData)

    StoragePanel.StandCard.Visible = false
    StoragePanel.DefaultCard.Visible = true

    -- update the max slots and used slots
    local counter = 0 
    if storageData.storageData ~= nil then
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
    newIcon = standData.Icon:Clone()
    newIcon.BorderSizePixel = 4
    newIcon.Parent = StoragePanel.StandIconFrame
    newIcon.Visible = true
    newIcon.Name = "TempIcon"

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
    local level, remainingPercent = powerUtils.GetLevelFromXp(standData.Xp)
    StoragePanel.Level.Text = tostring(level)
    local width = remainingPercent / 100
    StoragePanel.XpBar.Size = UDim2.new(width, StoragePanel.XpBar.Size.X.Offset, StoragePanel.XpBar.Size.Y.Scale, StoragePanel.XpBar.Size.Y.Offset)

    -- set base value
    StoragePanel.BaseValue.Text = standData.BaseValue

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

--// Request_EquipStand ------------------------------------------------------------
function StoragePanel.Request_EquipStand()

end

--// Request_EvolveStand ------------------------------------------------------------
function StoragePanel.Request_EvolveStand()

end

--// Request_SellStand ------------------------------------------------------------
function StoragePanel.Request_SellStand()

end


return StoragePanel