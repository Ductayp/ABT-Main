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

local LeftGui = {}


LeftGui.Cash_Value = mainGui.LeftGui:FindFirstChild("Cash_Value", true)
LeftGui.Inventory_Button = mainGui.LeftGui:FindFirstChild("A_Inventory_Button", true)
LeftGui.Codes_Button = mainGui.LeftGui:FindFirstChild("D_Codes_Button", true)
LeftGui.Shop_Button = mainGui.LeftGui:FindFirstChild("B_Shop_Button", true)
LeftGui.Settings_Button = mainGui.LeftGui:FindFirstChild("C_Shop_Button", true)


--// Setup_LeftGui() ------------------------------------------------------------
function LeftGui.Setup()

    -- connect the clickies
    LeftGui.Inventory_Button.Activated:Connect(function()
        Knit.Controllers.GuiController:CloseAllWindows()
        Knit.Controllers.GuiController.InventoryWindow.Open()
    end)

    LeftGui.Codes_Button.Activated:Connect(function()
        Knit.Controllers.GuiController:CloseAllWindows()
        
    end)

    LeftGui.Shop_Button.Activated:Connect(function()
        Knit.Controllers.GuiController:CloseAllWindows()
        Knit.Controllers.GuiController.ShopWindow.Open()
    end)
end

--// UpdateCash ------------------------------------------------------------
function LeftGui.Update_Cash(value)

    if value ~= nil then
        LeftGui.Cash_Value.Text = value
    end
end


return LeftGui