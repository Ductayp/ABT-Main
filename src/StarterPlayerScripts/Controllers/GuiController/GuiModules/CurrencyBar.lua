-- Bottom Gui
-- PDab
-- 1/2/2021

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")


-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui_OLD", 120)

local CurrencyBar = {}
CurrencyBar.Frame = mainGui.TopGui:FindFirstChild("CurrencyFrame", true)
CurrencyBar.Frame_Cash = CurrencyBar.Frame:FindFirstChild("Frame_Cash", true)
CurrencyBar.Frame_SoulOrbs = CurrencyBar.Frame:FindFirstChild("Frame_SoulOrbs", true)
CurrencyBar.Text_Cash = CurrencyBar.Frame:FindFirstChild("Text_Cash", true)
CurrencyBar.Text_SoulOrbs = CurrencyBar.Frame:FindFirstChild("Text_SoulOrbs", true)


--// Setup ------------------------------------------------------------
function CurrencyBar.Setup()

end

--// Update ------------------------------------------------------------
function CurrencyBar.Update(data)

    if utils.CommaValue(data.Cash) ~= CurrencyBar.Text_Cash.Text then
        if data.Cash < 1 then
            CurrencyBar.Text_Cash.Text = data.Cash
        else
            spawn(function()
                for count = 1, 5 do
                    local rand = math.random(1, data.Cash)
                    CurrencyBar.Text_Cash.Text = utils.CommaValue(rand)
                    wait(.02)
                end
                CurrencyBar.Text_Cash.Text = utils.CommaValue(data.Cash)
            end)

            spawn(function()
                for count = 1, 3 do
                    CurrencyBar.Frame_Cash.BackgroundColor3 = Color3.fromRGB(57,57,57)
                    wait(.3)
                    CurrencyBar.Frame_Cash.BackgroundColor3 = Color3.fromRGB(0,0,0)
                    wait(.3)
                end
            end)
        end
    end

    if utils.CommaValue(data.SoulOrbs) ~= CurrencyBar.Text_SoulOrbs.Text then
        if data.SoulOrbs < 1 then
            CurrencyBar.Text_SoulOrbs.Text = data.SoulOrbs
        else
            spawn(function()
                for count = 1, 5 do
                    local rand = math.random(1, data.SoulOrbs)
                    CurrencyBar.Text_SoulOrbs.Text = utils.CommaValue(rand)
                    wait(.02)
                end
                CurrencyBar.Text_SoulOrbs.Text = utils.CommaValue(data.SoulOrbs)
            end)

            spawn(function()
                for count = 1, 3 do
                    CurrencyBar.Frame_SoulOrbs.BackgroundColor3 = Color3.fromRGB(57,57,57)
                    wait(.3)
                    CurrencyBar.Frame_SoulOrbs.BackgroundColor3 = Color3.fromRGB(0,0,0)
                    wait(.3)
                end
            end)
        end
    end

end

return CurrencyBar