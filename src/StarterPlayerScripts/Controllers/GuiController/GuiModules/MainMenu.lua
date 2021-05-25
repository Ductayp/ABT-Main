--MainMenu

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

local MainMenu = {}

MainMenu.Frame = mainGui.Windows:FindFirstChild("MainMenu", true)
MainMenu.Button_Close = MainMenu.Frame:FindFirstChild("Button_Close", true)

MainMenu.Button_Storage = MainMenu.Frame:FindFirstChild("Button_Storage", true)
MainMenu.Button_Items = MainMenu.Frame:FindFirstChild("Button_Items", true)



--// Setup_MainMenu() ------------------------------------------------------------
function MainMenu.Setup()

    MainMenu.Frame.Visible = false

    MainMenu.Button_Close.MouseButton1Down:Connect(function()
        MainMenu.Close()
    end)

    MainMenu.Button_Storage.MouseButton1Down:Connect(function()
        Knit.Controllers.GuiController.Modules.Storage.Open()
    end)

    MainMenu.Button_Items.MouseButton1Down:Connect(function()
        Knit.Controllers.GuiController.Modules.Items.Open()
    end)

end

function MainMenu.Toggle()

    if not Knit.Controllers.GuiController.InDialogue then
        if Knit.Controllers.GuiController.CurrentWindow == "MainMenu" then
            MainMenu.Close()
        else
            MainMenu.Open()
        end
    end

end

function MainMenu.Open()
    Knit.Controllers.GuiController:CloseAllWindows()
    Knit.Controllers.GuiController.CurrentWindow = "MainMenu"
    MainMenu.Frame.Visible = true
end

function MainMenu.Close()
    Knit.Controllers.GuiController.CurrentWindow = nil
    MainMenu.Frame.Visible = false
end



return MainMenu