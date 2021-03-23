-- Storage Panel
-- PDab
-- 1/2/2021

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local InventoryService = Knit.GetService("InventoryService")
local GamePassService = Knit.GetService("GamePassService")
local PowersService = Knit.GetService("PowersService")

-- utils
local utils = require(Knit.Shared.Utils)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)

-- Constants
local GUI_COLOR = {
    COMMON = Color3.new(239/255, 239/255, 239/255),
    RARE = Color3.new(10/255, 202/255, 0/255),
    LEGENDARY = Color3.new(255/255, 149/255, 43/255) 
}

local StoragePanel = {}

-- variables
StoragePanel.StandCardGUID = nil -- this gets set when a player clicks a stand button to show a stand card. Its used in buttons to send the viewed stand for actions

--// DEFS - Storage PANEL ------------------------------------------------------------
StoragePanel.Stand_Icons = mainGui.Stand_Icons

StoragePanel.Panel = mainGui.Windows:FindFirstChild("Storage_Panel", true)
StoragePanel.Frame_StorageGrid = StoragePanel.Panel:FindFirstChild("Frame_StorageGrid", true)
StoragePanel.StandSlot_Equipped = StoragePanel.Panel:FindFirstChild("StandSlot_Equipped", true)
StoragePanel.Textlabel_Standless = StoragePanel.Panel:FindFirstChild("Textlabel_Standless", true)
StoragePanel.Icon_Locked = StoragePanel.Panel:FindFirstChild("Icon_Locked", true)

StoragePanel.Button_EquipStand = StoragePanel.Panel:FindFirstChild("Button_EquipStand", true)
StoragePanel.Button_SellStand = StoragePanel.Panel:FindFirstChild("Button_SellStand", true)
StoragePanel.Button_StoreStand = StoragePanel.Panel:FindFirstChild("Button_StoreStand", true)
StoragePanel.Button_UpgradeStand = StoragePanel.Panel:FindFirstChild("Button_UpgradeStand", true)
StoragePanel.Button_Buy_MobileStorage = StoragePanel.Panel:FindFirstChild("Button_Buy_MobileStorage", true)
StoragePanel.Frame_ManageButtons_Cover = StoragePanel.Panel:FindFirstChild("Frame_ManageButtons_Cover", true)

--local variables
local storageSlotCosts = require(Knit.InventoryModules.StorageSlotCosts)



                   
--// Setup_StandPanel ------------------------------------------------------------
function StoragePanel.Setup()

    StoragePanel.Icon_Locked.Visible = false
    StoragePanel.Frame_ManageButtons_Cover.Visible = true
    StoragePanel.Button_EquipStand.Visible = false
    StoragePanel.Button_SellStand.Visible = false
    StoragePanel.Button_StoreStand.Visible = false
    StoragePanel.Button_UpgradeStand.Visible = false

    for slotNumber, slotCost in pairs(storageSlotCosts) do
        local thisGuiSlot = StoragePanel.Frame_StorageGrid:FindFirstChild("StandSlot_" .. slotNumber, true)
        local lockedIcon = thisGuiSlot.Frame_Icon:FindFirstChild("Icon_Locked", true)
        local convertNumber = utils.CommaValue(slotCost)
        lockedIcon.TextLabel_SlotCost.Text = convertNumber .. "<br/>Soul Orbs"
    end
                       
    StoragePanel.Button_EquipStand.MouseButton1Down:Connect(function()
        print("BEEP")
    end)

    StoragePanel.Button_SellStand.MouseButton1Down:Connect(function()
        print("BEEP")
    end)

    StoragePanel.Button_StoreStand.MouseButton1Down:Connect(function()
        print("BEEP")
    end)

    StoragePanel.Button_UpgradeStand.MouseButton1Down:Connect(function()
        print("BEEP")
    end)

    StoragePanel.Button_Buy_MobileStorage.MouseButton1Down:Connect(function()
        GamePassService:Prompt_GamePassPurchase("MobileStandStorage")
    end)

end


--// Update_StandPanel ------------------------------------------------------------
function StoragePanel.Update(currentStand, storageData, hasGamePass, isInZone)

    --print("StoragePanel.Update", currentStand, storageData, hasGamePass, isInZone)

    -- handle the buttons and cover frame
    if hasGamePass or isInZone then
        StoragePanel.Frame_ManageButtons_Cover.Visible = false
        StoragePanel.Button_EquipStand.Visible = true
        StoragePanel.Button_SellStand.Visible = true
        StoragePanel.Button_StoreStand.Visible = true
        StoragePanel.Button_UpgradeStand.Visible = true
    else
        StoragePanel.Frame_ManageButtons_Cover.Visible = true
        StoragePanel.Button_EquipStand.Visible = false
        StoragePanel.Button_SellStand.Visible = false
        StoragePanel.Button_StoreStand.Visible = false
        StoragePanel.Button_UpgradeStand.Visible = false
    end

    -- handle the Equppped Stand button
    if currentStand.Power == "Standless" then
        StoragePanel.Textlabel_Standless.Visible = true
    else
        StoragePanel.Textlabel_Standless.Visible = false
        local standIconName = currentStand.Power .. "_" .. currentStand.Rarity
        local newIcon = mainGui.Stand_Icons:FindFirstChild(standIconName):Clone()
        newIcon.BorderSizePixel = 0
        newIcon.BackgroundColor3 = Color3.fromRGB(47, 47, 47)
        newIcon.Visible = true
        newIcon.Parent = StoragePanel.StandSlot_Equipped.Frame_Icon
    end

    -- handle locking and unlocking slots
    for count = 1, 11 do
        local thisGuiSlot = StoragePanel.Frame_StorageGrid:FindFirstChild("StandSlot_" .. count, true)
        local lockedIcon = thisGuiSlot.Frame_Icon:FindFirstChild("Icon_Locked", true)
        if storageData.SlotUnlocked[count]  then
            lockedIcon.Visible = false
        else
            lockedIcon.Visible = true
        end
        
    end

    --[[
    for slotNumber, isUnlocked in pairs(storageData.SlotUnlocked) do
        local thisGuiSlot = StoragePanel.Frame_StorageGrid:FindFirstChild("StandSlot_" .. slotNumber, true)
        local lockedIcon = thisGuiSlot.Frame_Icon:FindFirstChild("Icon_Locked", true)

        if isUnlocked then
            lockedIcon.Visible = false
        else
            lockedIcon.Visible = true
        end
    end
    ]]--

end



return StoragePanel