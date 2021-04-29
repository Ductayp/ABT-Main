--Left Gui
-- PDab
-- 1/4/2021

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local GuiService = Knit.GetService("GuiService")
local utils = require(Knit.Shared.Utils)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)

local RightGui = {}

RightGui.PVP_Button = mainGui.RightGui:FindFirstChild("PVP_Button", true)
RightGui.ItemFinder_Button = mainGui.RightGui:FindFirstChild("ItemFinder_Button", true)
RightGui.Settings_Button = mainGui.RightGui:FindFirstChild("Settings_Button", true)

RightGui.PVP_TOGGLE_TEXT = RightGui.PVP_Button:FindFirstChild("PVP_TOGGLE_TEXT", true)
RightGui.PVP_OUTER_FRAME = mainGui.RightGui:FindFirstChild("PVP_OUTER_FRAME", true)
RightGui.Label_2XExpereince = mainGui.RightGui:FindFirstChild("Label_2XExpereince", true)
RightGui.CantUse_Warning = mainGui.RightGui:FindFirstChild("CantUse_Warning", true)

local color_Green = Color3.fromRGB(16, 214, 46)
local color_Red = Color3.fromRGB(255, 2, 6)

local currentWindow = nil

--// Setup_RightGui() ------------------------------------------------------------
function RightGui.Setup()

    RightGui.CantUse_Warning.Visible = false

    -- PvP button
    RightGui.PVP_Button.MouseButton1Down:Connect(function()
        if not Knit.Controllers.GuiController.InDialogue then
            GuiService:TogglePvP()
        end
    end)

    -- item finder button
    RightGui.ItemFinder_Button.MouseButton1Down:Connect(function()
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

function RightGui.Update(pvpToggle, params)

    --print("RIGHT GUI Update", pvpToggle, params)

    if pvpToggle == true then
        RightGui.PVP_TOGGLE_TEXT.Text = "ON"
        RightGui.PVP_TOGGLE_TEXT.TextColor3 = color_Green
        RightGui.PVP_OUTER_FRAME.BackgroundColor3 = color_Green
        RightGui.Label_2XExpereince.Visible = true
    else
        RightGui.PVP_TOGGLE_TEXT.Text = "OFF"
        RightGui.PVP_TOGGLE_TEXT.TextColor3 = color_Red
        RightGui.PVP_OUTER_FRAME.BackgroundColor3 = color_Red
        RightGui.Label_2XExpereince.Visible = false
    end

    if params then
        if not params.CanToggle then
            spawn(function()
                RightGui.CantUse_Warning.Visible = true
                wait(3)
                RightGui.CantUse_Warning.Visible = false
            end)
        end
    end

end




return RightGui