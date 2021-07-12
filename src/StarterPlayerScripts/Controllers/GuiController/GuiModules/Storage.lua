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
local GUI_COLOR = { -- by rank number
    [1] = Color3.new(239/255, 239/255, 239/255),
    [2] = Color3.new(10/255, 202/255, 0/255),
    [3] = Color3.new(255/255, 149/255, 43/255) 
}
local TOGGLE_COLOR = {
    On = Color3.fromRGB(0, 170, 0),
    Off = Color3.fromRGB(86, 86, 86),
    Fail = Color3.fromRGB(195, 0, 0),
}

local Storage = {}

-- variables
Storage.EvolutionAction = nil -- gets set when a user clicks evolutions
Storage.StandCardGUID = nil -- this gets set when a player clicks a stand button to show a stand card. Its used in buttons to send the viewed stand for actions

--// DEFS - Storage PANEL ------------------------------------------------------------
Storage.Stand_Icons = mainGui.Stand_Icons

Storage.Frame = mainGui.Windows:FindFirstChild("Storage", true)
Storage.Frame_StorageGrid = Storage.Frame:FindFirstChild("Frame_StorageGrid", true)
Storage.StandSlot_Equipped = Storage.Frame:FindFirstChild("StandSlot_Equipped", true)
Storage.Textlabel_Standless = Storage.Frame:FindFirstChild("Textlabel_Standless", true)
Storage.Icon_Locked = Storage.Frame:FindFirstChild("Icon_Locked", true)

-- stand management buttons
Storage.Button_Equip = Storage.Frame:FindFirstChild("Button_Equip", true)
Storage.Button_Sell = Storage.Frame:FindFirstChild("Button_Sell", true)
Storage.Button_Store = Storage.Frame:FindFirstChild("Button_Store", true)
Storage.Button_Close = Storage.Frame:FindFirstChild("Button_Close", true)

-- stand card stuff
Storage.Frame_StandCard = Storage.Frame:FindFirstChild("Frame_StandCard", true)
Storage.Frame_XP = Storage.Frame:FindFirstChild("Frame_XP", true)
Storage.Xp_Bar = Storage.Frame:FindFirstChild("Xp_Bar", true)
Storage.Xp_Text = Storage.Frame:FindFirstChild("Xp_Text", true)
Storage.Star_1 = Storage.Frame:FindFirstChild("star_1", true)
Storage.Star_2 = Storage.Frame:FindFirstChild("star_2", true)
Storage.Star_3 = Storage.Frame:FindFirstChild("star_3", true)

-- confirm sell stuff
Storage.Frame_ConfirmSell = Storage.Frame:FindFirstChild("Frame_ConfirmSell", true)
Storage.Button_ConfirmSell_Yes = Storage.Frame:FindFirstChild("Button_ConfirmSell_Yes", true)
Storage.Button_ConfirmSell_No = Storage.Frame:FindFirstChild("Button_ConfirmSell_No", true)

--local variables
local storageDefs = require(Knit.Defs.StandStorageDefs)
local slotData
local selectedStandData
local canManageStands
local manageButtonsEnabaled = true

--// Setup ------------------------------------------------------------
function Storage.Setup()

    Storage.Frame.Visible = false
    Storage.Icon_Locked.Visible = false
    Storage.Button_Equip.Visible = false
    Storage.Button_Sell.Visible = false
    Storage.Button_Store.Visible = false
    Storage.Frame_StandCard.Visible = false
    Storage.Frame_ConfirmSell.Visible = false

    -- setup the storage slots
    for slotNumber, slotCost in pairs(storageDefs.SlotCosts) do
        local thisGuiSlot = Storage.Frame_StorageGrid:FindFirstChild("StandSlot_" .. slotNumber, true)
        local lockedIcon = thisGuiSlot.Frame_Icon:FindFirstChild("Icon_Locked", true)
        local convertNumber = utils.CommaValue(slotCost)
        lockedIcon.TextLabel_SlotCost.Text = convertNumber .. "<br/>Soul Orbs"
        thisGuiSlot:SetAttribute("SlotId", slotNumber)

        thisGuiSlot.MouseButton1Down:Connect(function()
            Storage.SlotClicked(thisGuiSlot)
        end)
    end

    Storage.StandSlot_Equipped:SetAttribute("SlotId", "Equipped")

    Storage.StandSlot_Equipped.MouseButton1Down:Connect(function()
        Storage.StandSlot_Equipped:SetAttribute("LockStatus", "Unlocked")
        Storage.SlotClicked(Storage.StandSlot_Equipped)
    end)
       
    -- setup stand manage buttons
    Storage.Button_Equip.MouseButton1Down:Connect(function()
        if manageButtonsEnabaled then
            if not canManageStands then 
                manageButtonsEnabaled = false
                local originalText = Storage.Button_Equip.Text
                Storage.Button_Equip.Text = "GO TO STORAGE"
                wait(3)
                Storage.Button_Equip.Text = originalText
                manageButtonsEnabaled = true
                return
            end

            if selectedStandData.GUID then
                InventoryService:EquipStand(selectedStandData.GUID)
            end
        end
    end)

    Storage.Button_Store.MouseButton1Down:Connect(function()
        if manageButtonsEnabaled then
            if not canManageStands then 
                manageButtonsEnabaled = false
                local originalText = Storage.Button_Store.Text
                Storage.Button_Store.Text = "GO TO STORAGE"
                wait(3)
                Storage.Button_Store.Text = originalText
                manageButtonsEnabaled = true
                return 
            end
            InventoryService:StoreStand()
        end

    end)

    Storage.Button_Sell.MouseButton1Down:Connect(function()
         if manageButtonsEnabaled then
            --if not canManageStands then return end
            Storage.Frame_ConfirmSell.Visible = true
         end
    end)

    -- setup sell confirmation
    Storage.Button_ConfirmSell_Yes.MouseButton1Down:Connect(function()
        if selectedStandData.GUID then
            InventoryService:SellStand(selectedStandData.GUID)
        end
    end)

    Storage.Button_ConfirmSell_No.MouseButton1Down:Connect(function()
        Storage.Frame_ConfirmSell.Visible = false
    end)

    Storage.Button_Close.MouseButton1Down:Connect(function()
        Storage.Close()
    end)

end

function Storage.Open()
    Knit.Controllers.GuiController:CloseAllWindows()
    Knit.Controllers.GuiController.CurrentWindow = "Storage"
    Storage.Frame.Visible = true
end

function Storage.Close()
    Knit.Controllers.GuiController:CloseAllWindows()
    Knit.Controllers.GuiController.CurrentWindow = nil
    Storage.Frame.Visible = false
end


--// Update ------------------------------------------------------------
function Storage.Update(currentStand, storageData, hasGamePass, isInZone)

    --print("Storage.Update", currentStand, storageData, hasGamePass, isInZone)

    -- set data
    selectedStandData = nil
    slotData = {}
    slotData.CurrentStand = currentStand
    slotData.StorageData = storageData

    Storage.Update_Access(hasGamePass, isInZone)

    Storage.Frame_StorageGrid.Visible = true
    Storage.Frame_ConfirmSell.Visible = false

    Storage.UpdateStandCard()

    -- remove all old stand icons
    for i, v in pairs(Storage.Frame_StorageGrid:GetDescendants()) do
        if v.Name == "StandIcon" then
            v:Destroy()
        end
    end

    -- handle the Equippped Stand button
    if currentStand.Power == "Standless" then
        Storage.StandSlot_Equipped.Frame_Icon.Textlabel_Standless.Visible = true
    else
        Storage.StandSlot_Equipped.Frame_Icon.Textlabel_Standless.Visible = false
        local iconName = currentStand.Power .. "_" .. tostring(currentStand.Rank)
        Storage.ShowStandIcon(iconName, Storage.StandSlot_Equipped.Frame_Icon)
    end

    -- handle storage buttons
    for count = 1, storageDefs.MaxSlots do -- there are 11 storage slots possible

        local thisGuiSlot = Storage.Frame_StorageGrid:FindFirstChild("StandSlot_" .. count, true)
        local lockedIcon = thisGuiSlot.Frame_Icon:FindFirstChild("Icon_Locked", true)

        if storageData.StoredStands[count] then
            local iconName = storageData.StoredStands[count].Power .. "_" .. tostring(storageData.StoredStands[count].Rank)
            Storage.ShowStandIcon(iconName, thisGuiSlot.Frame_Icon)
        end

        if count <= storageData.SlotsUnlocked then
            local countString = tostring(count)
            lockedIcon.Visible = false
            thisGuiSlot:SetAttribute("LockStatus", "Unlocked")
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

function Storage.Update_Access(hasGamePass, isInZone)

    if hasGamePass or isInZone then
        canManageStands = true
        --Storage.Frame_ManageStands_Cover.Visible = false
    else
        canManageStands = false
        --Storage.Frame_ManageStands_Cover.Visible = false
    end

end

--// SlotClicked
function Storage.SlotClicked(thisSlot)

    manageButtonsEnabaled = true

    -- start wth the card hidden
    Storage.Frame_StandCard.Visible = false
    Storage.Frame_ConfirmSell.Visible = false

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
        Storage.Button_Equip.Visible = false
        Storage.Button_Store.Visible = true
        --Storage.Button_Evolve.Visible = true
        Storage.Button_Sell.Visible = true
        selectedStandData = slotData.CurrentStand
    else
        local convertedSlotId = tonumber(slotId)
        Storage.Button_Equip.Visible = true
        Storage.Button_Store.Visible = false
        --Storage.Button_Evolve.Visible = true
        Storage.Button_Sell.Visible = true
        selectedStandData = slotData.StorageData.StoredStands[convertedSlotId]
    end

    Storage.UpdateStandCard()
end

--// ShowStandIcon
function Storage.ShowStandIcon(iconName, iconParent)

    local standIcon = mainGui.Stand_Icons:FindFirstChild(iconName)
    if standIcon then
        local newIcon = mainGui.Stand_Icons:FindFirstChild(iconName):Clone()
        newIcon.BorderSizePixel = 0
        newIcon.BackgroundColor3 = Color3.fromRGB(47, 47, 47)
        newIcon.Visible = true
        newIcon.Name = "StandIcon"
        newIcon.Parent = iconParent
    else 
        warn("GuiModule:Storage - Cannot find stand icon for GUI: ", iconName)
    end

end

--// UpdateStandCard
function Storage.UpdateStandCard()

    if selectedStandData == nil or selectedStandData.Power == "Standless" then
        Storage.Frame_StandCard.Visible = false
        return 
    end

    local showInfoCard = false
    if selectedStandData.GUID == slotData.CurrentStand.GUID then
        showInfoCard = true
    end

    for i, v in pairs(slotData.StorageData.StoredStands) do
        if v.GUID == selectedStandData.GUID then
            showInfoCard = true
        end
    end

    if showInfoCard == false then return end

    Storage.Frame_StandCard.Visible = true

    local powerModule = require(Knit.Shared.PowerModules.Powers[selectedStandData.Power])

    Storage.Frame_StandCard.Stand_Name.Text = powerModule.Defs.PowerName
    if selectedStandData.Rank == 1 then
        Storage.Star_1.Visible = true
        Storage.Star_2.Visible = false
        Storage.Star_3.Visible = false
    elseif selectedStandData.Rank == 2 then
        Storage.Star_1.Visible = true
        Storage.Star_2.Visible = true
        Storage.Star_3.Visible = false
    elseif selectedStandData.Rank == 3 then
        Storage.Star_1.Visible = true
        Storage.Star_2.Visible = true
        Storage.Star_3.Visible = true
    end


    -- destroy old icon
    local targetIconFrame = Storage.Frame_StandCard:FindFirstChild("Stand_Icon_Frame", true)
    for i, v in pairs(targetIconFrame:GetChildren()) do
        if v.Name == "StandIcon" then
            v:Destroy()
        end
    end

    -- set new icon
    local iconName = selectedStandData.Power .. "_" .. selectedStandData.Rank
    Storage.ShowStandIcon(iconName, targetIconFrame)

    -- set the Xp bar
    local maxExperience = powerModule.Defs.MaxXp
    Storage.Xp_Text.Text = selectedStandData.Xp .. " / " .. maxExperience
    local percent = selectedStandData.Xp / maxExperience
    Storage.Xp_Bar.Size = UDim2.new(percent, Storage.Xp_Bar.Size.X.Offset, Storage.Xp_Bar.Size.Y.Scale, Storage.Xp_Bar.Size.Y.Offset)

end


return Storage