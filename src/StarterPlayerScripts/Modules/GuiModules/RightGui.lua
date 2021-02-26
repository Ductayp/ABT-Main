--Left Gui
-- PDab
-- 1/4/2021

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)

local RightGui = {}

RightGui.PVP_Button = mainGui.RightGui:FindFirstChild("PVP_Button", true)
RightGui.ItemFinder_Button = mainGui.RightGui:FindFirstChild("ItemFinder_Button", true)
RightGui.Settings_Button = mainGui.RightGui:FindFirstChild("Settings_Button", true)

local currentWindow = nil

--// Setup_RightGui() ------------------------------------------------------------
function RightGui.Setup()

    -- PvP button
    RightGui.PVP_Button.MouseButton1Down:Connect(function()
        if not Knit.Controllers.GuiController.InDialogue then

        end
    end)

    -- item finder button
    RightGui.ItemFinder_Button.MouseButton1Down:Connect(function()
        print("Beep")
        if not Knit.Controllers.GuiController.InDialogue then
            if Knit.Controllers.GuiController.CurrentWindow == "ItemFinderWindow" then
                Knit.Controllers.GuiController.ItemFinderWindow.Close()
                Knit.Controllers.GuiController.CurrentWindow = nil
            else
                Knit.Controllers.GuiController:CloseAllWindows()
                Knit.Controllers.GuiController.ItemFinderWindow.Open()
                Knit.Controllers.GuiController.CurrentWindow = "ItemFinderWindow"
            end
        end
    end)

    -- settins window button
    RightGui.Settings_Button.MouseButton1Down:Connect(function()
        if not Knit.Controllers.GuiController.InDialogue then
            if Knit.Controllers.GuiController.CurrentWindow == "SettingsWindow" then
                Knit.Controllers.GuiController.SettingsWindow.Close()
                Knit.Controllers.GuiController.CurrentWindow = nil
            else
                Knit.Controllers.GuiController:CloseAllWindows()
                Knit.Controllers.GuiController.SettingsWindow.Open()
                Knit.Controllers.GuiController.CurrentWindow = "SettingsWindow"
            end
        end
    end)

end




return RightGui