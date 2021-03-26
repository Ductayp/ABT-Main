-- Arrow Panel
-- PDab
-- 1/2/2021

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local GamePassService = Knit.GetService("GamePassService")
local BoostService = Knit.GetService("BoostService")


-- utils
local utils = require(Knit.Shared.Utils)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)


local BoostPanel = {}

-- references
BoostPanel.Panel = mainGui.Windows:FindFirstChild("Boost_Panel", true)
BoostPanel.ListItem_DoubleExperience = BoostPanel.Panel:FindFirstChild("ListItem_DoubleExperience", true)
BoostPanel.ListItem_DoubleCash = BoostPanel.Panel:FindFirstChild("ListItem_DoubleCash", true)
BoostPanel.ListItem_DoubleSoulOrbs = BoostPanel.Panel:FindFirstChild("ListItem_DoubleSoulOrbs", true)
BoostPanel.ListItem_FastWalker = BoostPanel.Panel:FindFirstChild("ListItem_FastWalker", true)
BoostPanel.ListItem_ItemFinder = BoostPanel.Panel:FindFirstChild("ListItem_ItemFinder", true)

BoostPanel.InfoCard_TimeLeft = BoostPanel.Panel:FindFirstChild("InfoCard_TimeLeft", true)
BoostPanel.InfoCard_BoostName = BoostPanel.Panel:FindFirstChild("InfoCard_BoostName", true)
BoostPanel.InfoCard_Description = BoostPanel.Panel:FindFirstChild("InfoCard_Description", true)
BoostPanel.Button_Buy_Robux_1 = BoostPanel.Panel:FindFirstChild("Button_Buy_Robux_1", true)
BoostPanel.Button_Buy_Cash_1 = BoostPanel.Panel:FindFirstChild("Button_Buy_Cash_1", true)
BoostPanel.Button_Buy_Robux_2 = BoostPanel.Panel:FindFirstChild("Button_Buy_Robux_2", true)
BoostPanel.Button_Buy_Cash_2 = BoostPanel.Panel:FindFirstChild("Button_Buy_Cash_2", true)
BoostPanel.InfoCard_Buy_Pass = BoostPanel.Panel:FindFirstChild("InfoCard_Buy_Pass", true)

BoostPanel.Defs = require(Knit.Shared.Defs.BoostDefs)

local boostButtons = {
    DoubleExperience = BoostPanel.ListItem_DoubleExperience,
    DoubleCash = BoostPanel.ListItem_DoubleCash,
    DoubleSoulOrbs = BoostPanel.ListItem_DoubleSoulOrbs,
    FastWalker = BoostPanel.ListItem_FastWalker,
    ItemFinder = BoostPanel.ListItem_ItemFinder,
}



local timerText_Green = Color3.fromRGB(16, 214, 46)
local timerText_Red = Color3.fromRGB(255, 2, 6)

local boostData = {} -- this is set from the Update function, it contains the latest updated information about boost timers
local currentBoostKey



--// Setup ------------------------------------------------------------
function BoostPanel.Setup()

    BoostPanel.InfoCard_Buy_Pass.Visible = false
    BoostPanel.Update_InfoCard("DoubleExperience")

    --BoostPanel.Button_Buy_Cash_1.Cash_Price.Text = BoostPanel.Defs.
    
    -- list item buttons
    BoostPanel.ListItem_DoubleExperience.MouseButton1Down:Connect(function()
        BoostPanel.Update_InfoCard("DoubleExperience")
    end)

    BoostPanel.ListItem_DoubleCash.MouseButton1Down:Connect(function()
        BoostPanel.Update_InfoCard("DoubleCash")
    end)

    BoostPanel.ListItem_DoubleSoulOrbs.MouseButton1Down:Connect(function()
        BoostPanel.Update_InfoCard("DoubleSoulOrbs")
    end)

    BoostPanel.ListItem_FastWalker.MouseButton1Down:Connect(function()
        BoostPanel.Update_InfoCard("FastWalker")
    end)

    BoostPanel.ListItem_ItemFinder.MouseButton1Down:Connect(function()
        BoostPanel.Update_InfoCard("ItemFinder")
    end)

    -- dev product buy buttons
    BoostPanel.Button_Buy_Robux_1.MouseButton1Down:Connect(function()
        if currentBoostKey ~= nil then
            BoostService:BuyBoost("Robux", currentBoostKey, "1")
        end
    end)

    BoostPanel.Button_Buy_Robux_2.MouseButton1Down:Connect(function()
        if currentBoostKey ~= nil then
            BoostService:BuyBoost("Robux", currentBoostKey, "2")
        end
    end)

    BoostPanel.Button_Buy_Cash_1.MouseButton1Down:Connect(function()
        if currentBoostKey ~= nil then
            BoostService:BuyBoost("Cash", currentBoostKey, "1")
        end
    end)

    BoostPanel.Button_Buy_Cash_2.MouseButton1Down:Connect(function()
        if currentBoostKey ~= nil then
            BoostService:BuyBoost("Cash", currentBoostKey, "2")
        end
    end)

    BoostPanel.InfoCard_Buy_Pass.MouseButton1Down:Connect(function()
        GamePassService:Prompt_GamePassPurchase("ItemFinder")
    end)



end

function BoostPanel.UpdateTimer()

    if not boostData then
        return
    end

    for _, boostDef in pairs(boostData) do
        local thisListItem = boostButtons[boostDef.BoostName]
        local timerText = thisListItem:FindFirstChild("Time_Remaining", true)
        if timerText then
            if boostDef.TimeEnding - os.time() > 0 then
                timerText.TextColor3 = timerText_Green
                timerText.Text = utils.ConvertToHMS(boostDef.TimeEnding - os.time())
            else
                timerText.TextColor3 = timerText_Red
                timerText.Text = utils.ConvertToHMS(0)
            end
        end
    end
end

--// Update ------------------------------------------------------------
function BoostPanel.Update(data)
    boostData = data
end

--// UpdateInfoCard ------------------------------------------------------------
function BoostPanel.Update_InfoCard(boostKey)

    currentBoostKey = boostKey

    BoostPanel.InfoCard_BoostName.Text = BoostPanel.Defs[boostKey].Name
    BoostPanel.InfoCard_Description.Text = BoostPanel.Defs[boostKey].Description

    if boostKey == "ItemFinder" then

        BoostPanel.Button_Buy_Robux_1.Visible = false
        BoostPanel.Button_Buy_Cash_1.Visible = false 
        BoostPanel.Button_Buy_Robux_2.Visible = false 
        BoostPanel.Button_Buy_Cash_2.Visible = false 
        BoostPanel.InfoCard_Buy_Pass.Visible = true
    else
        BoostPanel.Button_Buy_Robux_1.Visible = true
        BoostPanel.Button_Buy_Cash_1.Visible = true 
        BoostPanel.Button_Buy_Robux_2.Visible = true
        BoostPanel.Button_Buy_Cash_2.Visible = true 
        BoostPanel.InfoCard_Buy_Pass.Visible = false
    end

end

return BoostPanel