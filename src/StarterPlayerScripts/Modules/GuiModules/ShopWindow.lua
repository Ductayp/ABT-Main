--Left Gui
-- PDab
-- 1/4/2021

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local GamePassService = Knit.GetService("GamePassService")
local utils = require(Knit.Shared.Utils)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)

local ShopWindow = {}

ShopWindow.Window = mainGui.Windows:FindFirstChild("ShopWindow", true)
ShopWindow.MainButton_Close = ShopWindow.Window:FindFirstChild("Close_Button", true)

ShopWindow.Button_2XCash = ShopWindow.Window:FindFirstChild("Button_2XCash", true)
ShopWindow.Button_2XSoulOrbs = ShopWindow.Window:FindFirstChild("Button_2XSoulOrbs", true)
ShopWindow.Button_2XArrowLuck = ShopWindow.Window:FindFirstChild("Button_2XArrowLuck", true)
ShopWindow.Button_MobileStorage = ShopWindow.Window:FindFirstChild("Button_MobileStorage", true)
ShopWindow.Button_ItemFinder = ShopWindow.Window:FindFirstChild("Button_ItemFinder", true)
ShopWindow.Button_2XExperience = ShopWindow.Window:FindFirstChild("Button_2XExperience", true)

--// Setup
function ShopWindow.Setup()

    -- be sure this shop window is not visible
    ShopWindow.Close()

    -- MainButton_Close
    ShopWindow.MainButton_Close.Activated:Connect(function()
        ShopWindow.Close()
    end)

    -- Button_2XCash
    ShopWindow.Button_2XCash.Activated:Connect(function()
        GamePassService:Prompt_GamePassPurchase("DoubleCash")
    end)

    -- Button_2XSoulOrbs
    ShopWindow.Button_2XSoulOrbs.Activated:Connect(function()
        GamePassService:Prompt_GamePassPurchase("DoubleOrbs")
    end)

    -- Button_2XArrowLuck
    ShopWindow.Button_2XArrowLuck.Activated:Connect(function()
        GamePassService:Prompt_GamePassPurchase("ArrowLuck")
    end)

    -- Button_MobileStorage
    ShopWindow.Button_MobileStorage.Activated:Connect(function()
        GamePassService:Prompt_GamePassPurchase("MobileStandStorage")
    end)

    -- Button_ItemFinder
    ShopWindow.Button_ItemFinder.Activated:Connect(function()
        GamePassService:Prompt_GamePassPurchase("ItemFinder")
    end)

    -- Button_2XExperience
    ShopWindow.Button_2XExperience.Activated:Connect(function()
        GamePassService:Prompt_GamePassPurchase("DoubleExperience")
    end)

end

function ShopWindow.Open()
    ShopWindow.Window.Visible = true
end

function ShopWindow.Close()
    ShopWindow.Window.Visible = false
    Knit.Controllers.GuiController.CurrentWindow = nil
end


return ShopWindow