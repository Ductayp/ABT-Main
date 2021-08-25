-- Arrow Panel
-- PDab
-- 1/2/2021

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local GuiService = Knit.GetService("GuiService")
local InventoryService = Knit.GetService("InventoryService")

-- utils
local utils = require(Knit.Shared.Utils)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)


local Items = {}

-- local variables
local inventoryData
local currentItemKey -- used to store the key of the active info card.
local currentItemType -- store the item type of tha active item card

-- references
Items.Frame = mainGui.Windows:FindFirstChild("Items", true)

-- item list
Items.Item_List = Items.Frame:FindFirstChild("Item_List", true)
Items.Item_Template = Items.Frame:FindFirstChild("Item_Template", true)

Items.Button_Close = Items.Frame:FindFirstChild("Button_Close", true)

-- item card
Items.Item_Card = Items.Frame:FindFirstChild("Item_Card", true)
Items.Item_Card_Name = Items.Frame:FindFirstChild("Item_Card_Name", true)
Items.Item_Card_Quantity = Items.Frame:FindFirstChild("Item_Card_Quantity", true)
Items.Item_Card_Description = Items.Frame:FindFirstChild("Item_Card_Description", true)
Items.Item_Card_Type = Items.Frame:FindFirstChild("Item_Card_Type", true)
Items.Item_Card_Button_Use = Items.Frame:FindFirstChild("Item_Card_Button_Use", true)
Items.Item_Card_Cant_Use = Items.Frame:FindFirstChild("Item_Card_Cant_Use", true)
Items.Item_Card_Standless = Items.Frame:FindFirstChild("Item_Card_Standless", true)


--// Setup ------------------------------------------------------------
function Items.Setup()

    GuiService:Request_GuiUpdate("ItemsWindow")

    Items.Frame.Visible = false
    Items.Item_Template.Visible = false
    Items.Item_Card.Visible = false
    Items.Item_Card_Button_Use.Visible = false
    Items.Item_Card_Button_Use.Active = false
    Items.Item_Card_Cant_Use.Visible = false
    Items.Item_Card_Cant_Use.Active = false

    Items.Button_Close.MouseButton1Down:Connect(function()
        Items.Close()
    end)

    Items.Item_Card_Button_Use.MouseButton1Down:Connect(function()

        -- if the variable is empty, just return
        if currentItemKey == nil then
            return
        end

        local returnMessage = InventoryService:UseItem(currentItemKey)

        if returnMessage then

            if returnMessage == "Used Arrow" then 
                Knit.Controllers.GuiController:CloseAllWindows()
            end

            spawn(function()

                Items.Item_Card_Button_Use.Text = returnMessage
                if returnMessage ~= "Success!" then
                    Items.Item_Card_Button_Use.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                end
                Items.Item_Card_Button_Use.Active = false
                
                wait(2)
    
                Items.Item_Card_Button_Use.Text = "USE ITEM"
                Items.Item_Card_Button_Use.BackgroundColor3 = Color3.fromRGB(0, 209, 0)
                Items.Item_Card_Button_Use.Active = true
    
            end)
        end
    end)
end

--// Open ------------------------------------------------------------
function Items.Open()
    Knit.Controllers.GuiController:CloseAllWindows()
    Knit.Controllers.GuiController.CurrentWindow = "Items"
    Items.Frame.Visible = true
end

--// Close ------------------------------------------------------------
function Items.Close()
    Knit.Controllers.GuiController:CloseAllWindows()
    Knit.Controllers.GuiController.CurrentWindow = nil
    Items.Frame.Visible = false
end

--// Update ------------------------------------------------------------
function Items.Update(data)

    inventoryData = data
    Items.Update_ItemList()
end

--// UpdateItemList ------------------------------------------------------------
function Items.Update_ItemList()

    -- destroy the old items in the list
    for _, item in pairs(Items.Item_List:GetChildren()) do
        if item.name == "List_Item" then
            item:Destroy()
        end
    end

    -- add all the new items
    for itemDefKey, itemDefTable in pairs(require(Knit.Defs.ItemDefs)) do

        -- create new item
        local newListItem = Items.Item_Template:Clone()
        newListItem.Name = "List_Item"
        newListItem.LayoutOrder = itemDefTable.LayoutOrder
        newListItem.Parent = Items.Item_List
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
            Items.Update_InfoCard(itemDefKey, itemDefTable, quantityOwned) -- pass the key and the quantity the player owns
        end)
    end

    -- uwe need to update the visible stand card too, so we use the currentItemKey if not nil
    if currentItemKey then
        local thisDef = require(Knit.Defs.ItemDefs)[currentItemKey]
        local thisQuantity = inventoryData[currentItemKey]
        Items.Update_InfoCard(currentItemKey, thisDef, thisQuantity)
    end

end

--// UpdateInfoCard ------------------------------------------------------------
function Items.Update_InfoCard(itemKey, itemDefTable, itemQuantity)

    --print("Update_InfoCard(itemKey, itemDefTable, itemQuantity)", itemKey, itemDefTable, itemQuantity)

    if not itemQuantity then 
        itemQuantity = 0
    end

    -- setup the card and show it
    Items.Item_Card_Name.Text = itemDefTable.Name
    Items.Item_Card_Quantity.Text = "x" .. itemQuantity
    Items.Item_Card_Description.Text = itemDefTable.Description
    Items.Item_Card_Type.Text = itemDefTable.Type
    Items.Item_Card.Visible = true

    -- if the type is ARROW
    if itemDefTable.Type == "Special" then
        Items.Item_Card_Button_Use.Visible = true
        Items.Item_Card_Button_Use.Active = true
        Items.Item_Card_Cant_Use.Visible = false
    end

    -- if the type is COLLECTABLE
    if itemDefTable.Type == "Collectable" then
        Items.Item_Card_Button_Use.Visible = false
        Items.Item_Card_Button_Use.Active = false
        Items.Item_Card_Cant_Use.Visible = true
    end

    -- if the type is EVOLUTION
    if itemDefTable.Type == "Evolution" then
        Items.Item_Card_Button_Use.Visible = true
        Items.Item_Card_Button_Use.Active = true
        Items.Item_Card_Cant_Use.Visible = false
    end
end


--// Request_UseArrow ------------------------------------------------------------
function Items.Request_UseArrow(params, button)

end


return Items