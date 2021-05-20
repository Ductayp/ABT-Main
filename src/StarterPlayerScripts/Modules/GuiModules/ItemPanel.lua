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

-- utils
local utils = require(Knit.Shared.Utils)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)


local ItemPanel = {}

-- local variables
local currentItemKey -- used to store the key of the active info card.
local currentItemType -- store the item type of tha active item card

-- references
ItemPanel.Panel = mainGui.Windows:FindFirstChild("Item_Panel", true)

-- item list
ItemPanel.Item_List = ItemPanel.Panel:FindFirstChild("Item_List", true)
ItemPanel.Item_Template = ItemPanel.Panel:FindFirstChild("Item_Template", true)

-- item card
ItemPanel.Item_Card = ItemPanel.Panel:FindFirstChild("Item_Card", true)
ItemPanel.Item_Card_Name = ItemPanel.Panel:FindFirstChild("Item_Card_Name", true)
ItemPanel.Item_Card_Quantity = ItemPanel.Panel:FindFirstChild("Item_Card_Quantity", true)
ItemPanel.Item_Card_Description = ItemPanel.Panel:FindFirstChild("Item_Card_Description", true)
ItemPanel.Item_Card_Type = ItemPanel.Panel:FindFirstChild("Item_Card_Type", true)
ItemPanel.Item_Card_Button_Use = ItemPanel.Panel:FindFirstChild("Item_Card_Button_Use", true)
ItemPanel.Item_Card_Cant_Use = ItemPanel.Panel:FindFirstChild("Item_Card_Cant_Use", true)
ItemPanel.Item_Card_Standless = ItemPanel.Panel:FindFirstChild("Item_Card_Standless", true)


--// Setup ------------------------------------------------------------
function ItemPanel.Setup()

    ItemPanel.Item_Template.Visible = false
    ItemPanel.Item_Card.Visible = false
    ItemPanel.Item_Card_Button_Use.Visible = false
    ItemPanel.Item_Card_Button_Use.Active = false
    ItemPanel.Item_Card_Cant_Use.Visible = false
    ItemPanel.Item_Card_Cant_Use.Active = false

    ItemPanel.Item_Card_Button_Use.MouseButton1Down:Connect(function()

        -- if the variable is empty, just return
        if currentItemKey == nil then
            return
        end

        local returnMessage = InventoryService:UseItem(currentItemKey)

        if returnMessage then

            print("BEEEEEEP 1")
            if returnMessage == "Used Arrow" then 
                print("BEEEEEEP 2")
                Knit.Controllers.GuiController:CloseAllWindows()
            end

            spawn(function()

                ItemPanel.Item_Card_Button_Use.Text = returnMessage
                if returnMessage ~= "Success!" then
                    ItemPanel.Item_Card_Button_Use.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                end
                ItemPanel.Item_Card_Button_Use.Active = false
                
                wait(2)
    
                ItemPanel.Item_Card_Button_Use.Text = "USE ITEM"
                ItemPanel.Item_Card_Button_Use.BackgroundColor3 = Color3.fromRGB(0, 209, 0)
                ItemPanel.Item_Card_Button_Use.Active = true
    
            end)
        end
    end)
end

--// Update ------------------------------------------------------------
function ItemPanel.Update(inventoryData)
    ItemPanel.Update_ItemList(inventoryData)
    ItemPanel.Update_ItemFinder()
end

--// UpdateItemList ------------------------------------------------------------
function ItemPanel.Update_ItemList(inventoryData)

    --print("inventoryData", inventoryData)

    -- destroy the old items in the list
    for _, item in pairs(ItemPanel.Item_List:GetChildren()) do
        if item.name == "List_Item" then
            item:Destroy()
        end
    end

    -- add all the new items
    for itemDefKey, itemDefTable in pairs(require(Knit.Defs.ItemDefs)) do

        -- create new item
        local newListItem = ItemPanel.Item_Template:Clone()
        newListItem.Name = "List_Item"
        newListItem.LayoutOrder = itemDefTable.LayoutOrder
        newListItem.Parent = ItemPanel.Item_List
        newListItem:FindFirstChild("Item_Name", true).Text = itemDefTable.Name

        -- set the quatity based on player data
        local quantityOwned
        if inventoryData[itemDefKey] == nil then
            quantityOwned = 0
        else
            quantityOwned = inventoryData[itemDefKey]
        end
        newListItem:FindFirstChild("Item_Quantity", true).Text = quantityOwned

        newListItem.Visible = true

        newListItem.MouseButton1Down:Connect(function()
            currentItemKey = itemDefKey
            currentItemType = itemDefTable.Type
            ItemPanel.Update_InfoCard(itemDefKey, itemDefTable, quantityOwned) -- pass the key and the quantity the player owns
        end)
    end

    -- uwe need to update the visible stand card too, so we use the currentItemKey if not nil
    if currentItemKey then
        local thisDef = require(Knit.Defs.ItemDefs)[currentItemKey]
        local thisQuantity = inventoryData[currentItemKey]
        ItemPanel.Update_InfoCard(currentItemKey, thisDef, thisQuantity)
    end

end

--// UpdateInfoCard ------------------------------------------------------------
function ItemPanel.Update_InfoCard(itemKey, itemDefTable, itemQuantity)

    --print("Update_InfoCard(itemKey, itemDefTable, itemQuantity)", itemKey, itemDefTable, itemQuantity)

    -- setup the card and show it
    ItemPanel.Item_Card_Name.Text = itemDefTable.Name
    ItemPanel.Item_Card_Quantity.Text = "x" .. itemQuantity
    ItemPanel.Item_Card_Description.Text = itemDefTable.Description
    ItemPanel.Item_Card_Type.Text = itemDefTable.Type
    ItemPanel.Item_Card.Visible = true

    -- if the type is ARROW
    if itemDefTable.Type == "Special" then
        ItemPanel.Item_Card_Button_Use.Visible = true
        ItemPanel.Item_Card_Button_Use.Active = true
        ItemPanel.Item_Card_Cant_Use.Visible = false
    end

    -- if the type is COLLECTABLE
    if itemDefTable.Type == "Collectable" then
        ItemPanel.Item_Card_Button_Use.Visible = false
        ItemPanel.Item_Card_Button_Use.Active = false
        ItemPanel.Item_Card_Cant_Use.Visible = true
    end

    -- if the type is EVOLUTION
    if itemDefTable.Type == "Evolution" then
        ItemPanel.Item_Card_Button_Use.Visible = true
        ItemPanel.Item_Card_Button_Use.Active = true
        ItemPanel.Item_Card_Cant_Use.Visible = false
    end
end

--// UpdateItemFinder ------------------------------------------------------------
function ItemPanel.Update_ItemFinder()

end

--// Request_UseArrow ------------------------------------------------------------
function ItemPanel.Request_UseArrow(params, button)

end


return ItemPanel