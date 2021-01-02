-- Sacrifice PopUp
-- PDab
-- 1/2/2021

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")


-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)

local SacrificePopUp = {}

SacrificePopUp.Defs = {}
SacrificePopUp.Defs.Frame = mainGui:FindFirstChild("SacrificePopUp", true)
SacrificePopUp.Defs.StandName = mainGui:FindFirstChild("Stand_Name", true)
SacrificePopUp.Defs.StandLevel = mainGui:FindFirstChild("Stand_Level", true)
SacrificePopUp.Defs.BaseValue = mainGui:FindFirstChild("Base_Value", true)
SacrificePopUp.Defs.TotalValue = mainGui:FindFirstChild("Total_Value", true)
SacrificePopUp.Defs.Button_DoubleOrbsPass = mainGui:FindFirstChild("Button_DoubleOrbsPass", true)
SacrificePopUp.Defs.Button_Cancel = mainGui:FindFirstChild("Button_Cancel", true)
SacrificePopUp.Defs.Button_Sacrifice = mainGui:FindFirstChild("Button_Sacrifice", true)

-- this gets set by the Update function
SacrificePopUp.standCardGUID

--// Setup
function SacrificePopUp.Setup()
    SacrificePopUp.Defs.Frame.Visible = false

    -- Button - DoubleOrbsPass
    SacrificePopUp.Defs.Button_DoubleOrbsPass.Activated:Connect(function()
        GamePassService:Prompt_GamePassPurchase("DoubleOrbs")
    end)

    -- Button - Cancel
    SacrificePopUp.Defs.Button_Cancel.Activated:Connect(function()
        SacrificePopUp.Defs.Frame.Visible = false
    end)

    -- Button - Sacrifice
    SacrificePopUp.Defs.Button_Sacrifice.Activated:Connect(function()
        InventoryService:SacrificeStand(standCardGUID) -- send the GUID of the stand shown on the stand card
    end)

end

--// Updare
function SacrificePopUp.Update(standData)

end


return SacrificePopUp