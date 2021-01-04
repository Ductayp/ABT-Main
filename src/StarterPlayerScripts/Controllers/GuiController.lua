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

-- utility modules
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)

-- gui modules
local SacrificePopUp = require(Knit.GuiModules.SacrificePopUp)
local StoragePanel = require(Knit.GuiModules.StoragePanel)
local ArrowPanel = require(Knit.GuiModules.ArrowPanel)
local StandReveal = require(Knit.GuiModules.StandReveal)
local BottomGui = require(Knit.GuiModules.BottomGui)

-- Gui Defs
local mainGui = PlayerGui:WaitForChild("MainGui", 120)
local defs = {}

-- Constants
local GUI_COLOR = {
    COMMON = Color3.new(239/255, 239/255, 239/255),
    RARE = Color3.new(10/255, 202/255, 0/255),
    LEGENDARY = Color3.new(255/255, 149/255, 43/255)
}

-- variables
local standCardGUID -- this gets set when the stand card shows, it stores the GUID of the shown stand. Its used in buttons

--// ====================================================================================================================================
--//  BOTTOM GUI
--// ====================================================================================================================================


--[[
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
function GuiController:Update_BottomGUI(data)
    defs.Bottom_Gui.Current_Power.Text = data.Power
end

]]--
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
--//  GENERAL UTILITY
--// ====================================================================================================================================

--// Request_GuiUpdate ------------------------------------------------------------
function GuiController:Request_GuiUpdate(requestName)
    GuiService:Request_GuiUpdate(requestName)
end

--// ====================================================================================================================================
--//  KNIT
--// ====================================================================================================================================

--// KnitStart ------------------------------------------------------------
function GuiController:KnitStart()

    -- do some setups OLD
    --self:Setup_PowerButton()
    self:Setup_LeftGui()
    self:Setup_MainWindow()

    -- do some setups NEW NEW NEW
    StoragePanel.Setup()
    ArrowPanel.Setup()
    StandReveal.Setup()
    BottomGui.Setup()
    --SacrificePopUp.Setup()

    -- request Gui Updates
    self:Request_GuiUpdate("ArrowPanel")
    self:Request_GuiUpdate("Cash")
    self:Request_GuiUpdate("StoragePanel")
    self:Request_GuiUpdate("BottomGUI")


    -- connect events
    GuiService.Event_Update_ArrowPanel:Connect(function(data)
        ArrowPanel.Update(data)
    end)

    GuiService.Event_Update_Cash:Connect(function(value)
        self:Update_Cash(value)
    end)

    GuiService.Event_Update_BottomGUI:Connect(function(data)
        BottomGui.Update(data)
    end)

    GuiService.Event_Update_StandReveal:Connect(function(data)
        StandReveal.Update(data)
    end)

    GuiService.Event_Update_StoragePanel:Connect(function(currentStand, storageData)
        StoragePanel.Update(currentStand, storageData)
    end)

end

--// KnitInit ------------------------------------------------------------
function GuiController:KnitInit()

end


return GuiController