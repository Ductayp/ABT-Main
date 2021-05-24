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
local mainGui = PlayerGui:WaitForChild("MainGui_OLD", 120)

local LeftGui = {}

LeftGui.Inventory_Button = mainGui.LeftGui:FindFirstChild("Inventory_Button", true)
LeftGui.Codes_Button = mainGui.LeftGui:FindFirstChild("Codes_Button", true)
LeftGui.Shop_Button = mainGui.LeftGui:FindFirstChild("Shop_Button", true)


--// Setup_LeftGui() ------------------------------------------------------------
function LeftGui.Setup()

    -- connect the clickies
    LeftGui.Inventory_Button.MouseButton1Down:Connect(function()
        if not Knit.Controllers.GuiController.InDialogue then
            if Knit.Controllers.GuiController.CurrentWindow == "Inventory" then
                Knit.Controllers.GuiController.InventoryWindow.Close()
                Knit.Controllers.GuiController.CurrentWindow = nil
            else
                Knit.Controllers.GuiController:CloseAllWindows()
                Knit.Controllers.GuiController.InventoryWindow.Open()
                Knit.Controllers.GuiController.CurrentWindow = "Inventory"
            end
        end
    end)

    LeftGui.Codes_Button.MouseButton1Down:Connect(function()
        if not Knit.Controllers.GuiController.InDialogue then
            if Knit.Controllers.GuiController.CurrentWindow == "Codes" then
                Knit.Controllers.GuiController.CodesWindow.Close()
                Knit.Controllers.GuiController.CurrentWindow = nil
            else
                Knit.Controllers.GuiController:CloseAllWindows()
                Knit.Controllers.GuiController.CodesWindow.Open()
                Knit.Controllers.GuiController.CurrentWindow = "Codes"
            end
        end
    end)

    LeftGui.Shop_Button.MouseButton1Down:Connect(function()
        if not Knit.Controllers.GuiController.InDialogue then
            if Knit.Controllers.GuiController.CurrentWindow == "Shop" then
                Knit.Controllers.GuiController.ShopWindow.Close()
                Knit.Controllers.GuiController.CurrentWindow = nil
            else
                Knit.Controllers.GuiController:CloseAllWindows()
                Knit.Controllers.GuiController.ShopWindow.Open()
                Knit.Controllers.GuiController.CurrentWindow = "Shop"
            end
        end
    end)
end


return LeftGui