-- GUI controller
-- PDab
-- 12 / 15/ 2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local PlayerGui = Players.LocalPlayer.PlayerGui


-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local GuiController = Knit.CreateController { Name = "GuiController" }
local GuiService = Knit.GetService("GuiService")
local InventoryService = Knit.GetService("InventoryService")

-- Knit modules
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)

-- Gui Defs
local mainGui = PlayerGui.MainGui
local defs = {}

-- Window Defs
defs.Windows = {}
defs.Windows.MainWindow = {
    Window = mainGui.Windows:FindFirstChild("MainWindow", true),
    Buttons = {
        Item_Button = mainGui.Windows.MainWindow:FindFirstChild("Item_Button", true),
        Storage_Button = mainGui.Windows.MainWindow:FindFirstChild("Storage_Button", true),
        Arrow_Button = mainGui.Windows.MainWindow:FindFirstChild("Arrow_Button", true),
        Shop_Button = mainGui.Windows.MainWindow:FindFirstChild("Shop_Button", true),
        Code_Button = mainGui.Windows.MainWindow:FindFirstChild("Code_Button", true),
        Setting_Button = mainGui.Windows.MainWindow:FindFirstChild("Setting_Button", true),
        Close_Button = mainGui.Windows.MainWindow:FindFirstChild("CloseButton", true)
    },
    Panels = {
        Arrow_Panel = mainGui.Windows.MainWindow:FindFirstChild("Arrow_Panel", true),
        Code_Panel = mainGui.Windows.MainWindow:FindFirstChild("Code_Panel", true),
        Item_Panel = mainGui.Windows.MainWindow:FindFirstChild("Item_Panel", true),
        Shop_Panel = mainGui.Windows.MainWindow:FindFirstChild("Shop_Panel", true),
        Storage_Panel = mainGui.Windows.MainWindow:FindFirstChild("Storage_Panel", true),
        Setting_Panel = mainGui.Windows.MainWindow:FindFirstChild("Setting_Panel", true)
    }
}

defs.LeftGui = {
    Cash_Value = mainGui.LeftGui:FindFirstChild("Cash_Value", true),
    Buttons = {
        MainMenu_Button = mainGui.LeftGui:FindFirstChild("MainMenu_Button", true),
        Arrow_Button = mainGui.LeftGui:FindFirstChild("Arrow_Button", true),
        Storage_Button = mainGui.LeftGui:FindFirstChild("Storage_Button", true),
    },
}

defs.ArrowPanel = {
    Scrolling_Frame = defs.Windows.MainWindow.Panels.Arrow_Panel:FindFirstChild("ScrollingFrame", true),
    Item_Template = defs.Windows.MainWindow.Panels.Arrow_Panel:FindFirstChild("ItemTemplate", true),
    UseArrowFrame = defs.Windows.MainWindow.Panels.Arrow_Panel:FindFirstChild("UserArrowPanels"),
    UseArrowPanels = {
        UniversalArrow_Common = defs.Windows.MainWindow.Panels.Arrow_Panel:FindFirstChild("UniversalArrow_Common", true),
        UniversalArrow_Rare = defs.Windows.MainWindow.Panels.Arrow_Panel:FindFirstChild("UniversalArrow_Rare", true),
        UniversalArrow_Legendary = defs.Windows.MainWindow.Panels.Arrow_Panel:FindFirstChild("UniversalArrow_Legendary", true),
    },
    UseArrowButtons = {
        UniversalArrow_Common = defs.Windows.MainWindow.Panels.Arrow_Panel:FindFirstChild("UseArrow_Universal_Common", true),
        UniversalArrow_Rare = defs.Windows.MainWindow.Panels.Arrow_Panel:FindFirstChild("UseArrow_Universal_Rare", true),
        UniversalArrow_Legendary = defs.Windows.MainWindow.Panels.Arrow_Panel:FindFirstChild("UseArrow_Universal_Legendary", true),
    }
}


--// ActivateWindow
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


--// Setup_PowerButton
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

--// Setup_LeftGui()
function GuiController:Setup_LeftGui()

    -- connect the clickies
    defs.LeftGui.Buttons.MainMenu_Button.Activated:Connect(function()
        self:ActivateWindow(defs.Windows.MainWindow,defs.Windows.MainWindow.Panels.Item_Panel)
    end)

    defs.LeftGui.Buttons.Arrow_Button.Activated:Connect(function()
        self:ActivateWindow(defs.Windows.MainWindow,defs.Windows.MainWindow.Panels.Arrow_Panel)
    end)

    defs.LeftGui.Buttons.Storage_Button.Activated:Connect(function()
        self:ActivateWindow(defs.Windows.MainWindow,defs.Windows.MainWindow.Panels.Storage_Panel)
    end)
end

--// Setup_MainWindow
function GuiController:Setup_MainWindow()

    -- just be sure main window is off
    defs.Windows.MainWindow.Window.Visible = false

    -- connect buttons
    defs.Windows.MainWindow.Buttons.Close_Button.Activated:Connect(function()
        defs.Windows.MainWindow.Window.Visible = false
    end)

    defs.Windows.MainWindow.Buttons.Item_Button.Activated:Connect(function()
        self:ActivatePanel(defs.Windows.MainWindow,defs.Windows.MainWindow.Panels.Item_Panel)
    end)

    defs.Windows.MainWindow.Buttons.Arrow_Button.Activated:Connect(function()
        self:ActivatePanel(defs.Windows.MainWindow,defs.Windows.MainWindow.Panels.Arrow_Panel)
    end)

    defs.Windows.MainWindow.Buttons.Storage_Button.Activated:Connect(function()
        self:ActivatePanel(defs.Windows.MainWindow,defs.Windows.MainWindow.Panels.Storage_Panel)
    end)

    defs.Windows.MainWindow.Buttons.Shop_Button.Activated:Connect(function()
        self:ActivatePanel(defs.Windows.MainWindow,defs.Windows.MainWindow.Panels.Shop_Panel)
    end)

    defs.Windows.MainWindow.Buttons.Code_Button.Activated:Connect(function()
        self:ActivatePanel(defs.Windows.MainWindow,defs.Windows.MainWindow.Panels.Code_Panel)
    end)

    defs.Windows.MainWindow.Buttons.Setting_Button.Activated:Connect(function()
        self:ActivatePanel(defs.Windows.MainWindow,defs.Windows.MainWindow.Panels.Setting_Panel)
    end)

end

function GuiController:Update_Cash(value)
    defs.LeftGui.Cash_Value.Text = value
end

--// Update_ArrowPanel
function GuiController:Update_ArrowPanel(data)

    print("GuiController:Update_ArrowPanel - RECEIVED EVENT")

    -- destroy all arrows int he scrolling frame
    for _,object in pairs(defs.ArrowPanel.Scrolling_Frame:GetChildren()) do
        if object.Name == "arrowItem" then
            object:Destroy()
        end
    end

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
            print("beep beep")
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


--// Setup_ArrowPanel
function GuiController:Setup_ArrowPanel()
    defs.ArrowPanel.Item_Template.Visible = false

    -- connect Use Arrow buttons
    defs.ArrowPanel.UseArrowButtons.UniversalArrow_Common.Activated:Connect(function()
        params = {}
        params.Type = "UniversalArrow"
        params.Rarity = "Common"
        InventoryService:UseArrow(params)
    end)
    defs.ArrowPanel.UseArrowButtons.UniversalArrow_Rare.Activated:Connect(function()
        params = {}
        params.Type = "UniversalArrow"
        params.Rarity = "Rare"
        InventoryService:UseArrow(params)
    end)
    defs.ArrowPanel.UseArrowButtons.UniversalArrow_Legendary.Activated:Connect(function()
        params = {}
        params.Type = "UniversalArrow"
        params.Rarity = "Legendary"
        InventoryService:UseArrow(params)
    end)
end

--/ Request_GuiUpdate
function GuiController:Request_GuiUpdate(requestName)
    GuiService:Request_GuiUpdate(requestName)
end


function GuiController:KnitStart()

    -- do some setups
    self:Setup_PowerButton()
    self:Setup_LeftGui()
    self:Setup_MainWindow()
    self:Setup_ArrowPanel()

    -- request Gui Updates
    self:Request_GuiUpdate("ArrowPanel")
    self:Request_GuiUpdate("Cash")


    -- connect events
    GuiService.Event_Update_ArrowPanel:Connect(function(data)
        self:Update_ArrowPanel(data)
    end)

    GuiService.Event_Update_Cash:Connect(function(value)
        self:Update_Cash(value)
    end)

end

function GuiController:KnitInit()


end


return GuiController