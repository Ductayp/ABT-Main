-- Bottom Gui
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

local BottomGui = {}

BottomGui.Current_Power = mainGui.BottomGui:FindFirstChild("Current_Power", true)

--// Setup ------------------------------------------------------------
function BottomGui.Setup()

    --local mainGui = Players.LocalPlayer.PlayerGui:WaitForChild("MainGui")
    local powerButtonFrame = mainGui:FindFirstChild("PowerButtons",true)

    for _,button in pairs(powerButtonFrame:GetDescendants()) do
        if button:IsA("TextButton") then
            button.Activated:Connect(function()
                Knit.Controllers.InputController:SendToPowersService({InputId = button.Name, KeyState = "InputBegan"})
            end)
        end
    end
end

--// Update ------------------------------------------------------------
function BottomGui.Update(data)
    BottomGui.Current_Power.Text = data.Power
end

function BottomGui.HidePower()
    BottomGui.Current_Power.Visible = false
end

function BottomGui.ShowPower()
    BottomGui.Current_Power.Visible = true
end



return BottomGui