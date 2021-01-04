-- Arrow Panel
-- PDab
-- 1/2/2021

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local InventoryService = Knit.GetService("InventoryService")
local PowersService = Knit.GetService("PowersService")

-- utils
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)

-- Constants
local GUI_COLOR = {
    COMMON = Color3.new(239/255, 239/255, 239/255),
    RARE = Color3.new(10/255, 202/255, 0/255),
    LEGENDARY = Color3.new(255/255, 149/255, 43/255)
}

local ArrowPanel = {}

ArrowPanel.Panel = mainGui.Windows:FindFirstChild("Arrow_Panel", true)

ArrowPanel.Scrolling_Frame = ArrowPanel.Panel:FindFirstChild("ScrollingFrame", true)
ArrowPanel.Item_Template = ArrowPanel.Panel:FindFirstChild("ItemTemplate", true)
ArrowPanel.UseArrowFrame = ArrowPanel.Panel:FindFirstChild("UserArrowPanels")

ArrowPanel.Default_Panel = ArrowPanel.Panel:FindFirstChild("Default_Panel", true)
ArrowPanel.UniversalArrow_Common = ArrowPanel.Panel:FindFirstChild("UniversalArrow_Common", true)
ArrowPanel.UniversalArrow_Rare = ArrowPanel.Panel:FindFirstChild("UniversalArrow_Rare", true)
ArrowPanel.UniversalArrow_Legendary = ArrowPanel.Panel:FindFirstChild("UniversalArrow_Legendary", true)

ArrowPanel.Button_UniversalArrow_Common = ArrowPanel.Panel:FindFirstChild("Button_Universal_Common", true)
ArrowPanel.Button_UniversalArrow_Rare = ArrowPanel.Panel:FindFirstChild("Button_Universal_Rare", true)
ArrowPanel.Button_UniversalArrow_Legendary = ArrowPanel.Panel:FindFirstChild("Button_Universal_Legendary", true)



--// Setup_ArrowPanel ------------------------------------------------------------
function ArrowPanel.Setup()
    ArrowPanel.Item_Template.Visible = false

    -- connect Use Arrow buttons
    ArrowPanel.Button_UniversalArrow_Common.Activated:Connect(function()
            params = {}
            params.Type = "UniversalArrow"
            params.Rarity = "Common"
            button = ArrowPanel.Button_UniversalArrow_Common
            ArrowPanel.Request_UseArrow(params,button)
    end)
    ArrowPanel.Button_UniversalArrow_Rare.Activated:Connect(function()
        params = {}
        params.Type = "UniversalArrow"
        params.Rarity = "Rare"
        button = ArrowPanel.Button_UniversalArrow_Rare
        ArrowPanel.Request_UseArrow(params,button)
    end)
    ArrowPanel.Button_UniversalArrow_Legendary.Activated:Connect(function()
        params = {}
        params.Type = "UniversalArrow"
        params.Rarity = "Legendary"
        button = ArrowPanel.Button_UniversalArrow_Legendary
        ArrowPanel.Request_UseArrow(params,button)
    end)
end

--// Update_ArrowPanel ------------------------------------------------------------
function ArrowPanel.Update(data)

    -- destroy all arrows int he scrolling frame
    for _,object in pairs(ArrowPanel.Scrolling_Frame:GetChildren()) do
        if object.Name == "arrowItem" then
            object:Destroy()
        end
    end

    -- turn off all right panels and show default panel
    for i,v in pairs(ArrowPanel.UseArrowFrame:GetChildren()) do
        if v:IsA("Frame") then
        v.Visible = false
        end
    end
    ArrowPanel.Default_Panel.Visible = true


    -- build all the arrows and put them in the scrollign frame
    for i,arrow in pairs(data) do

        -- make a new list item
        local newListItem = ArrowPanel.Item_Template:Clone()
        newListItem.Parent = ArrowPanel.Scrolling_Frame
        newListItem.Visible = true
        newListItem.Name = "arrowItem"

        -- change text
        local textLabel = newListItem:FindFirstChild("Arrow_Name", true)
        textLabel.Text = arrow.ArrowName

        -- set some values based on rarity
        local icon = newListItem:FindFirstChild("Arrow_Icon", true)
        local targetPanel
        if arrow.Rarity == "Common" then
            icon.ImageColor3 = GUI_COLOR.COMMON
            textLabel.TextColor3 = GUI_COLOR.COMMON
            targetPanel = ArrowPanel.UniversalArrow_Common
        elseif arrow.Rarity == "Rare" then
            icon.ImageColor3 = GUI_COLOR.RARE
            textLabel.TextColor3 = GUI_COLOR.RARE
            targetPanel = ArrowPanel.UniversalArrow_Rare
        elseif arrow.Rarity == "Legendary" then
            icon.ImageColor3 = GUI_COLOR.LEGENDARY
            textLabel.TextColor3 = GUI_COLOR.LEGENDARY
            targetPanel = ArrowPanel.UniversalArrow_Legendary
        end

        -- connect the click to open the arrow panel
        newListItem.Activated:Connect(function()

            -- turn off all the use arrow panels
            for i,v in pairs(ArrowPanel.UseArrowFrame:GetChildren()) do
                if v:IsA("Frame") then
                v.Visible = false
                end
            end
 
            print(targetPanel.Parent.Parent)

            targetPanel.Visible = true
        end)
    end

    -- finally, update the ScrollingFrame CanvasSize to match the UiListLayout
    ArrowPanel.Scrolling_Frame.CanvasSize = UDim2.new(0, 0, 0, ArrowPanel.Scrolling_Frame.UIListLayout.AbsoluteContentSize.Y)
end

--// Request_UseArrow ------------------------------------------------------------
function ArrowPanel.Request_UseArrow(params,button)
    local currentPower = PowersService:GetCurrentPower()
    if currentPower == "Standless" then
        InventoryService:UseArrow(params)
    else
        print("USE ARROW BUTTON: You Must Be Standless")
        spawn(function()
            local buttonColor = button.BorderColor3
            local buttonText = button.Text
            local textColor = button.TextColor3
            local buttonSize = button.Size

            button.BorderColor3 = Color3.new(255/255, 0/255, 0/255)
            button.Text = "MUST BE STANDLESS"
            button.TextColor3 = Color3.new(255/255, 0/255, 0/255)
            button.Size = button.Size + UDim2.new(0,0,.5,0)
            button.Active = false

            wait(3)

            button.BorderColor3 = buttonColor
            button.Text = buttonText
            button.TextColor3 = textColor
            button.Size = buttonSize
            button.Active = true
        end)
    end
end


return ArrowPanel