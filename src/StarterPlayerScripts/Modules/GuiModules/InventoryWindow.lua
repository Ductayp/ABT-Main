--Inventory Window
-- PDab
-- 1/4/2021

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)

-- gui defs
local InventoryWindow = {}
InventoryWindow.Window = mainGui.Windows:FindFirstChild("MainWindow", true)
InventoryWindow.Item_Button = InventoryWindow.Window:FindFirstChild("Item_Button", true)
InventoryWindow.Storage_Button = InventoryWindow.Window:FindFirstChild("Storage_Button", true)
InventoryWindow.Boost_Button = InventoryWindow.Window:FindFirstChild("Boost_Button", true)
InventoryWindow.Close_Button = InventoryWindow.Window:FindFirstChild("CloseButton", true)
InventoryWindow.Item_Panel = InventoryWindow.Window:FindFirstChild("Item_Panel", true)
InventoryWindow.Boost_Panel = InventoryWindow.Window:FindFirstChild("Boost_Panel", true)
InventoryWindow.Storage_Panel = InventoryWindow.Window:FindFirstChild("Storage_Panel", true)

local allPanels = {InventoryWindow.Item_Panel,InventoryWindow.Boost_Panel,InventoryWindow.Storage_Panel}

-- constants
local DEFAULT_PANEL = InventoryWindow.Item_Panel

--// Setup ------------------------------------------------------------
function InventoryWindow.Setup()

    -- just be sure main window is off
    InventoryWindow.Window.Visible = false

    -- connect buttons
    InventoryWindow.Close_Button.Activated:Connect(function()
        InventoryWindow.Close()
    end)

    InventoryWindow.Item_Button.Activated:Connect(function()
        InventoryWindow.ActivatePanel(InventoryWindow.Item_Panel)
    end)

    InventoryWindow.Storage_Button.Activated:Connect(function()
        InventoryWindow.ActivatePanel(InventoryWindow.Storage_Panel)
    end)

    InventoryWindow.Boost_Button.Activated:Connect(function()
        InventoryWindow.ActivatePanel(InventoryWindow.Boost_Panel)
    end)

end

--// Activate ------------------------------------------------------------
function InventoryWindow.Open()

    -- make sure all panels are off
    for _,panel in pairs(allPanels) do
        panel.Visible = false
    end

    -- set the default panel to true
    DEFAULT_PANEL.Visible = true

    -- show it
    InventoryWindow.Window.Visible = true
end

--// ActivatePanel
function InventoryWindow.ActivatePanel(panelDef)

    -- make sure all panels are off
    for _,panel in pairs(allPanels) do
    panel.Visible = false
    end

    -- make it visible
    panelDef.Visible = true

end

--// Close
function InventoryWindow.Close()
    InventoryWindow.Window.Visible = false
end




return InventoryWindow