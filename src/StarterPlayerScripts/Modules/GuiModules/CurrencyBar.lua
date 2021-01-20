-- Bottom Gui
-- PDab
-- 1/2/2021

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")


-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)

local CashBar = {}

CashBar.Frame = mainGui.TopGui:FindFirstChild("CurrencyFrame", true)
CashBar.Text_Cash = CashBar.Frame:FindFirstChild("Text_Cash", true)
CashBar.Text_SoulOrbs = CashBar.Frame:FindFirstChild("Text_SoulOrbs", true)

--// Setup ------------------------------------------------------------
function CashBar.Setup()

end

--// Update ------------------------------------------------------------
function CashBar.Update(data)
    CashBar.Text_Cash.Text = data.Cash
    CashBar.Text_SoulOrbs.Text = data.SoulOrbs
end

return CashBar