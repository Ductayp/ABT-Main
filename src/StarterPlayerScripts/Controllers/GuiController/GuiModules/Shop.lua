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

local Shop = {}

Shop.Frame = mainGui.Windows:FindFirstChild("Shop", true)
Shop.Button_Close = Shop.Frame:FindFirstChild("Button_Close", true)

Shop.Button_2XCash = Shop.Frame:FindFirstChild("Button_2XCash", true)
Shop.Button_2XSoulOrbs = Shop.Frame:FindFirstChild("Button_2XSoulOrbs", true)
Shop.Button_2XArrowLuck = Shop.Frame:FindFirstChild("Button_2XArrowLuck", true)
Shop.Button_MobileStorage = Shop.Frame:FindFirstChild("Button_MobileStorage", true)
Shop.Button_ItemFinder = Shop.Frame:FindFirstChild("Button_ItemFinder", true)
Shop.Button_2XExperience = Shop.Frame:FindFirstChild("Button_2XExperience", true)

--// Setup
function Shop.Setup()

    Shop.Close()

    -- Button_Close
    Shop.Button_Close.MouseButton1Down:Connect(function()
        Shop.Close()
    end)

    -- Button_2XCash
    Shop.Button_2XCash.MouseButton1Down:Connect(function()
        GamePassService:Prompt_GamePassPurchase("DoubleCash")
    end)

    -- Button_2XSoulOrbs
    Shop.Button_2XSoulOrbs.MouseButton1Down:Connect(function()
        GamePassService:Prompt_GamePassPurchase("DoubleOrbs")
    end)

    -- Button_2XArrowLuck
    Shop.Button_2XArrowLuck.MouseButton1Down:Connect(function()
        GamePassService:Prompt_GamePassPurchase("ArrowLuck")
    end)

    -- Button_MobileStorage
    Shop.Button_MobileStorage.MouseButton1Down:Connect(function()
        GamePassService:Prompt_GamePassPurchase("MobileStandStorage")
    end)

    -- Button_ItemFinder
    Shop.Button_ItemFinder.MouseButton1Down:Connect(function()
        GamePassService:Prompt_GamePassPurchase("ItemFinder")
    end)

    -- Button_2XExperience
    Shop.Button_2XExperience.MouseButton1Down:Connect(function()
        GamePassService:Prompt_GamePassPurchase("DoubleExperience")
    end)

end

function Shop.Open()
    Knit.Controllers.GuiController:CloseAllWindows()
    Knit.Controllers.GuiController.CurrentWindow = "Storage"
    Shop.Frame.Visible = true
end

function Shop.Close()
    Knit.Controllers.GuiController:CloseAllWindows()
    Knit.Controllers.GuiController.CurrentWindow = nil
    Shop.Frame.Visible = false
end


return Shop