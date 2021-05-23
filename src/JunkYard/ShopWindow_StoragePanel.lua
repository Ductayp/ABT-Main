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
local InventoryService = Knit.GetService("InventoryService")
local ShopWindow = require(Knit.GuiModules.ShopWindow)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui_OLD", 120)

local ShopWindow_StoragePanel = {}

ShopWindow_StoragePanel.PurchaseDefs = {

    Button_StorageBuy_A = {
        Slots = 1,
        Cost = 6000
    },

    Button_StorageBuy_B = {
        Slots = 3,
        Cost = 17000
    },

    Button_StorageBuy_C = {
        Slots = 5,
        Cost = 28000
    },

    Button_StorageBuy_D = {
        Slots = 10,
        Cost = 50000
    },
}

ShopWindow_StoragePanel.PurchaseParams = {} -- this gets set when a player clicks a button, confirming sends this table to InventoryService

-- the main panel
ShopWindow_StoragePanel.Frame = mainGui.Windows:FindFirstChild("ShopWindow_StoragePanel", true)
ShopWindow_StoragePanel.Button_StorageBuy_A = ShopWindow_StoragePanel.Frame:FindFirstChild("Button_StorageBuy_A", true)
ShopWindow_StoragePanel.Button_StorageBuy_B = ShopWindow_StoragePanel.Frame:FindFirstChild("Button_StorageBuy_B", true)
ShopWindow_StoragePanel.Button_StorageBuy_C = ShopWindow_StoragePanel.Frame:FindFirstChild("Button_StorageBuy_C", true)
ShopWindow_StoragePanel.Button_StorageBuy_D = ShopWindow_StoragePanel.Frame:FindFirstChild("Button_StorageBuy_D", true)

-- confimration panel
ShopWindow_StoragePanel.Confirm_Frame = mainGui.Windows:FindFirstChild("StoragePurchase_Confirm", true)
ShopWindow_StoragePanel.Number_Slots = ShopWindow_StoragePanel.Confirm_Frame:FindFirstChild("Number_Slots", true)
ShopWindow_StoragePanel.This_Cost = ShopWindow_StoragePanel.Confirm_Frame:FindFirstChild("This_Cost", true)
ShopWindow_StoragePanel.Button_Confirm_Yes = ShopWindow_StoragePanel.Confirm_Frame:FindFirstChild("Button_Confirm_Yes", true)
ShopWindow_StoragePanel.Button_Confirm_No = ShopWindow_StoragePanel.Confirm_Frame:FindFirstChild("Button_Confirm_No", true)


--// Setup
function ShopWindow_StoragePanel.Setup()

    -- visibility stuff
    ShopWindow_StoragePanel.Frame.Visible = false
    ShopWindow_StoragePanel.Confirm_Frame.Visible = false

    -- Button_StorageBuy_A
    ShopWindow_StoragePanel.Button_StorageBuy_A.Activated:Connect(function()

        -- set the params and confimration widnow
        ShopWindow_StoragePanel.PurchaseParams = ShopWindow_StoragePanel.PurchaseDefs.Button_StorageBuy_A

        -- check if the player has enough cash
        local currencyData = InventoryService:GetCurrencyData()

        if currencyData ~= nil then
            if currencyData.Cash >= ShopWindow_StoragePanel.PurchaseParams.Cost then

                ShopWindow_StoragePanel.UpdateConfirmPanel(ShopWindow_StoragePanel.PurchaseParams)
                ShopWindow.Window.Visible = false
                ShopWindow_StoragePanel.Confirm_Frame.Visible = true

            else
                ShopWindow_StoragePanel.CantAfford(ShopWindow_StoragePanel.Button_StorageBuy_A)
            end
        end 

    end)

    -- Button_StorageBuy_B
    ShopWindow_StoragePanel.Button_StorageBuy_B.Activated:Connect(function()

        -- set the params and confimration widnow
        ShopWindow_StoragePanel.PurchaseParams = ShopWindow_StoragePanel.PurchaseDefs.Button_StorageBuy_B

        -- check if the player has enough cash
        local currencyData = InventoryService:GetCurrencyData()

        if currencyData ~= nil then
            if currencyData.Cash >= ShopWindow_StoragePanel.PurchaseParams.Cost then

                ShopWindow_StoragePanel.UpdateConfirmPanel(ShopWindow_StoragePanel.PurchaseParams)
                ShopWindow.Window.Visible = false
                ShopWindow_StoragePanel.Confirm_Frame.Visible = true

            else
                ShopWindow_StoragePanel.CantAfford(ShopWindow_StoragePanel.Button_StorageBuy_B)
            end
        end 

    end)

    -- Button_StorageBuy_C
    ShopWindow_StoragePanel.Button_StorageBuy_C.Activated:Connect(function()

        -- set the params and confimration widnow
        ShopWindow_StoragePanel.PurchaseParams = ShopWindow_StoragePanel.PurchaseDefs.Button_StorageBuy_C

        -- check if the player has enough cash
        local currencyData = InventoryService:GetCurrencyData()

        if currencyData ~= nil then
            if currencyData.Cash >= ShopWindow_StoragePanel.PurchaseParams.Cost then

                ShopWindow_StoragePanel.UpdateConfirmPanel(ShopWindow_StoragePanel.PurchaseParams)
                ShopWindow.Window.Visible = false
                ShopWindow_StoragePanel.Confirm_Frame.Visible = true

            else
                ShopWindow_StoragePanel.CantAfford(ShopWindow_StoragePanel.Button_StorageBuy_C)
            end
        end 
    end)

    -- Button_StorageBuy_D
    ShopWindow_StoragePanel.Button_StorageBuy_D.Activated:Connect(function()

        -- set the params and confimration widnow
        ShopWindow_StoragePanel.PurchaseParams = ShopWindow_StoragePanel.PurchaseDefs.Button_StorageBuy_D

        -- check if the player has enough cash
        local currencyData = InventoryService:GetCurrencyData()

        if currencyData ~= nil then
            if currencyData.Cash >= ShopWindow_StoragePanel.PurchaseParams.Cost then

                ShopWindow_StoragePanel.UpdateConfirmPanel(ShopWindow_StoragePanel.PurchaseParams)
                ShopWindow.Window.Visible = false
                ShopWindow_StoragePanel.Confirm_Frame.Visible = true

            else
                ShopWindow_StoragePanel.CantAfford(ShopWindow_StoragePanel.Button_StorageBuy_D)
            end
        end 
    end)

    -- Button_Confirm_Yes
    ShopWindow_StoragePanel.Button_Confirm_Yes.Activated:Connect(function()

        -- send the purchase to InventoryService
        InventoryService:BuyStorage(ShopWindow_StoragePanel.PurchaseParams)

        ShopWindow_StoragePanel.Confirm_Frame.Visible = false
        ShopWindow.Window.Visible = true
    end)

    -- Button_Confirm_No
    ShopWindow_StoragePanel.Button_Confirm_No.Activated:Connect(function()

        -- cancel it bro
        print("cancel it bro")
        ShopWindow_StoragePanel.Confirm_Frame.Visible = false
        ShopWindow.Window.Visible = true

    end)

end

--// UpdateConfirmPanel
function ShopWindow_StoragePanel.UpdateConfirmPanel(defs)

    ShopWindow_StoragePanel.Number_Slots.Text = defs.Slots
    ShopWindow_StoragePanel.This_Cost.Text = defs.Cost

end

--// CantAfford
function ShopWindow_StoragePanel.CantAfford(button)

    -- define the things we will work with
    local costText = button:FindFirstChild("CostText", true)
    local costIcon = button:FindFirstChild("CostIcon", true)
    local costFrame = button:FindFirstChild("Cost_Frame", true)

    local originalTextColor = costText.TextColor3
    local originalTextText = costText.Text
    local originalIconColor = costIcon.ImageColor3
    local originalIconSize = costIcon.Size
    local oringinalCostFrameSize = costFrame.Size

    spawn(function()
        costText.TextColor3 = Color3.new(255/255, 59/255, 0/255)
        costText.Text = "CANT AFFORD"
        costIcon.ImageColor3 = Color3.new(255/255, 59/255, 0/255)
        costFrame.Size = costFrame.Size + UDim2.new(.2,.2,.2,.2)

        wait(2)

        costText.TextColor3 = originalTextColor
        costText.Text = originalTextText
        costIcon.ImageColor3 = originalIconColor
        costFrame.Size = oringinalCostFrameSize

    end)

end

return ShopWindow_StoragePanel