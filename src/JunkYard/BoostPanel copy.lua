-- Arrow Panel
-- PDab
-- 1/2/2021

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local BoostService = Knit.GetService("BoostService")


-- utils
local utils = require(Knit.Shared.Utils)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui_OLD", 120)


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
BoostPanel.InfoCard_BoostOn = BoostPanel.Panel:FindFirstChild("InfoCard_BoostOn", true)
BoostPanel.InfoCard_BoostOff = BoostPanel.Panel:FindFirstChild("InfoCard_BoostOff", true)
BoostPanel.InfoCard_Buy50 = BoostPanel.Panel:FindFirstChild("InfoCard_Buy50", true)
BoostPanel.InfoCard_Buy100 = BoostPanel.Panel:FindFirstChild("InfoCard_Buy100", true)

BoostPanel.Button_AllOn = BoostPanel.Panel:FindFirstChild("Button_AllOn", true)
BoostPanel.Button_AllOff = BoostPanel.Panel:FindFirstChild("Button_AllOff", true)

--[[
-- a table to hold some simple connections used in updating the panel
local listItemConnections = {
    DoubleExperience = BoostPanel.ListItem_DoubleExperience,
    DoubleCash = BoostPanel.ListItem_DoubleCash,
    DoubleSoulOrbs = BoostPanel.ListItem_DoubleSoulOrbs,
    FastWalker = BoostPanel.ListItem_FastWalker,
    ItemFinder = BoostPanel.ListItem_ItemFinder
}
]]--

BoostPanel.Defs = {
    DoubleExperience = {
        Name = "2x Experience",
        Description = "Double stand experience. Stacks with Gamepass.",
        Button = BoostPanel.ListItem_DoubleExperience
    },

    DoubleCash = {
        Name = "2x Cash",
        Description = "Double your money! Stacks with Gamepass.",
        Button = BoostPanel.ListItem_DoubleCash
    },

    DoubleSoulOrbs = {
        Name = "2x Soul Orbs",
        Description = "Double your money! Stacks with Gamepass.",
        Button = BoostPanel.ListItem_DoubleSoulOrbs
    },

    FastWalker = {
        Name = "Fast Walker",
        Description = "+5 Walkspeed. Stacks with your stand bonus.",
        Button = BoostPanel.ListItem_FastWalker
    },

    ItemFinder = {
        Name = "Item Finder",
        Description = "You can use the item finder. If you have the Gamepass then this wont work.",
        Button = BoostPanel.ListItem_ItemFinder
    },
}

local timerText_Green = Color3.fromRGB(16, 214, 46)
local timerText_Red = Color3.fromRGB(255, 2, 6)

local boostData = {} -- this is set from the Update function, it contains the latest updated information about boost timers
local currentBoostKey



--// Setup ------------------------------------------------------------
function BoostPanel.Setup()
    
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

    -- infocard boost toggles
    BoostPanel.InfoCard_BoostOn.MouseButton1Down:Connect(function()
        BoostService:ToggleBoost(currentBoostKey, true)
    end)

    BoostPanel.InfoCard_BoostOff.MouseButton1Down:Connect(function()
        BoostService:ToggleBoost(currentBoostKey, false)
    end)

    -- toggle all buttons
    BoostPanel.Button_AllOn.MouseButton1Down:Connect(function()
        for boostKey,_ in pairs(BoostPanel.Defs) do
            BoostService:ToggleBoost(oostKey, true)
        end
    end)

    BoostPanel.Button_AllOff.MouseButton1Down:Connect(function()
        for boostKey,_ in pairs(BoostPanel.Defs) do
            BoostService:ToggleBoost(oostKey, true)
        end
    end)

    -- dev product buy buttons
    BoostPanel.InfoCard_Buy50.MouseButton1Down:Connect(function()
        
    end)

    BoostPanel.InfoCard_Buy100.MouseButton1Down:Connect(function()
        
    end)

end

function BoostPanel.UpdateTimer()

    for _, boostDef in pairs(boostData) do

        local thisListItem = BoostPanel.Defs[boostDef.BoostName].Button
        local timerText = thisListItem:FindFirstChild("Time_Remaining", true)
        if timerText then

            if boostDef.TimerState == "Running" then

                timerText.TextColor3 = timerText_Green

                if boostDef.TimeEnding - os.time() > 0 then
                    timerText.Text = utils.ConvertToHMS(boostDef.TimeEnding - os.time())
                else
                    timerText.Text = utils.ConvertToHMS(0)
                end
            else
                timerText.TextColor3 = timerText_Red
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

    BoostPanel.InfoCard_BoostName.Text = BoostPanel.Defs[boostKey].Name
    BoostPanel.InfoCard_Description.Text = BoostPanel.Defs[boostKey].Description

    currentBoostKey = boostKey

end

return BoostPanel