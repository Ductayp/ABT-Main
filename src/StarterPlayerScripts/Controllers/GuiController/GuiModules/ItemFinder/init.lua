-- Arrow Panel
-- PDab
-- 1/2/2021

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local GamePassService = Knit.GetService("GamePassService")
local GuiService = Knit.GetService("GuiService")
local utils = require(Knit.Shared.Utils)

-- local variables
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)

local color_DeSelect = Color3.fromRGB(63, 63, 63)
local color_Select = Color3.fromRGB(0, 117, 0)

local ItemFinder = {}

-- references
ItemFinder.Frame = mainGui.Windows:FindFirstChild("ItemFinder", true)
ItemFinder.Frame_Blocker = ItemFinder.Frame:FindFirstChild("Frame_Blocker", true)
ItemFinder.Scrolling_Frame = ItemFinder.Frame:FindFirstChild("Scrolling_Frame", true)
ItemFinder.List_Item = ItemFinder.Frame:FindFirstChild("List_Item", true)
ItemFinder.Time_Left_Text = ItemFinder.Frame:FindFirstChild("Time_Left_Text", true)

ItemFinder.Button_Close = ItemFinder.Frame:FindFirstChild("Button_Close", true)
ItemFinder.Button_SelectAll = ItemFinder.Frame:FindFirstChild("Button_SelectAll", true)
ItemFinder.Button_DeSelectAll = ItemFinder.Frame:FindFirstChild("Button_DeSelectAll", true)
ItemFinder.Button_Buy_Finder = ItemFinder.Frame:FindFirstChild("Button_Buy_Finder", true)
--ItemFinder.Button_Finder_On = ItemFinder.Frame:FindFirstChild("Button_Finder_On", true)
--ItemFinder.Button_Finder_Off = ItemFinder.Frame:FindFirstChild("Button_Finder_Off", true)


-- public variables
ItemFinder.ActiveKeys = {}
ItemFinder.CurrentMapZone = nil
ItemFinder.HasAccess = false

--// Setup ------------------------------------------------------------
function ItemFinder.Setup()

    GuiService:Request_GuiUpdate("ItemFinderWindow")

    -- turn it off when we start
    ItemFinder.Frame.Visible = false
    ItemFinder.List_Item.Visible = false

    -- connect close button 
    ItemFinder.Button_Close.MouseButton1Down:Connect(function()
        ItemFinder.Close()
    end)

    -- connect buy button 
    ItemFinder.Button_Buy_Finder.MouseButton1Down:Connect(function()
        GamePassService:Prompt_GamePassPurchase("ItemFinder")
    end)

    --[[
    -- connect ON button 
    ItemFinder.Button_Finder_On.MouseButton1Down:Connect(function()
        ItemFinder.ToggleOn()
    end)

    -- connect OFF button 
    ItemFinder.Button_Finder_Off.MouseButton1Down:Connect(function()
        ItemFinder.ToggleOff()
    end)
    ]]--

    -- connect SelectAll
    ItemFinder.Button_SelectAll.MouseButton1Down:Connect(function()
        if ItemFinder.HasAccess then
            ItemFinder.SelectAll()
        end
    end)

    -- connect SelectAll
    ItemFinder.Button_DeSelectAll.MouseButton1Down:Connect(function()
        if ItemFinder.HasAccess then
            ItemFinder.DeSelectAll()
        end
    end)

    
end

--// Update ------------------------------------------------------------
function ItemFinder.Update(hasGamePass, mapZone)

    if hasGamePass then
        ItemFinder.Frame_Blocker.Visible = false
        ItemFinder.HasAccess = true
        --ItemFinder.Time_Left_Text.Text = "TIME LEFT - INF."
    else
        ItemFinder.Frame_Blocker.Visible = true
        ItemFinder.HasAccess = false
    end

    -- if we are moving into a new mapzone, then turn off all the keys
    if mapZone ~= ItemFinder.CurrentMapZone then
        ItemFinder.ActiveKeys = {}
    end

    ItemFinder.CurrentMapZone = mapZone

    ItemFinder.UpdateItemList(mapZone)
    Knit.Controllers.ItemSpawnController:UpdateItemFinder()

end

function ItemFinder.UpdateItemList(mapZone)

    print("ItemFinder.UpdateItemList(mapZone)", mapZone)

    for _, item in pairs(ItemFinder.Scrolling_Frame:GetChildren()) do
        if item.Name == "ListItem" then
            item:Destroy()
        end
    end

    local itemList = require(script.ItemFinder_List)[mapZone]

    for _, itemTable in pairs(itemList) do
        local newListItem = ItemFinder.List_Item:Clone()
        newListItem.Parent = ItemFinder.Scrolling_Frame
        newListItem.Text = itemTable.Key
        newListItem.Visible = true
        newListItem.Name = "ListItem"
        newListItem:SetAttribute("IsActive", false)
        newListItem:SetAttribute("ItemKey", itemTable.Key)

        --[[
        if ItemFinder.ActiveKeys[itemTable.Key] == nil then
            ItemFinder.ActiveKeys[itemTable.Key] = false
        end
        ]]--

        if ItemFinder.ActiveKeys[itemTable.Key] == true then
            newListItem.BackgroundColor3 = color_Select
            newListItem:SetAttribute("IsActive", true)
            ItemFinder.ActiveKeys[itemTable.Key] = true
        else
            newListItem.BackgroundColor3 = color_DeSelect
            newListItem:SetAttribute("IsActive", false)
            ItemFinder.ActiveKeys[itemTable.Key] = false
        end

        newListItem.MouseButton1Down:Connect(function()

            if ItemFinder.HasAccess then
                if newListItem:GetAttribute("IsActive") then
                    --newListItem:SetAttribute("IsActive", false)
                    ItemFinder.ActiveKeys[itemTable.Key] = false
                else
                    --newListItem:SetAttribute("IsActive", true)
                    ItemFinder.ActiveKeys[itemTable.Key] = true
                end
    
                GuiService:Request_GuiUpdate("ItemFinderWindow")
            end

        end)
    end

end

--// ToggleOn
function ItemFinder.ToggleOn()

end

--// ToggleOff
function ItemFinder.ToggleOff()

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

    --Knit.Controllers.ItemSpawnController:UpdateItemFinder()
    GuiService:Request_GuiUpdate("ItemFinderWindow")
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

    --Knit.Controllers.ItemSpawnController:UpdateItemFinder()
    GuiService:Request_GuiUpdate("ItemFinderWindow")
end

--// Open ------------------------------------------------------------
function ItemFinder.Open()
    Knit.Controllers.GuiController:CloseAllWindows()
    ItemFinder.Frame.Visible = true
    Knit.Controllers.GuiController.CurrentWindow = "ItemFinderWindow"
end

--// Close ------------------------------------------------------------
function ItemFinder.Close()
    Knit.Controllers.GuiController:CloseAllWindows()
    ItemFinder.Frame.Visible = false
    Knit.Controllers.GuiController.CurrentWindow = nil
end

return ItemFinder