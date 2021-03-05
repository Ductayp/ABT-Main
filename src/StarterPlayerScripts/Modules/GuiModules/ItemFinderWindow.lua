-- Arrow Panel
-- PDab
-- 1/2/2021

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local InventoryService = Knit.GetService("InventoryService")
local PowersService = Knit.GetService("PowersService")
local utils = require(Knit.Shared.Utils)
local itemList = require(Knit.GuiModules.ItemFinder_List)

-- local variables
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)
local color_DeSelect = Color3.fromRGB(63, 63, 63)
local color_Select = Color3.fromRGB(0, 117, 0)


local ItemFinder = {}

-- references
ItemFinder.Window = mainGui.Windows:FindFirstChild("ItemFinderWindow", true)
ItemFinder.Scrolling_Frame = ItemFinder.Window:FindFirstChild("Scrolling_Frame", true)
ItemFinder.List_Item = ItemFinder.Window:FindFirstChild("List_Item", true)
ItemFinder.Close_Button = ItemFinder.Window:FindFirstChild("Close_Button", true)
ItemFinder.Button_SelectAll = ItemFinder.Window:FindFirstChild("Button_SelectAll", true)
ItemFinder.Button_DeSelectAll = ItemFinder.Window:FindFirstChild("Button_DeSelectAll", true)

-- public variables
ItemFinder.ActiveKeys = {}


--// Setup ------------------------------------------------------------
function ItemFinder.Setup()

    print("setup")

    -- turn it off when we start
    ItemFinder.Window.Visible = false
    ItemFinder.List_Item.Visible = false

    -- connect close button 
    ItemFinder.Close_Button.MouseButton1Down:Connect(function()
        ItemFinder.Close()
    end)

    -- connect SelectAll
    ItemFinder.Button_SelectAll.MouseButton1Down:Connect(function()
        ItemFinder.SelectAll()
    end)

        -- connect SelectAll
        ItemFinder.Button_DeSelectAll.MouseButton1Down:Connect(function()
            ItemFinder.DeSelectAll()
        end)

    local itemList = require(Knit.GuiModules.ItemFinder_List)
    for _, itemTable in pairs(itemList) do
        local newListItem = ItemFinder.List_Item:Clone()
        newListItem.Parent = ItemFinder.Scrolling_Frame
        newListItem.Text = itemTable.Key
        newListItem.Visible = true
        newListItem.Name = "ListItem" -- we dont use this as the key, but its here in case we need it someday
        newListItem:SetAttribute("IsActive", false)
        newListItem:SetAttribute("ItemKey", itemTable.Key)

        -- add the key to the table
        ItemFinder.ActiveKeys[itemTable.Key] = false

        newListItem.MouseButton1Down:Connect(function()

            if newListItem:GetAttribute("IsActive") then
                newListItem.BackgroundColor3 = color_DeSelect
                newListItem:SetAttribute("IsActive", false)
                ItemFinder.ActiveKeys[itemTable.Key] = false
            else
                newListItem.BackgroundColor3 = color_Select
                newListItem:SetAttribute("IsActive", true)
                ItemFinder.ActiveKeys[itemTable.Key] = true
            end

            Knit.Controllers.ItemSpawnController:UpdateItemFinder()

        end)
    end
end

--// SelectAll ------------------------------------------------------------
function ItemFinder.SelectAll()

    for _, listItem in pairs(ItemFinder.Scrolling_Frame:GetChildren()) do
        if listItem.Name == "ListItem" then
            listItem.BackgroundColor3 = color_Select
            listItem:SetAttribute("IsActive", true)
            ItemFinder.ActiveKeys[listItem:GetAttribute("ItemKey")] = true
        end
    end

    Knit.Controllers.ItemSpawnController:UpdateItemFinder()
end

--// DeSelectAll ------------------------------------------------------------
function ItemFinder.DeSelectAll()

    for _, listItem in pairs(ItemFinder.Scrolling_Frame:GetChildren()) do
        if listItem.Name == "ListItem" then
            listItem.BackgroundColor3 = color_DeSelect
            listItem:SetAttribute("IsActive", false)
            ItemFinder.ActiveKeys[listItem:GetAttribute("ItemKey")] = false
        end
    end

    print("TEST", ItemFinder.ActiveKeys)

    Knit.Controllers.ItemSpawnController:UpdateItemFinder()
end

--// Open ------------------------------------------------------------
function ItemFinder.Open()
    ItemFinder.Window.Visible = true
    Knit.Controllers.GuiController.CurrentWindow = "ItemFinderWindow"
end

--// Close ------------------------------------------------------------
function ItemFinder.Close()
    ItemFinder.Window.Visible = false
    Knit.Controllers.GuiController.CurrentWindow = nil
end

return ItemFinder