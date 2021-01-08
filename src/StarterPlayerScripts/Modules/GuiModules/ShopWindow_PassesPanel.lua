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
local ShopWindow = require(Knit.GuiModules.ShopWindow)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)

local ShopWindow_PassesPanel = {}

-- the main panel
ShopWindow_PassesPanel.Frame = mainGui.Windows:FindFirstChild("ShopWindow_PassesPanel", true)
ShopWindow_PassesPanel.Button_2XCash = ShopWindow_PassesPanel.Frame:FindFirstChild("Button_2XCash", true)
ShopWindow_PassesPanel.Button_2XSoulOrbs = ShopWindow_PassesPanel.Frame:FindFirstChild("Button_2XSoulOrbs", true)
ShopWindow_PassesPanel.Button_2XArrowLuck = ShopWindow_PassesPanel.Frame:FindFirstChild("Button_2XArrowLuck", true)
ShopWindow_PassesPanel.Button_MobileStorage = ShopWindow_PassesPanel.Frame:FindFirstChild("Button_MobileStorage", true)
ShopWindow_PassesPanel.Button_ItemFinder = ShopWindow_PassesPanel.Frame:FindFirstChild("Button_ItemFinder", true)
ShopWindow_PassesPanel.Button_2XExperience = ShopWindow_PassesPanel.Frame:FindFirstChild("Button_2XExperience", true)


--// Setup
function ShopWindow_PassesPanel.Setup()

    -- setup visibility
    ShopWindow_PassesPanel.Frame.Visible = false

    -- Button_2XCash
    ShopWindow_PassesPanel.Button_2XCash.Activated:Connect(function()
        GamePassService:Prompt_GamePassPurchase("DoubleCash")
    end)

    -- Button_2XSoulOrbs
    ShopWindow_PassesPanel.Button_2XSoulOrbs.Activated:Connect(function()
        GamePassService:Prompt_GamePassPurchase("DoubleOrbs")
    end)

    -- Button_2XArrowLuck
    ShopWindow_PassesPanel.Button_2XArrowLuck.Activated:Connect(function()
        GamePassService:Prompt_GamePassPurchase("DoubleArrowLuck")
    end)

    -- Button_MobileStorage
    ShopWindow_PassesPanel.Button_MobileStorage.Activated:Connect(function()
        GamePassService:Prompt_GamePassPurchase("MobileStandStorage")
    end)

    -- Button_ItemFinder
    ShopWindow_PassesPanel.Button_ItemFinder.Activated:Connect(function()
        GamePassService:Prompt_GamePassPurchase("ItemFinder")
    end)

    -- Button_2XExperience
    ShopWindow_PassesPanel.Button_2XExperience.Activated:Connect(function()
        GamePassService:Prompt_GamePassPurchase("DoubleExperience")
    end)

end



return ShopWindow_PassesPanel