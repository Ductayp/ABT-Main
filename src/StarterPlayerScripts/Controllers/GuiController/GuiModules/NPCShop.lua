-- NPCShop
-- PDab
-- 2/11/2021

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local GuiService = Knit.GetService("GuiService")
local InventoryService = Knit.GetService("InventoryService")
local utils = require(Knit.Shared.Utils)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)
local NPC_Icons = mainGui:FindFirstChild("NPC_Icons", true)

local NPCShop = {}

NPCShop.Frame = mainGui.Windows:FindFirstChild("NPCShop", true)
NPCShop.Button_Close = NPCShop.Frame:FindFirstChild("Button_Close", true)
NPCShop.Frame_Icon = NPCShop.Frame:FindFirstChild("Frame_Icon", true)
NPCShop.Text_Title = NPCShop.Frame:FindFirstChild("Text_Title", true)
NPCShop.Text_Body = NPCShop.Frame:FindFirstChild("Text_Body", true)
NPCShop.Text_ShopType = NPCShop.Frame:FindFirstChild("Text_ShopType", true)

NPCShop.ScrollingFrame = NPCShop.Frame:FindFirstChild("ScrollingFrame", true)
NPCShop.Frame_ItemTemplate = NPCShop.Frame:FindFirstChild("Frame_ItemTemplate", true)

NPCShop.Frame_Confirm = NPCShop.Frame:FindFirstChild("Frame_Confirm", true)
NPCShop.Confirm_Text_ItemName = NPCShop.Frame:FindFirstChild("Confirm_Text_ItemName", true)
NPCShop.Confirm_Text_ItemPrice = NPCShop.Frame:FindFirstChild("Confirm_Text_ItemPrice", true)
NPCShop.Confirm_Text_ItemDescription = NPCShop.Frame:FindFirstChild("Confirm_Text_ItemDescription", true)
NPCShop.Confirm_Text_BuySell = NPCShop.Frame:FindFirstChild("Confirm_Text_BuySell", true)
NPCShop.Button_Confirm_Yes = NPCShop.Frame:FindFirstChild("Button_Confirm_Yes", true)
NPCShop.Button_Confirm_No = NPCShop.Frame:FindFirstChild("Button_Confirm_No", true)
NPCShop.Text_Result = NPCShop.Frame:FindFirstChild("Text_Result", true)

NPCShop.AllProximityPrompts = {} -- a table to held them all

local currentShopModule
local currentTransactionId
local currentShopType

local currencyData -- updated by GuiService when the player currency updates

local itemButtons_Enabled = true
local confirmButtons_Enabled = false

--// Setup
function NPCShop.Setup()

    NPCShop.Frame.Visible = false
    NPCShop.Frame_ItemTemplate.Visible = false

    NPCShop.Frame_Confirm.Visible = false
    NPCShop.Text_Result.Visible = false

    -- Close Button
    NPCShop.Button_Close.MouseButton1Down:Connect(function()
        NPCShop.Close()
    end)

    -- connect proximity prompts
    for _, module in pairs(Knit.ShopModules:GetChildren()) do
        local proximityPrompt = require(module).ProximityPrompt

        table.insert(NPCShop.AllProximityPrompts, proximityPrompt)

        proximityPrompt.Triggered:Connect(function(player)

            currentShopModule = module
            NPCShop.RenderShopWindow(module)
            NPCShop.Open()
    
        end)
    end

    NPCShop.Button_Confirm_Yes.MouseButton1Down:Connect(function()


        if confirmButtons_Enabled and currentTransactionId then

            confirmButtons_Enabled = false

            local params = {}
            params.ShopModule = currentShopModule
            params.TransactionId = currentTransactionId

            local success = InventoryService:ShopTransaction(params)
            if success then
                NPCShop.Text_Result.Text = "Success"
                NPCShop.Text_Result.TextColor3 = Color3.fromRGB(0, 255, 0)
                NPCShop.Text_Result.Visible = true
            else
                NPCShop.Text_Result.Text = "Failed"
                NPCShop.Text_Result.TextColor3 = Color3.fromRGB(255, 0, 0)
                NPCShop.Text_Result.Visible = true
            end

            spawn(function()
                wait(2)
                NPCShop.Text_Result.Visible = false
                NPCShop.Frame_Confirm.Visible = false
                confirmButtons_Enabled = true
                itemButtons_Enabled = true
            end)
        end

    end)

    NPCShop.Button_Confirm_No.MouseButton1Down:Connect(function()
        NPCShop.Frame_Confirm.Visible = false
        currentTransactionId = {}
        itemButtons_Enabled = true
        confirmButtons_Enabled = false
    end)

end

function NPCShop.Update(data)
    currencyData = data
end

--// RenderShopWindow
function NPCShop.RenderShopWindow(module)

    local thisModule = require(module)

    currentShopType = thisModule.ShopType

    for _, object in pairs(NPCShop.Frame_Icon:GetChildren()) do
        if object:IsA("Frame") then
            object:Destroy()
        end
    end

    local newIcon
    local findIcon = NPC_Icons:FindFirstChild(thisModule.IconName, true)
    if findIcon then
        newIcon = findIcon:Clone()
        newIcon.Parent = NPCShop.Frame_Icon
        newIcon.Visible = true
    end

    -- fill the title
    NPCShop.Text_Title.Text = thisModule.Title

    -- fill the body
    NPCShop.Text_Body.Text = thisModule.Body
    NPCShop.Text_ShopType.Text = thisModule.ShopType
    NPCShop.Text_ShopType.TextColor3 = thisModule.ShopType_TextColor

    for _, object in pairs(NPCShop.ScrollingFrame:GetChildren()) do
        if object.Name == "ListItem" then
            object:Destroy()
        end
    end

    for index, shopItemDef in pairs(thisModule.ShopItems) do

        local newListItem = NPCShop.Frame_ItemTemplate:Clone()
        newListItem.Name = "ListItem"
        newListItem.Parent = NPCShop.ScrollingFrame
        newListItem.LayoutOrder = index

        local itemName = newListItem:FindFirstChild("Item_Name", true)
        local itemCost = newListItem:FindFirstChild("Item_Cost", true)

        if currentShopType == "BUY" then

            itemName.Text = shopItemDef.OutputName
            itemCost.Text = tostring(shopItemDef.InputValue) .. " " .. shopItemDef.InputName
            itemCost.TextColor3 = Color3.fromRGB(0, 255, 0)

        elseif currentShopType == "SELL" then

            itemName.Text = shopItemDef.InputName
            itemCost.Text = tostring(shopItemDef.OutputValue) .. " " .. shopItemDef.OutputName
            itemCost.TextColor3 = Color3.fromRGB(255, 0, 0)

        end

        newListItem.Visible = true

        local button = newListItem:FindFirstChild("Button_ListItem", true)
        button.MouseButton1Down:Connect(function()
            if itemButtons_Enabled then
                currentTransactionId = index
                NPCShop.ShopItemClicked(shopItemDef)
            end
        end)
        
    end

end

--// ProcessDialogueChoice
function NPCShop.ShopItemClicked(shopItemDef)

    --print(currentShopType)

    if currentShopType == "BUY" then

        NPCShop.Confirm_Text_BuySell.Text = "BUY ITEM"
        NPCShop.Confirm_Text_BuySell.TextColor3 = Color3.fromRGB(0, 255, 0)
        NPCShop.Confirm_Text_ItemName.Text = shopItemDef.OutputName
        NPCShop.Confirm_Text_ItemPrice.Text = shopItemDef.InputValue .. " " .. shopItemDef.InputName
        NPCShop.Confirm_Text_ItemDescription.Text = shopItemDef.Description

    elseif currentShopType == "SELL" then

        NPCShop.Confirm_Text_BuySell.Text = "SELL ITEM"
        NPCShop.Confirm_Text_BuySell.TextColor3 = Color3.fromRGB(255, 0, 0)

        NPCShop.Confirm_Text_ItemName.Text = shopItemDef.InputName
        NPCShop.Confirm_Text_ItemPrice.Text = shopItemDef.OutputValue .. " " .. shopItemDef.OutputName
        NPCShop.Confirm_Text_ItemDescription.Text = shopItemDef.Description

    end

    

    itemButtons_Enabled = false
    NPCShop.Frame_Confirm.Visible = true
    confirmButtons_Enabled = true

end

--// Open
function NPCShop.Open()
    
    Knit.Controllers.GuiController:CloseAllWindows()
    NPCShop.Frame.Visible = true

    itemButtons_Enabled = true
    confirmButtons_Enabled = false

    -- disable all proximity prompts
    for _, proximityPrompt in pairs(NPCShop.AllProximityPrompts) do
        proximityPrompt.Enabled = false
    end

    -- toggle InDialogue and do actions there
    Knit.Controllers.GuiController:ToggleDialogue(true)
end

--// Close
function NPCShop.Close()

    NPCShop.Frame.Visible = false

    currentShopModule = nil
    currentTransactionId = nil
    currentShopType = nil

    itemButtons_Enabled = false
    confirmButtons_Enabled = false

    -- enable all the proximity prompts
    for _, proximityPrompt in pairs(NPCShop.AllProximityPrompts) do
        proximityPrompt.Enabled = true
    end

    -- toggle InDialogue
    Knit.Controllers.GuiController:ToggleDialogue(false)

end


return NPCShop