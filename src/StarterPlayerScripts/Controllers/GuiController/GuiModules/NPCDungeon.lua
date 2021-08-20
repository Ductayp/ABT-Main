-- NPCDungeon
-- PDab
-- 2/11/2021

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local GuiService = Knit.GetService("GuiService")
--local InventoryService = Knit.GetService("InventoryService")
local utils = require(Knit.Shared.Utils)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)
local NPC_Icons = mainGui:FindFirstChild("NPC_Icons", true)

local NPCDungeon = {}

NPCDungeon.Frame = mainGui.Windows:FindFirstChild("NPCDungeon", true)
--[[
NPCDungeon.Button_Close = NPCDungeon.Frame:FindFirstChild("Button_Close", true)
NPCDungeon.Frame_Icon = NPCDungeon.Frame:FindFirstChild("Frame_Icon", true)
NPCDungeon.Text_Title = NPCDungeon.Frame:FindFirstChild("Text_Title", true)
NPCDungeon.Text_Body = NPCDungeon.Frame:FindFirstChild("Text_Body", true)
NPCDungeon.Text_ShopType = NPCDungeon.Frame:FindFirstChild("Text_ShopType", true)

NPCDungeon.ScrollingFrame = NPCDungeon.Frame:FindFirstChild("ScrollingFrame", true)
NPCDungeon.Frame_ItemTemplate = NPCDungeon.Frame:FindFirstChild("Frame_ItemTemplate", true)

NPCDungeon.Frame_Confirm = NPCDungeon.Frame:FindFirstChild("Frame_Confirm", true)
NPCDungeon.Confirm_Text_ItemName = NPCDungeon.Frame:FindFirstChild("Confirm_Text_ItemName", true)
NPCDungeon.Confirm_Text_ItemPrice = NPCDungeon.Frame:FindFirstChild("Confirm_Text_ItemPrice", true)
NPCDungeon.Confirm_Text_ItemDescription = NPCDungeon.Frame:FindFirstChild("Confirm_Text_ItemDescription", true)
NPCDungeon.Confirm_Text_BuySell = NPCDungeon.Frame:FindFirstChild("Confirm_Text_BuySell", true)
NPCDungeon.Button_Confirm_Yes = NPCDungeon.Frame:FindFirstChild("Button_Confirm_Yes", true)
NPCDungeon.Button_Confirm_No = NPCDungeon.Frame:FindFirstChild("Button_Confirm_No", true)
NPCDungeon.Text_Result = NPCDungeon.Frame:FindFirstChild("Text_Result", true)
]]--

NPCDungeon.AllProximityPrompts = {} -- a table to held them all

--local currentShopModule
--local currentTransactionId
--local currentShopType

--local currencyData -- updated by GuiService when the player currency updates

--local itemButtons_Enabled = true
--local confirmButtons_Enabled = false

--// Setup
function NPCDungeon.Setup()

    NPCDungeon.Frame.Visible = false
    NPCDungeon.Frame_ItemTemplate.Visible = false

    NPCDungeon.Frame_Confirm.Visible = false
    NPCDungeon.Text_Result.Visible = false

    -- Close Button
    NPCDungeon.Button_Close.MouseButton1Down:Connect(function()
        NPCDungeon.Close()
    end)

    -- connect proximity prompts
    for _, module in pairs(Knit.ShopModules:GetChildren()) do
        local proximityPrompt = require(module).ProximityPrompt

        table.insert(NPCDungeon.AllProximityPrompts, proximityPrompt)

        proximityPrompt.Triggered:Connect(function(player)

            currentShopModule = module
            NPCDungeon.RenderShopWindow(module)
            NPCDungeon.Open()
    
        end)
    end

    NPCDungeon.Button_Confirm_Yes.MouseButton1Down:Connect(function()


        if confirmButtons_Enabled and currentTransactionId then

            confirmButtons_Enabled = false

            local params = {}
            params.ShopModule = currentShopModule
            params.TransactionId = currentTransactionId

            local success = InventoryService:ShopTransaction(params)
            if success then
                NPCDungeon.Text_Result.Text = "Success"
                NPCDungeon.Text_Result.TextColor3 = Color3.fromRGB(0, 255, 0)
                NPCDungeon.Text_Result.Visible = true
            else
                NPCDungeon.Text_Result.Text = "Failed"
                NPCDungeon.Text_Result.TextColor3 = Color3.fromRGB(255, 0, 0)
                NPCDungeon.Text_Result.Visible = true
            end

            spawn(function()
                wait(2)
                NPCDungeon.Text_Result.Visible = false
                NPCDungeon.Frame_Confirm.Visible = false
                confirmButtons_Enabled = true
                itemButtons_Enabled = true
            end)
        end

    end)

    NPCDungeon.Button_Confirm_No.MouseButton1Down:Connect(function()
        NPCDungeon.Frame_Confirm.Visible = false
        currentTransactionId = {}
        itemButtons_Enabled = true
        confirmButtons_Enabled = false
    end)

end

function NPCDungeon.Update(data)
    currencyData = data
end

--// RenderShopWindow
function NPCDungeon.RenderShopWindow(module)

    local thisModule = require(module)

    currentShopType = thisModule.ShopType

    for _, object in pairs(NPCDungeon.Frame_Icon:GetChildren()) do
        if object:IsA("Frame") then
            object:Destroy()
        end
    end

    local newIcon
    local findIcon = NPC_Icons:FindFirstChild(thisModule.IconName, true)
    if findIcon then
        newIcon = findIcon:Clone()
        newIcon.Parent = NPCDungeon.Frame_Icon
        newIcon.Visible = true
    end

    -- fill the title
    NPCDungeon.Text_Title.Text = thisModule.Title

    -- fill the body
    NPCDungeon.Text_Body.Text = thisModule.Body
    NPCDungeon.Text_ShopType.Text = thisModule.ShopType
    NPCDungeon.Text_ShopType.TextColor3 = thisModule.ShopType_TextColor

    for _, object in pairs(NPCDungeon.ScrollingFrame:GetChildren()) do
        if object.Name == "ListItem" then
            object:Destroy()
        end
    end

    for index, shopItemDef in pairs(thisModule.ShopItems) do

        local newListItem = NPCDungeon.Frame_ItemTemplate:Clone()
        newListItem.Name = "ListItem"
        newListItem.Parent = NPCDungeon.ScrollingFrame
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
                NPCDungeon.ShopItemClicked(shopItemDef)
            end
        end)
        
    end

end

--// ProcessDialogueChoice
function NPCDungeon.ShopItemClicked(shopItemDef)

    --print(currentShopType)

    if currentShopType == "BUY" then

        NPCDungeon.Confirm_Text_BuySell.Text = "BUY ITEM"
        NPCDungeon.Confirm_Text_BuySell.TextColor3 = Color3.fromRGB(0, 255, 0)
        NPCDungeon.Confirm_Text_ItemName.Text = shopItemDef.OutputName
        NPCDungeon.Confirm_Text_ItemPrice.Text = shopItemDef.InputValue .. " " .. shopItemDef.InputName
        NPCDungeon.Confirm_Text_ItemDescription.Text = shopItemDef.Description

    elseif currentShopType == "SELL" then

        NPCDungeon.Confirm_Text_BuySell.Text = "SELL ITEM"
        NPCDungeon.Confirm_Text_BuySell.TextColor3 = Color3.fromRGB(255, 0, 0)

        NPCDungeon.Confirm_Text_ItemName.Text = shopItemDef.InputName
        NPCDungeon.Confirm_Text_ItemPrice.Text = shopItemDef.OutputValue .. " " .. shopItemDef.OutputName
        NPCDungeon.Confirm_Text_ItemDescription.Text = shopItemDef.Description

    end

    

    itemButtons_Enabled = false
    NPCDungeon.Frame_Confirm.Visible = true
    confirmButtons_Enabled = true

end

--// Open
function NPCDungeon.Open()
    
    Knit.Controllers.GuiController:CloseAllWindows()
    NPCDungeon.Frame.Visible = true

    itemButtons_Enabled = true
    confirmButtons_Enabled = false

    -- disable all proximity prompts
    for _, proximityPrompt in pairs(NPCDungeon.AllProximityPrompts) do
        proximityPrompt.Enabled = false
    end

    -- toggle InDialogue and do actions there
    Knit.Controllers.GuiController:ToggleDialogue(true)
end

--// Close
function NPCDungeon.Close()

    NPCDungeon.Frame.Visible = false

    currentShopModule = nil
    currentTransactionId = nil
    currentShopType = nil

    itemButtons_Enabled = false
    confirmButtons_Enabled = false

    -- enable all the proximity prompts
    for _, proximityPrompt in pairs(NPCDungeon.AllProximityPrompts) do
        proximityPrompt.Enabled = true
    end

    -- toggle InDialogue
    Knit.Controllers.GuiController:ToggleDialogue(false)

end


return NPCDungeon