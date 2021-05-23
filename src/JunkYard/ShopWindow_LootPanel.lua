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
local GamePassService = Knit.GetService("GamePassService")

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui_OLD", 120)

local ShopWindow_LootPanel = {}

ShopWindow_LootPanel.Frame = mainGui.Windows:FindFirstChild("ShopWindow_LootPanel", true)

-- buttons
ShopWindow_LootPanel.Button_Cash1 = ShopWindow_LootPanel.Frame:FindFirstChild("Button_Cash1", true)
ShopWindow_LootPanel.Button_Cash2 = ShopWindow_LootPanel.Frame:FindFirstChild("Button_Cash2", true)
ShopWindow_LootPanel.Button_Cash3 = ShopWindow_LootPanel.Frame:FindFirstChild("Button_Cash3", true)
ShopWindow_LootPanel.Button_Cash4 = ShopWindow_LootPanel.Frame:FindFirstChild("Button_Cash4", true)

ShopWindow_LootPanel.Button_Orbs1 = ShopWindow_LootPanel.Frame:FindFirstChild("Button_Orbs1", true)
ShopWindow_LootPanel.Button_Orbs2 = ShopWindow_LootPanel.Frame:FindFirstChild("Button_Orbs2", true)
ShopWindow_LootPanel.Button_Orbs3 = ShopWindow_LootPanel.Frame:FindFirstChild("Button_Orbs3", true)
ShopWindow_LootPanel.Button_Orbs4 = ShopWindow_LootPanel.Frame:FindFirstChild("Button_Orbs4", true)

--// Setup
function ShopWindow_LootPanel.Setup()

    -- Button_Cash1
    ShopWindow_LootPanel.Button_Cash1.Activated:Connect(function()
        GamePassService:Prompt_ProductPurchase("Cash_A")
    end)

    -- Button_Cash2
    ShopWindow_LootPanel.Button_Cash2.Activated:Connect(function()
        GamePassService:Prompt_ProductPurchase("Cash_B")
    end)

    -- Button_Cash3
    ShopWindow_LootPanel.Button_Cash3.Activated:Connect(function()
        GamePassService:Prompt_ProductPurchase("Cash_C")
    end)

    -- Button_Cash4
    ShopWindow_LootPanel.Button_Cash4.Activated:Connect(function()
        GamePassService:Prompt_ProductPurchase("Cash_D")
    end)

    -- Button_Orbs1
    ShopWindow_LootPanel.Button_Orbs1.Activated:Connect(function()
        GamePassService:Prompt_ProductPurchase("Orbs_A")
    end)

    -- Button_Orbs2
    ShopWindow_LootPanel.Button_Orbs2.Activated:Connect(function()
        GamePassService:Prompt_ProductPurchase("Orbs_B")
    end)

    -- Button_Orbs3
    ShopWindow_LootPanel.Button_Orbs3.Activated:Connect(function()
        GamePassService:Prompt_ProductPurchase("Orbs_C")
    end)

    -- Button_Orbs4
    ShopWindow_LootPanel.Button_Orbs4.Activated:Connect(function()
        GamePassService:Prompt_ProductPurchase("Orbs_D")
    end)

end

return ShopWindow_LootPanel