-- Arrow Panel
-- PDab
-- 1/2/2021

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local InventoryService = Knit.GetService("InventoryService")
local PowersService = Knit.GetService("PowersService")

-- utils
local utils = require(Knit.Shared.Utils)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)


local ItemPanel = {}

ItemPanel.Panel = mainGui.Windows:FindFirstChild("Item_Panel", true)

--// Setup_ItemPanel ------------------------------------------------------------
function ItemPanel.Setup()
    ItemPanel.Item_Template.Visible = false
end

--// Update_ItemPanel ------------------------------------------------------------
function ItemPanel.Update(data)

end

--// Request_UseArrow ------------------------------------------------------------
function ItemPanel.Request_UseArrow(params,button)

end


return ItemPanel