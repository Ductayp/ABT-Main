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
local evolveRank_DefaultText = "UPGRADE RANK"

local StoragePanel = {}

-- variables
StoragePanel.EvolutionAction = nil -- gets set when a user clicks evolutions
StoragePanel.StandCardGUID = nil -- this gets set when a player clicks a stand button to show a stand card. Its used in buttons to send the viewed stand for actions

--// DEFS - Storage PANEL ------------------------------------------------------------
StoragePanel.Stand_Icons = mainGui.Stand_Icons

StoragePanel.Panel = mainGui.Windows:FindFirstChild("Storage_Panel", true)
StoragePanel.Frame_StorageGrid = StoragePanel.Panel:FindFirstChild("Frame_StorageGrid", true)
StoragePanel.StandSlot_Equipped = StoragePanel.Panel:FindFirstChild("StandSlot_Equipped", true)
StoragePanel.Textlabel_Standless = StoragePanel.Panel:FindFirstChild("Textlabel_Standless", true)
StoragePanel.Icon_Locked = StoragePanel.Panel:FindFirstChild("Icon_Locked", true)

-- stand management buttons
StoragePanel.Button_Equip = StoragePanel.Panel:FindFirstChild("Button_Equip", true)
StoragePanel.Button_Sell = StoragePanel.Panel:FindFirstChild("Button_Sell", true)
StoragePanel.Button_Store = StoragePanel.Panel:FindFirstChild("Button_Store", true)
StoragePanel.Button_Evolve = StoragePanel.Panel:FindFirstChild("Button_Evolve", true)

-- mobile storage stuff
StoragePanel.Button_Buy_MobileStorage = StoragePanel.Panel:FindFirstChild("Button_Buy_MobileStorage", true)
StoragePanel.Frame_ManageStands_Cover = StoragePanel.Panel:FindFirstChild("Frame_ManageStands_Cover", true)

-- stand card stuff
StoragePanel.Stand_Card = StoragePanel.Panel:FindFirstChild("Stand_Card", true)
StoragePanel.Frame_XP = StoragePanel.Panel:FindFirstChild("Frame_XP", true)
StoragePanel.Xp_Bar = StoragePanel.Panel:FindFirstChild("Xp_Bar", true)
StoragePanel.Xp_Text = StoragePanel.Panel:FindFirstChild("Xp_Text", true)

-- evolve panel stuff
StoragePanel.Frame_Evolve = StoragePanel.Panel:FindFirstChild("Frame_Evolve", true)
StoragePanel.Frame_ConfirmEvolve = StoragePanel.Panel:FindFirstChild("Frame_ConfirmEvolve", true)
StoragePanel.Button_ConfirmEvolve_Yes = StoragePanel.Panel:FindFirstChild("Button_ConfirmEvolve_Yes", true)
StoragePanel.Button_ConfirmEvolve_No = StoragePanel.Panel:FindFirstChild("Button_ConfirmEvolve_No", true)
StoragePanel.Button_RankUpgrade = StoragePanel.Panel:FindFirstChild("Button_RankUpgrade", true)

-- confirm sell stuff
StoragePanel.Frame_ConfirmSell = StoragePanel.Panel:FindFirstChild("Frame_ConfirmSell", true)
StoragePanel.Button_ConfirmSell_Yes = StoragePanel.Panel:FindFirstChild("Button_ConfirmSell_Yes", true)
StoragePanel.Button_ConfirmSell_No = StoragePanel.Panel:FindFirstChild("Button_ConfirmSell_No", true)

--local variables
local storageDefs = require(Knit.Defs.StandStorageDefs)
local slotData
local selectedStandData
local canManageStands

--// Setup ------------------------------------------------------------
function StoragePanel.Setup()

    StoragePanel.Icon_Locked.Visible = false
    StoragePanel.Frame_ManageStands_Cover.Visible = true
    StoragePanel.Button_Equip.Visible = false
    StoragePanel.Button_Sell.Visible = false
    StoragePanel.Button_Store.Visible = false
    StoragePanel.Stand_Card.Visible = false
    StoragePanel.Frame_ConfirmSell.Visible = false
    StoragePanel.Frame_Evolve.Visible = false
    StoragePanel.Frame_ConfirmEvolve.Visible = false

    -- setup the storage slots
    for slotNumber, slotCost in pairs(storageDefs.SlotCosts) do
        local thisGuiSlot = StoragePanel.Frame_StorageGrid:FindFirstChild("StandSlot_" .. slotNumber, true)
        local lockedIcon = thisGuiSlot.Frame_Icon:FindFirstChild("Icon_Locked", true)
        local convertNumber = utils.CommaValue(slotCost)
        lockedIcon.TextLabel_SlotCost.Text = convertNumber .. "<br/>Cash"
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
       
    -- setup stand manage buttons
    StoragePanel.Button_Equip.MouseButton1Down:Connect(function()
        if not canManageStands then return end
        if selectedStandData.GUID then
            InventoryService:EquipStand(selectedStandData.GUID)
        end
    end)

    StoragePanel.Button_Evolve.MouseButton1Down:Connect(function()
        if not canManageStands then return end
        StoragePanel.Frame_Evolve.Visible = true
        StoragePanel.Frame_ConfirmEvolve.Visible = true
        StoragePanel.Frame_StorageGrid.Visible = false
    end)

    StoragePanel.Button_Store.MouseButton1Down:Connect(function()
        if not canManageStands then return end
        InventoryService:StoreStand()
    end)

    StoragePanel.Button_Sell.MouseButton1Down:Connect(function()
        if not canManageStands then return end
        StoragePanel.Frame_ConfirmSell.Visible = true
    end)

    -- setup evolution options
    StoragePanel.Button_RankUpgrade.MouseButton1Down:Connect(function()
        StoragePanel.SetEvolutionAction("RankUpgrade", StoragePanel.Button_RankUpgrade)
    end)

    -- setup evolution confirms
    StoragePanel.Button_ConfirmEvolve_Yes.MouseButton1Down:Connect(function()
        StoragePanel.ConfirmEvolutionAction()
    end)

    StoragePanel.Button_ConfirmEvolve_No.MouseButton1Down:Connect(function()
        StoragePanel.CancelEvolutionAction()
    end)

    -- setup sell confirmation
    StoragePanel.Button_ConfirmSell_Yes.MouseButton1Down:Connect(function()
        if selectedStandData.GUID then
            InventoryService:SellStand(selectedStandData.GUID)
        end
    end)

    StoragePanel.Button_ConfirmSell_No.MouseButton1Down:Connect(function()
        StoragePanel.Frame_ConfirmSell.Visible = false
    end)

    -- buy moble storage button
    StoragePanel.Button_Buy_MobileStorage.MouseButton1Down:Connect(function()
        GamePassService:Prompt_GamePassPurchase("MobileStandStorage")
    end)
end


--// Update ------------------------------------------------------------
function StoragePanel.Update(currentStand, storageData, hasGamePass, isInZone)

    --print("StoragePanel.Update", currentStand, storageData, hasGamePass, isInZone)

    -- set data
    selectedStandData = nil
    slotData = {}
    slotData.CurrentStand = currentStand
    slotData.StorageData = storageData

    StoragePanel.Update_Access(hasGamePass, isInZone)

    StoragePanel.Frame_Evolve.Visible = false
    StoragePanel.Frame_StorageGrid.Visible = true
    StoragePanel.Frame_ConfirmEvolve.Visible = false
    StoragePanel.Frame_ConfirmSell.Visible = false

    StoragePanel.UpdateStandCard()

    -- remove all old stand icons
    for i, v in pairs(StoragePanel.Frame_StorageGrid:GetDescendants()) do
        if v.Name == "StandIcon" then
            v:Destroy()
        end
    end

    -- handle the Equippped Stand button
    if currentStand.Power == "Standless" then
        StoragePanel.StandSlot_Equipped.Frame_Icon.Textlabel_Standless.Visible = true
    else
        StoragePanel.StandSlot_Equipped.Frame_Icon.Textlabel_Standless.Visible = false
        local iconName = currentStand.Power .. "_" .. tostring(currentStand.Rank)
        StoragePanel.ShowStandIcon(iconName, StoragePanel.StandSlot_Equipped.Frame_Icon)
    end

    -- handle storage buttons
    for count = 1, storageDefs.MaxSlots do -- there are 11 storage slots possible

        local thisGuiSlot = StoragePanel.Frame_StorageGrid:FindFirstChild("StandSlot_" .. count, true)
        local lockedIcon = thisGuiSlot.Frame_Icon:FindFirstChild("Icon_Locked", true)

        if storageData.StoredStands[count] then
            local iconName = storageData.StoredStands[count].Power .. "_" .. tostring(storageData.StoredStands[count].Rank)
            StoragePanel.ShowStandIcon(iconName, thisGuiSlot.Frame_Icon)
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

function StoragePanel.Update_Access(hasGamePass, isInZone)

    if hasGamePass or isInZone then
        canManageStands = true
        StoragePanel.Frame_ManageStands_Cover.Visible = false
    else
        canManageStands = false
        StoragePanel.Frame_ManageStands_Cover.Visible = true
    end

end

--// SlotClicked
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
        StoragePanel.Button_Evolve.Visible = true
        StoragePanel.Button_Sell.Visible = true
        selectedStandData = slotData.CurrentStand
    else
        local convertedSlotId = tonumber(slotId)
        StoragePanel.Button_Equip.Visible = true
        StoragePanel.Button_Store.Visible = false
        StoragePanel.Button_Evolve.Visible = true
        StoragePanel.Button_Sell.Visible = true
        selectedStandData = slotData.StorageData.StoredStands[convertedSlotId]
    end

    StoragePanel.UpdateStandCard()
end

--// ShowStandIcon
function StoragePanel.ShowStandIcon(iconName, iconParent)

    local newIcon = mainGui.Stand_Icons:FindFirstChild(iconName):Clone()
    newIcon.BorderSizePixel = 0
    newIcon.BackgroundColor3 = Color3.fromRGB(47, 47, 47)
    newIcon.Visible = true
    newIcon.Name = "StandIcon"
    newIcon.Parent = iconParent

end

--// UpdateStandCard
function StoragePanel.UpdateStandCard()

    if selectedStandData == nil or selectedStandData.Power == "Standless" then
        StoragePanel.Stand_Card.Visible = false
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

    StoragePanel.Stand_Card.Visible = true

    local powerModule = require(Knit.Shared.PowerModules.Powers[selectedStandData.Power])

    StoragePanel.Stand_Card.Stand_Name.Text = powerModule.Defs.PowerName
    if selectedStandData.Rank == 1 then
        StoragePanel.Stand_Card.Stand_Rank.star_1.Visible = true
        StoragePanel.Stand_Card.Stand_Rank.star_2.Visible = false
        StoragePanel.Stand_Card.Stand_Rank.star_3.Visible = false
    elseif selectedStandData.Rank == 2 then
        StoragePanel.Stand_Card.Stand_Rank.star_1.Visible = true
        StoragePanel.Stand_Card.Stand_Rank.star_2.Visible = true
        StoragePanel.Stand_Card.Stand_Rank.star_3.Visible = false
    elseif selectedStandData.Rank == 3 then
        StoragePanel.Stand_Card.Stand_Rank.star_1.Visible = true
        StoragePanel.Stand_Card.Stand_Rank.star_2.Visible = true
        StoragePanel.Stand_Card.Stand_Rank.star_3.Visible = true
    end


    -- destroy old icon
    local targetIconFrame = StoragePanel.Stand_Card:FindFirstChild("Stand_Icon_Frame", true)
    for i, v in pairs(targetIconFrame:GetChildren()) do
        if v.Name == "StandIcon" then
            v:Destroy()
        end
    end

    -- set new icon
    local iconName = selectedStandData.Power .. "_" .. selectedStandData.Rank
    StoragePanel.ShowStandIcon(iconName, targetIconFrame)

    -- set the Xp bar
    local maxExperience = powerModule.Defs.MaxXp[selectedStandData.Rank]
    StoragePanel.Xp_Text.Text = selectedStandData.Xp .. " / " .. maxExperience
    local percent = selectedStandData.Xp / maxExperience
    StoragePanel.Xp_Bar.Size = UDim2.new(percent, StoragePanel.Xp_Bar.Size.X.Offset, StoragePanel.Xp_Bar.Size.Y.Scale, StoragePanel.Xp_Bar.Size.Y.Offset)

end


--// SetEvolutionAction
function StoragePanel.SetEvolutionAction(actionName, buttonObject)

    if buttonObject.BackgroundColor3 == TOGGLE_COLOR.On then
        buttonObject.BackgroundColor3 = TOGGLE_COLOR.Off
        StoragePanel.EvolutionAction = nil
    else
        buttonObject.BackgroundColor3 = TOGGLE_COLOR.On
        StoragePanel.EvolutionAction = actionName
    end
end

--// ConfirmEvolutionAction
function StoragePanel.ConfirmEvolutionAction()
    local result
    if selectedStandData.GUID and StoragePanel.EvolutionAction then
        if StoragePanel.EvolutionAction == "RankUpgrade" then
            result = InventoryService:UpgradeStandRank(selectedStandData.GUID)
        end
    end

    if result == "NoExperience" then
        StoragePanel.Button_RankUpgrade.Text = "Not Enough XP"
        StoragePanel.Button_RankUpgrade.BackgroundColor3 = TOGGLE_COLOR.Fail
        wait(3)
        StoragePanel.Button_RankUpgrade.Text = evolveRank_DefaultText
        StoragePanel.Button_RankUpgrade.BackgroundColor3 = TOGGLE_COLOR.Off
        StoragePanel.EvolutionAction = nil
        return
    end

    if result == "CantAfford" then
        StoragePanel.Button_RankUpgrade.Text = "Not Enough Soul Orbs"
        StoragePanel.Button_RankUpgrade.BackgroundColor3 = TOGGLE_COLOR.Fail
        wait(3)
        StoragePanel.Button_RankUpgrade.Text = evolveRank_DefaultText
        StoragePanel.Button_RankUpgrade.BackgroundColor3 = TOGGLE_COLOR.Off
        StoragePanel.EvolutionAction = nil
        return
    end

    StoragePanel.Button_RankUpgrade.BackgroundColor3 = TOGGLE_COLOR.Off
    StoragePanel.EvolutionAction = nil

end

--// CancelEvolutionAction
function StoragePanel.CancelEvolutionAction()

    StoragePanel.Frame_Evolve.Visible = false
    StoragePanel.Frame_ConfirmEvolve.Visible = false
    StoragePanel.Frame_StorageGrid.Visible = true

    StoragePanel.Button_RankUpgrade.BackgroundColor3 = TOGGLE_COLOR.Off
    StoragePanel.EvolutionAction = nil

end


return StoragePanel