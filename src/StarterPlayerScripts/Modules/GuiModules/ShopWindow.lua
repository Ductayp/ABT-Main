--Left Gui
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

local ShopWindow = {}

ShopWindow.Window = mainGui.Windows:FindFirstChild("ShopWindow", true)

-- main buttons
ShopWindow.MainButton_Loot = ShopWindow.Window:FindFirstChild("MainButton_Loot", true)
ShopWindow.MainButton_Storage = ShopWindow.Window:FindFirstChild("MainButton_Storage", true)
ShopWindow.MainButton_Passes = ShopWindow.Window:FindFirstChild("MainButton_Passes", true)
ShopWindow.MainButton_Boosts = ShopWindow.Window:FindFirstChild("MainButton_Boosts", true)
ShopWindow.MainButton_Close = ShopWindow.Window:FindFirstChild("Close_Button", true)

-- panels
ShopWindow.LootPanel = ShopWindow.Window:FindFirstChild("ShopWindow_LootPanel", true)
ShopWindow.StoragePanel = ShopWindow.Window:FindFirstChild("ShopWindow_StoragePanel", true)
ShopWindow.PassesPanel = ShopWindow.Window:FindFirstChild("ShopWindow_PassesPanel", true)
ShopWindow.BoostsPanel = ShopWindow.Window:FindFirstChild("ShopWindow_BoostsPanel", true)

-- update values
ShopWindow.Current_Cash = ShopWindow.Window:FindFirstChild("Current_Cash", true)
ShopWindow.Current_SoulOrbs = ShopWindow.Window:FindFirstChild("Current_SoulOrbs", true)

ShopWindow.All_Panels = {ShopWindow.LootPanel, ShopWindow.StoragePanel, ShopWindow.PassesPanel, ShopWindow.BoostsPanel}

local DEFAULT_PANEL = ShopWindow.LootPanel

--// Update_Currency
function ShopWindow.Update_Currency(data)

    ShopWindow.Current_Cash.Text = data.Cash
    ShopWindow.Current_SoulOrbs.Text = data.SoulOrbs
end

--// Setup
function ShopWindow.Setup()

    -- be sure this shop window is not visible
    ShopWindow.Close()

    -- MainButton_Loot
    ShopWindow.MainButton_Loot.Activated:Connect(function()
        ShopWindow.CloseAllPanels()
        ShopWindow.LootPanel.Visible = true
    end)

    -- MainButton_Arrows
    ShopWindow.MainButton_Storage.Activated:Connect(function()
        ShopWindow.CloseAllPanels()
        ShopWindow.StoragePanel.Visible = true
    end)

    -- MainButton_Passes
    ShopWindow.MainButton_Passes.Activated:Connect(function()
        ShopWindow.CloseAllPanels()
        ShopWindow.PassesPanel.Visible = true
    end)

    -- MainButton_Boosts
    ShopWindow.MainButton_Boosts.Activated:Connect(function()
        ShopWindow.CloseAllPanels()
        ShopWindow.BoostsPanel.Visible = true
    end)

    -- MainButton_Close
    ShopWindow.MainButton_Close.Activated:Connect(function()
        ShopWindow.Close()
    end)

end

function ShopWindow.CloseAllPanels()
    for _i,panel in pairs(ShopWindow.All_Panels) do
        panel.Visible = false
    end
end

function ShopWindow.Open()
    ShopWindow.CloseAllPanels()
    DEFAULT_PANEL.Visible = true
    ShopWindow.Window.Visible = true
end

function ShopWindow.Close()
    ShopWindow.Window.Visible = false
    Knit.Controllers.GuiController.CurrentWindow = nil
end


return ShopWindow