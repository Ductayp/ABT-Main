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

-- Left Gui Defs
defs.LeftGui = {
    Buttons = {
        MainMenu_Button = mainGui.LeftGui:FindFirstChild("MainMenu_Button", true),
        Arrow_Button = mainGui.LeftGui:FindFirstChild("Arrow_Button", true),
        Storage_Button = mainGui.LeftGui:FindFirstChild("Storage_Button", true),
    }
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


--// PowerButtonSetup
function GuiController:PowerButtonSetup()

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

--// LeftGuiSetup()
function GuiController:LeftGuiSetup()

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

--// WindowGuiSetup
function GuiController:MainWindowSetup()

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

function GuiController:Update_ArrowPanel()

    local playerDataFolder = ReplicatedStorage.ReplicatedPlayerData[Players.LocalPlayer.UserId]
    local arrowInventory = playerDataFolder.ArrowInventory

    for _,arrowFolder in pairs(arrowInventory:GetChildren()) do

        -- make a new list item
        local newListItem = defs.ArrowPanel.Item_Template:Clone()
        newListItem.Parent = defs.ArrowPanel.Scrolling_Frame
        newListItem.Visible = true
        newListItem.Name = "arrow"

        -- change text
        local textLabel = newListItem:FindFirstChild("Arrow_Name", true)
        textLabel.Text = arrowFolder.ArrowName.Value

        -- set some values based on rarity
        local icon = newListItem:FindFirstChild("Arrow_Icon", true)
        local rarity = arrowFolder.Rarity.Value
        local targetPanel
        if rarity == "Common" then
            targetPanel = defs.ArrowPanel.UseArrowPanels.UniversalArrow_Common
        elseif rarity == "Rare" then
            icon.ImageColor3 = Color3.new(10/255, 202/255, 0/255)
            textLabel.TextColor3 = Color3.new(10/255, 202/255, 0/255)
            targetPanel = defs.ArrowPanel.UseArrowPanels.UniversalArrow_Rare
        elseif rarity == "Legendary" then
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

        -- set the canvas size to the absolute listLayot size
        defs.ArrowPanel.Scrolling_Frame.CanvasSize = UDim2.new(0, 0, 0, defs.ArrowPanel.Scrolling_Frame.UIListLayout.AbsoluteContentSize.Y)

    end
end

function GuiController:Setup_ArrowPanel()

    -- upadte the arrows when we start
    self:Update_ArrowPanel()

    -- update the arrows whenever an arrow is added or removed form the data folder
    local playerDataFolder = ReplicatedStorage.ReplicatedPlayerData[Players.LocalPlayer.UserId]
    local arrowFolder = playerDataFolder.ArrowInventory

    arrowFolder.ChildAdded:Connect(function(child)
        local debounce = false
        if debounce == false then
            debaounce = true
            self:Update_ArrowPanel()
            spawn(function()
                wait(2)
                debounce = false
            end)
        end
    end)

    arrowFolder.ChildRemoved:Connect(function(child)
        spawn(function()
            wait(.5)
            self:Update_ArrowPanel()
        end)
    end)

    -- connect Use Arrow buttons
    defs.ArrowPanel.UseArrowButtons.UniversalArrow_Common.Activated:Connect(function()
        GuiService:UseArrow("UniversalArrow","Common")
    end)
    defs.ArrowPanel.UseArrowButtons.UniversalArrow_Rare.Activated:Connect(function()
        GuiService:UseArrow("UniversalArrow","Rare")
    end)
    defs.ArrowPanel.UseArrowButtons.UniversalArrow_Legendary.Activated:Connect(function()
        GuiService:UseArrow("UniversalArrow","Legendary")
    end)

end


function GuiController:KnitStart()
    self:PowerButtonSetup()
    self:LeftGuiSetup()
    self:MainWindowSetup()
    self:Setup_ArrowPanel()
end

function GuiController:KnitInit()


end


return GuiController