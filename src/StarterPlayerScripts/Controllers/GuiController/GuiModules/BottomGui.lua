-- Bottom Gui
-- PDab
-- 1/2/2021

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

-- modules
local utils = require(Knit.Shared.Utils)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)

local BottomGui = {}

BottomGui.Frame_Main = mainGui:FindFirstChild("BottomGui", true)
BottomGui.Text_Ping = BottomGui.Frame_Main:FindFirstChild("Text_Ping", true)


-- Constants
local EMPTY_COOLDOWN_SIZE = UDim2.new(1,0,0,0)
local FULL_COOLDOWN_SIZE = UDim2.new(1,0,1,0)


--// Setup ------------------------------------------------------------
function BottomGui.Setup()

    -- connect the ping
    local pingValue = ReplicatedStorage.PlayerPings:WaitForChild(Players.LocalPlayer.UserId)
    pingValue.Changed:Connect(function()
        local roundedNumber = tonumber(string.format("%." .. (3 or 0) .. "f", pingValue.Value))
        --print(roundedNumber)
        BottomGui.Text_Ping.Text = tostring(roundedNumber)
    end)

end

--// Update ------------------------------------------------------------
function BottomGui.Update(data, params)
    
    --print("BottomGui.Update", data)

end


return BottomGui