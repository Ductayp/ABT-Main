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

-- local variables
local currentRecipeKey -- used to store the key of the active info card.
local playerInventory -- gets set during the update
local playerCurrency -- gets set during the update
local canCraft -- gets set when the player clicks a recipe

local Crafting = {}

-- references
Crafting.Frame = mainGui.Windows:FindFirstChild("Crafting", true)
Crafting.Button_Close = Crafting.Frame:FindFirstChild("Button_Close", true)

-- recipe list
Crafting.Recipe_List = Crafting.Frame:FindFirstChild("Recipe_List", true)
Crafting.Recipe_Template = Crafting.Frame:FindFirstChild("Recipe_Template", true)

-- recipe card
Crafting.Recipe_Card = Crafting.Frame:FindFirstChild("Recipe_Card", true)
Crafting.Recipe_Card_Name = Crafting.Frame:FindFirstChild("Recipe_Card_Name", true)
Crafting.Recipe_Card_Description = Crafting.Frame:FindFirstChild("Recipe_Card_Description", true)
Crafting.Recipe_Card_Button_Craft = Crafting.Frame:FindFirstChild("Recipe_Card_Button_Craft", true)
Crafting.Frame_IngredientList = Crafting.Frame:FindFirstChild("Frame_IngredientList", true)


--// Setup ------------------------------------------------------------
function Crafting.Setup()

    GuiService:Request_GuiUpdate("CraftingWindow")

    Crafting.Frame.Visible = false
    Crafting.Recipe_Template.Visible = false
    Crafting.Recipe_Card.Visible = false
    Crafting.Recipe_Card_Button_Craft.Visible = false
    Crafting.Recipe_Card_Button_Craft.Active = false

    Crafting.Button_Close.MouseButton1Down:Connect(function()
        Crafting.Close()
    end)

    Crafting.Recipe_Card_Button_Craft.MouseButton1Down:Connect(function()

        if currentRecipeKey == nil then return end
        if not canCraft then return end

        local craftingParams = {}
        craftingParams.ReceipeKey = currentRecipeKey
        local returnMessage = InventoryService:CraftItem(craftingParams)

        if returnMessage then

            spawn(function()

                Crafting.Recipe_Card_Button_Craft.Text = returnMessage

                wait(2)
    
                Crafting.Recipe_Card_Button_Craft.Text = "CRAFT ITEM"

                --[[
                if returnMessage ~= "Success!" then
                    --Crafting.Recipe_Card_Button_Craft.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                end
                Crafting.Recipe_Card_Button_Craft.Active = false
                
                wait(2)
    
                --Crafting.Recipe_Card_Button_Craft.Text = "CRAFT ITEM"
                --Crafting.Recipe_Card_Button_Craft.BackgroundColor3 = Color3.fromRGB(0, 209, 0)
                Crafting.Recipe_Card_Button_Craft.Active = true
                ]]--
    
            end)
        end
    end)

    Crafting.Setup_RecipeList()
end

--// Open ------------------------------------------------------------
function Crafting.Open()
    Knit.Controllers.GuiController:CloseAllWindows()
    Knit.Controllers.GuiController.CurrentWindow = "Crafting"
    Crafting.Frame.Visible = true
end

--// Close ------------------------------------------------------------
function Crafting.Close()
    Knit.Controllers.GuiController:CloseAllWindows()
    Knit.Controllers.GuiController.CurrentWindow = nil
    Crafting.Frame.Visible = false
end

--// Update ------------------------------------------------------------
function Crafting.Update(inventoryData, currencyData)

    playerInventory = inventoryData
    playerCurrency = currencyData

    Crafting.Update_RecipeCard()

end

--// UpdateItemList ------------------------------------------------------------
function Crafting.Setup_RecipeList()

    -- add all the new Crafting
    for craftingDefKey, craftingDefTable in pairs(require(Knit.Defs.CraftingDefs)) do

        -- create new item
        local newListItem = Crafting.Recipe_Template:Clone()
        newListItem.Name = "List_Item"
        newListItem.LayoutOrder = craftingDefTable.LayoutOrder
        newListItem.Parent = Crafting.Recipe_List
        newListItem:FindFirstChild("Item_Name", true).Text = craftingDefTable.Name

        newListItem.Visible = true

        newListItem.MouseButton1Down:Connect(function()
            currentRecipeKey = craftingDefKey
            Crafting.Update_RecipeCard() -- pass the key and the quantity the player owns
        end)
    end

    -- uwe need to update the visible stand card too, so we use the currentRecipeKey if not nil
    if currentRecipeKey then
        local thisDef = require(Knit.Defs.CraftingDefs)[currentRecipeKey]
        Crafting.Update_RecipeCard()
    end

end

--// UpdateInfoCard ------------------------------------------------------------
function Crafting.Update_RecipeCard()

    if not currentRecipeKey then return end
    
    local craftingDefTable = require(Knit.Defs.CraftingDefs)[currentRecipeKey]
    if not craftingDefTable then return end

    -- setup the card and show it
    Crafting.Recipe_Card_Name.Text = craftingDefTable.Name
    Crafting.Recipe_Card_Description.Text = craftingDefTable.Description
    Crafting.Recipe_Card.Visible = true

    -- hide all ingredients in list
    for _, object in pairs(Crafting.Frame_IngredientList:GetChildren()) do
        if object:IsA("Frame") then
            object.Visible = false
        end
    end

    -- update and show ingredients in list
    canCraft = true
    for index, ingredientData in pairs(craftingDefTable.InputItems) do

        local thisListObject = Crafting.Frame_IngredientList:FindFirstChild("Ingredient_" .. index)
        if thisListObject then
            thisListObject.TextLabel.Text = ingredientData.Name .. " x" .. ingredientData.Value
            thisListObject.Visible = true
        end

        local inventoryItem
        if ingredientData.Key == "Cash" or ingredientData.Key == "SoulOrbs" then
            inventoryItem = playerCurrency[ingredientData.Key]
        else
            inventoryItem = playerInventory[ingredientData.Key]
        end

        if inventoryItem ~= nil and inventoryItem >= ingredientData.Value then
            thisListObject.TextLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            thisListObject.TextLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            canCraft = false
        end

    end

    Crafting.Recipe_Card_Button_Craft.Visible = true
    if canCraft then
        Crafting.Recipe_Card_Button_Craft.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        Crafting.Recipe_Card_Button_Craft.Active = true
        Crafting.Recipe_Card_Button_Craft.Text = "CRAFT ITEM"
    else
        Crafting.Recipe_Card_Button_Craft.BackgroundColor3 = Color3.fromRGB(106, 106, 106)
        Crafting.Recipe_Card_Button_Craft.Active = false
        Crafting.Recipe_Card_Button_Craft.Text = "MISSING ITEMS"
    end


end



return Crafting