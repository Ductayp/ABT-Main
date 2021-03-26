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
    Common = Color3.new(239/255, 239/255, 239/255),
    Rare = Color3.new(10/255, 202/255, 0/255),
    Legendary = Color3.new(255/255, 149/255, 43/255) 
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

StoragePanel.Button_Equip = StoragePanel.Panel:FindFirstChild("Button_Equip", true)
StoragePanel.Button_Sell = StoragePanel.Panel:FindFirstChild("Button_Sell", true)
StoragePanel.Button_Store = StoragePanel.Panel:FindFirstChild("Button_Store", true)
StoragePanel.Button_ConfirmSell_Yes = StoragePanel.Panel:FindFirstChild("Button_ConfirmSell_Yes", true)
StoragePanel.Button_ConfirmSell_No = StoragePanel.Panel:FindFirstChild("Button_ConfirmSell_No", true)

StoragePanel.Button_Buy_MobileStorage = StoragePanel.Panel:FindFirstChild("Button_Buy_MobileStorage", true)
StoragePanel.Frame_ManageButtons_Cover = StoragePanel.Panel:FindFirstChild("Frame_ManageButtons_Cover", true)

StoragePanel.Stand_Card = StoragePanel.Panel:FindFirstChild("Stand_Card", true)
StoragePanel.Frame_XP = StoragePanel.Panel:FindFirstChild("Frame_XP", true)
StoragePanel.Xp_Bar = StoragePanel.Panel:FindFirstChild("Xp_Bar", true)
StoragePanel.Xp_Text = StoragePanel.Panel:FindFirstChild("Xp_Text", true)
StoragePanel.Frame_ConfirmSell = StoragePanel.Panel:FindFirstChild("Frame_ConfirmSell", true)

--local variables
local storageDefs = require(Knit.Defs.StandStorageDefs)
local slotData = nil
local selectedStandData = nil

--// Setup_StandPanel ------------------------------------------------------------
function StoragePanel.Setup()

    StoragePanel.Icon_Locked.Visible = false
    StoragePanel.Frame_ManageButtons_Cover.Visible = true
    StoragePanel.Button_Equip.Visible = false
    StoragePanel.Button_Sell.Visible = false
    StoragePanel.Button_Store.Visible = false
    StoragePanel.Stand_Card.Visible = false
    StoragePanel.Frame_ConfirmSell.Visible = false

    for slotNumber, slotCost in pairs(storageDefs.SlotCosts) do
        local thisGuiSlot = StoragePanel.Frame_StorageGrid:FindFirstChild("StandSlot_" .. slotNumber, true)
        local lockedIcon = thisGuiSlot.Frame_Icon:FindFirstChild("Icon_Locked", true)
        local convertNumber = utils.CommaValue(slotCost)
        lockedIcon.TextLabel_SlotCost.Text = convertNumber .. "<br/>Soul Orbs"
        thisGuiSlot:SetAttribute("SlotId", slotNumber)

        thisGuiSlot.MouseButton1Down:Connect(function()
            StoragePanel.SlotClicked(thisGuiSlot)
        end)
    end

    StoragePanel.StandSlot_Equipped:SetAttribute("SlotId", "Equipped")

    StoragePanel.StandSlot_Equipped.MouseButton1Down:Connect(function()
        StoragePanel.StandSlot_Equipped:SetAttribute("LockStatus", "Unlocked")
        StoragePanel.SlotClicked(StoragePanel.StandSlot_Equipped)
    end)
             
    StoragePanel.Button_Equip.MouseButton1Down:Connect(function()
        if selectedStandData.GUID then
            InventoryService:EquipStand(selectedStandData.GUID)
        end
    end)

    StoragePanel.Button_Sell.MouseButton1Down:Connect(function()
        StoragePanel.Frame_ConfirmSell.Visible = true
        --StoragePanel.SellStand()
    end)

    StoragePanel.Button_ConfirmSell_Yes.MouseButton1Down:Connect(function()
        if selectedStandData.GUID then
            InventoryService:SellStand(selectedStandData.GUID)
        end
    end)

    StoragePanel.Button_ConfirmSell_No.MouseButton1Down:Connect(function()
        StoragePanel.Frame_ConfirmSell.Visible = false
    end)

    StoragePanel.Button_Store.MouseButton1Down:Connect(function()
        InventoryService:StoreStand()
    end)

    StoragePanel.Button_Buy_MobileStorage.MouseButton1Down:Connect(function()
        GamePassService:Prompt_GamePassPurchase("MobileStandStorage")
    end)

end


--// Update_StandPanel ------------------------------------------------------------
function StoragePanel.Update(currentStand, storageData, hasGamePass, isInZone)

    print("StoragePanel.Update", currentStand, storageData, hasGamePass, isInZone)

    StoragePanel.Stand_Card.Visible = false
    StoragePanel.Frame_ConfirmSell.Visible = false

    -- set data
    selectedStandData = nil
    slotData = {}
    slotData.CurrentStand = currentStand
    slotData.StorageData = storageData

    -- handle the buttons and cover frame
    if hasGamePass or isInZone then
        StoragePanel.Frame_ManageButtons_Cover.Visible = false
        StoragePanel.Button_Equip.Visible = true
        StoragePanel.Button_Sell.Visible = true
        StoragePanel.Button_Store.Visible = true
    else
        StoragePanel.Frame_ManageButtons_Cover.Visible = true
        StoragePanel.Button_Equip.Visible = false
        StoragePanel.Button_Sell.Visible = false
        StoragePanel.Button_Store.Visible = false
    end

    -- handle the Equippped Stand button
    if currentStand.Power == "Standless" then
        StoragePanel.StandSlot_Equipped.Frame_Icon.Textlabel_Standless.Visible = true
        -- destroy old stand icons
        for i,v in pairs(StoragePanel.StandSlot_Equipped.Frame_Icon:GetChildren()) do
            if v.Name ~= "Textlabel_Standless" then
                v:Destroy()
            end
        end

    else
        StoragePanel.StandSlot_Equipped.Frame_Icon.Textlabel_Standless.Visible = false
        local standIconName = currentStand.Power .. "_" .. currentStand.Rarity
        local newIcon = mainGui.Stand_Icons:FindFirstChild(standIconName):Clone()
        newIcon.BorderSizePixel = 0
        newIcon.BackgroundColor3 = Color3.fromRGB(47, 47, 47)
        newIcon.Visible = true
        newIcon.Name = "StandIcon"
        newIcon.Parent = StoragePanel.StandSlot_Equipped.Frame_Icon
    end

    -- handle locking and unlocking slots
    for count = 1, storageDefs.MaxSlots do -- there are 11 storage slots possible

        local thisGuiSlot = StoragePanel.Frame_StorageGrid:FindFirstChild("StandSlot_" .. count, true)
        local lockedIcon = thisGuiSlot.Frame_Icon:FindFirstChild("Icon_Locked", true)

        local standIcon = thisGuiSlot:FindFirstChild("StandIcon")

        if count <= storageData.SlotsUnlocked then
            local countString = tostring(count)
            lockedIcon.Visible = false
            thisGuiSlot:SetAttribute("LockStatus", "Unlocked")

            -- if there is a stand in this slot, then show the icon
            if storageData.StoredStands[count] then
                local standIconName = storageData.StoredStands[count].Power .. "_" .. storageData.StoredStands[count].Rarity
                local newIcon = mainGui.Stand_Icons:FindFirstChild(standIconName):Clone()
                newIcon.BorderSizePixel = 0
                newIcon.BackgroundColor3 = Color3.fromRGB(47, 47, 47)
                newIcon.Visible = true
                newIcon.Parent = thisGuiSlot.Frame_Icon
            else
                -- destroy old stand icons
                for i,v in pairs(thisGuiSlot.Frame_Icon:GetChildren()) do
                    if v.Name ~= "Icon_Locked" then
                        v:Destroy()
                    end
                end
            end

        elseif count == storageData.SlotsUnlocked + 1 then
            lockedIcon.Visible = true
            lockedIcon.TextLabel_SlotCost.TextColor3 = Color3.fromRGB(0, 255, 0)
            thisGuiSlot:SetAttribute("LockStatus", "Locked_CanBuy")

        else
            lockedIcon.Visible = true
            lockedIcon.TextLabel_SlotCost.TextColor3 = Color3.fromRGB(163, 163, 163)
            thisGuiSlot:SetAttribute("LockStatus", "Locked_CantBuy")
        end
    end
end

function StoragePanel.SlotClicked(thisSlot)

    -- start wth the card hidden
    StoragePanel.Stand_Card.Visible = false
    StoragePanel.Frame_ConfirmSell.Visible = false

    local textLabel = thisSlot:FindFirstChild("TextLabel_SlotCost", true)

    -- check LockStatus
    local lockStatus = thisSlot:GetAttribute("LockStatus")

    if lockStatus == "Locked_CantBuy" or lockStatus == "CantAfford" then
        return
    end

    if lockStatus == "Locked_CanBuy" then
        spawn(function()
            thisSlot:SetAttribute("LockStatus", "Buy_Confirm")
            local originalText = textLabel.Text
            local originalColor = textLabel.TextColor3
            textLabel.Text = "CLICK TO CONFIRM"
            textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            wait(3)
            textLabel.Text = originalText
            textLabel.TextColor3 = originalColor
            thisSlot:SetAttribute("LockStatus", "Locked_CanBuy")
        end)
        return -- return so we can wait for another click
    end

    if lockStatus == "Buy_Confirm" then
        local results = InventoryService:BuyStorage()
        if results == "CantAfford" then
            spawn(function()

                local newLabel = textLabel:Clone()
                newLabel.Text = "CANT AFFORD"
                newLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                newLabel.Parent = textLabel.Parent
                newLabel.TextYAlignment = "Top"
                thisSlot:SetAttribute("LockStatus", "CantAfford")
                wait(3)
                newLabel:Destroy()
                thisSlot:SetAttribute("LockStatus", "Locked_CanBuy")
            end)
        end
        return -- we return because this slot isnt holding a stand
    end

    -- set thisStandData
    local slotId = thisSlot:GetAttribute("SlotId")
    if slotId == "Equipped" then
        StoragePanel.Button_Equip.Visible = false
        StoragePanel.Button_Store.Visible = true
        selectedStandData = slotData.CurrentStand
    else
        local convertedSlotId = tonumber(slotId)
        StoragePanel.Button_Equip.Visible = true
        StoragePanel.Button_Store.Visible = false
        selectedStandData = slotData.StorageData.StoredStands[convertedSlotId]
    end

    -- if the slot is empty, selectedStandData will be nil so just return
    if selectedStandData == nil then
        return
    end

    -- return if the equipped stand is Standless
    if selectedStandData.Power == "Standless"  and slotId == "Equipped" then
        return
    end


    -- setup to display the card
    local powerModule = require(Knit.Shared.PowerModules.Powers[selectedStandData.Power])
    StoragePanel.Stand_Card.Visible = true

    -- set all the text
    StoragePanel.Stand_Card.Stand_Name.Text = powerModule.Defs.PowerName
    StoragePanel.Stand_Card.Stand_Rarity.Text = selectedStandData.Rarity
    StoragePanel.Stand_Card.Stand_Rarity.TextColor3 = GUI_COLOR[selectedStandData.Rarity]
    
    -- set the stand icon
    local targetIconFrame = StoragePanel.Stand_Card:FindFirstChild("Stand_Icon_Frame", true)
    for i, v in pairs(targetIconFrame:GetChildren()) do
        if v.Name == "StandIcon" then
            v:Destroy()
        end
    end
    local standIconName = selectedStandData.Power .. "_" .. selectedStandData.Rarity
    local newIcon = mainGui.Stand_Icons:FindFirstChild(standIconName):Clone()
    newIcon.BorderSizePixel = 0
    newIcon.BackgroundColor3 = Color3.fromRGB(47, 47, 47)
    newIcon.Visible = true
    newIcon.Name = "StandIcon"
    newIcon.Parent = targetIconFrame

    -- set te Xp bar
    local maxExperience = powerModule.Defs.MaxXp[selectedStandData.Rarity]
    StoragePanel.Xp_Text.Text = selectedStandData.Xp .. " / " .. maxExperience
    local percent = selectedStandData.Xp / maxExperience
    StoragePanel.Xp_Bar.Size = UDim2.new(percent, StoragePanel.Xp_Bar.Size.X.Offset, StoragePanel.Xp_Bar.Size.Y.Scale, StoragePanel.Xp_Bar.Size.Y.Offset)

end

function StoragePanel.SellStand()
    StoragePanel.Frame_ConfirmSell.Visible = true
end


return StoragePanel