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


                   
--// Setup_StandPanel ------------------------------------------------------------
function StoragePanel.Setup()
                          
end


--// Update_StandPanel ------------------------------------------------------------
function StoragePanel.Update(currentStand, storageData)

    print("StoragePanel.Textlabel_Standless", StoragePanel.Textlabel_Standless)

    print("StoragePanel.Update", currentStand, storageData)

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


end



return StoragePanel