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
local powerUtils = require(Knit.Shared.PowerUtils)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)

local LeftGui = {}


LeftGui.Cash_Value = mainGui.LeftGui:FindFirstChild("Cash_Value", true)
LeftGui.Inventory_Button = mainGui.LeftGui:FindFirstChild("Inventory_Button", true)
LeftGui.Codes_Button = mainGui.LeftGui:FindFirstChild("Codes_Button", true)
LeftGui.Shop_Button = mainGui.LeftGui:FindFirstChild("Shop_Button", true)


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
    for i = 1,3 do
        LeftGui.Cash_Value.Text = math.random(1,99999)
        wait(.1)
    end
    if value ~= nil then
        LeftGui.Cash_Value.Text = value
    end
end


return LeftGui