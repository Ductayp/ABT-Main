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

-- public variables
ItemFinder.ActiveKeys = {}


--// Setup ------------------------------------------------------------
function ItemFinder.Setup()

    print("setup")

    -- turn it off when we start
    ItemFinder.Window.Visible = false
    ItemFinder.List_Item.Visible = false

    local itemList = require(Knit.GuiModules.ItemFinder_List)
    for _, itemTable in pairs(itemList) do
        local newListItem = ItemFinder.List_Item:Clone()
        newListItem.Parent = ItemFinder.Scrolling_Frame
        newListItem.Text = itemTable.Name
        newListItem.Visible = true
        newListItem.Name = itemTable.Key -- we dont use this as the key, but its here in case we need it someday
        newListItem:SetAttribute("IsActive", false)

        newListItem.MouseButton1Down:Connect(function()

            if newListItem:GetAttribute("IsActive") then
                newListItem.BackgroundColor3 = color_DeSelect
                newListItem:SetAttribute("IsActive", false)
                ItemFinder.ActiveKeys[itemTable.Key] = nil
            else
                newListItem.BackgroundColor3 = color_Select
                newListItem:SetAttribute("IsActive", true)
                ItemFinder.ActiveKeys[itemTable.Key] = true
            end

        end)
    end
end

--// Update ------------------------------------------------------------
function ItemFinder.Update(inventoryData)

end

--// Open ------------------------------------------------------------
function ItemFinder.Open()
    print("open")
    ItemFinder.Window.Visible = true
end

--// Close ------------------------------------------------------------
function ItemFinder.Close()
    print("close")
    ItemFinder.Window.Visible = false
end

return ItemFinder