--LeftGui

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

local LeftGui = {}

LeftGui.Menu_Button = mainGui.LeftGui:FindFirstChild("Inventory_Button", true)


--// Setup_LeftGui() ------------------------------------------------------------
function LeftGui.Setup()

    -- connect the clickies
    LeftGui.Menu_Button.MouseButton1Down:Connect(function()

        Knit.Controllers.GuiController.Modules.MainMenu:Toggle()
        
        --[[
        if not Knit.Controllers.GuiController.InDialogue then
            if Knit.Controllers.GuiController.CurrentWindow == "MainMenu" then
                Knit.Controllers.GuiController.Modules.MainMenu.Close()
                Knit.Controllers.GuiController.CurrentWindow = nil
            else
                Knit.Controllers.GuiController:CloseAllWindows()
                Knit.Controllers.GuiController.Modules.MainMenu.Open()
                Knit.Controllers.GuiController.CurrentWindow = "MainMenu"
            end
        end
        ]]--
    end)

end


return LeftGui