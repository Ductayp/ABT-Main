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
ShopWindow.MainButton_Arrows = ShopWindow.Window:FindFirstChild("MainButton_Arrows", true)
ShopWindow.MainButton_Passes = ShopWindow.Window:FindFirstChild("MainButton_Passes", true)
ShopWindow.MainButton_Boosts = ShopWindow.Window:FindFirstChild("MainButton_Boosts", true)
ShopWindow.MainButton_Close = ShopWindow.Window:FindFirstChild("MainButton_Close", true)

-- panels
ShopWindow.LootPanel = ShopWindow.Window:FindFirstChild("ShopWindow_LootPanel", true)
ShopWindow.ArrowsPanel = ShopWindow.Window:FindFirstChild("ShopWindow_ArrowPanel", true)
ShopWindow.PassesPanel = ShopWindow.Window:FindFirstChild("ShopWindow_PassesPanel", true)
ShopWindow.BoostsPanel = ShopWindow.Window:FindFirstChild("ShopWindow_BoostsPanel", true)

ShopWindow.All_Panels = {ShopWindow.LootPanel, ShopWindow.ArrowsPanel, ShopWindow.PassesPanel, ShopWindow.BoostsPanel}

local DEFAULT_PANEL = ShopWindow.LootPanel

--// Setup
function ShopWindow.Setup()

    -- be sure this shop window is not visible
    ShopWindow.Close()

    -- MainButton_Loot
    ShopWindow.MainButton_Loot.Activated:Connect(function()
        ShopWindow.CloseAllPanels()
        ShopWindow.LooPanel.Visible = true
    end)

    -- MainButton_Arrows
    ShopWindow.MainButton_Arrows.Activated:Connect(function()
        ShopWindow.CloseAllPanels()
        ShopWindow.ArrowsPanel.Visible = true
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
end


return ShopWindow