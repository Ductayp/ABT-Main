--MainMenu

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local GuiService = Knit.GetService("GuiService")
local utils = require(Knit.Shared.Utils)


local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)

local color_Green = Color3.fromRGB(16, 214, 46)
local color_Red = Color3.fromRGB(255, 2, 6)

local MainMenu = {}

MainMenu.Frame = mainGui.Windows:FindFirstChild("MainMenu", true)
MainMenu.Button_Close = MainMenu.Frame:FindFirstChild("Button_Close", true)

MainMenu.Button_Storage = MainMenu.Frame:FindFirstChild("Button_Storage", true)
MainMenu.Button_Items = MainMenu.Frame:FindFirstChild("Button_Items", true)
MainMenu.Button_Codes = MainMenu.Frame:FindFirstChild("Button_Codes", true)
MainMenu.Button_Shop = MainMenu.Frame:FindFirstChild("Button_Shop", true)
MainMenu.Button_ItemFinder = MainMenu.Frame:FindFirstChild("Button_ItemFinder", true)
MainMenu.Button_Settings = MainMenu.Frame:FindFirstChild("Button_Settings", true)
MainMenu.Button_Crafting = MainMenu.Frame:FindFirstChild("Button_Crafting", true)

MainMenu.Button_PvP = MainMenu.Frame:FindFirstChild("Button_PvP", true)
MainMenu.PVP_TOGGLE_TEXT = MainMenu.Button_PvP:FindFirstChild("ToggleText", true)
MainMenu.PVP_OUTER_FRAME = MainMenu.Frame.Buttons:FindFirstChild("PvPToggle", true)
MainMenu.Label_2XExpereince = MainMenu.Button_PvP:FindFirstChild("Label_2XExpereince", true)
MainMenu.CantUse_Warning = MainMenu.Button_PvP:FindFirstChild("CantUse_Warning", true)

--// Setup_MainMenu() ------------------------------------------------------------
function MainMenu.Setup()

    MainMenu.Frame.Visible = false

    MainMenu.Button_Close.MouseButton1Down:Connect(function()
        MainMenu.Close()
    end)

    MainMenu.Button_Storage.MouseButton1Down:Connect(function()
        GuiService:Request_GuiUpdate("StoragePanel")
        --GuiService:Request_GuiUpdate("StoragePanel_Access")
        Knit.Controllers.GuiController.Modules.Storage.Open()
    end)

    MainMenu.Button_Items.MouseButton1Down:Connect(function()
        GuiService:Request_GuiUpdate("ItemsWindow")
        Knit.Controllers.GuiController.Modules.Items.Open()
    end)

    MainMenu.Button_Codes.MouseButton1Down:Connect(function()
        Knit.Controllers.GuiController.Modules.Codes.Open()
    end)

    MainMenu.Button_Shop.MouseButton1Down:Connect(function()
        Knit.Controllers.GuiController.Modules.Shop.Open()
    end)

    MainMenu.Button_ItemFinder.MouseButton1Down:Connect(function()
        Knit.Controllers.GuiController.Modules.ItemFinder.Open()
    end)

    MainMenu.Button_Settings.MouseButton1Down:Connect(function()
        Knit.Controllers.GuiController.Modules.Settings.Open()
    end)

    MainMenu.Button_Crafting.MouseButton1Down:Connect(function()
        GuiService:Request_GuiUpdate("CraftingWindow")
        Knit.Controllers.GuiController.Modules.Crafting.Open()
    end)

    -- PvP button
    MainMenu.Button_PvP.MouseButton1Down:Connect(function()
        if not Knit.Controllers.GuiController.InDialogue then
            GuiService:TogglePvP()
        end
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

function  MainMenu.Update_PvPButton(pvpToggle, params)

    print("Update_PvPButton(pvpToggle, params)", pvpToggle, params)

    if pvpToggle == true then
        MainMenu.PVP_TOGGLE_TEXT.Text = "ON"
        MainMenu.PVP_TOGGLE_TEXT.TextColor3 = color_Green
        MainMenu.PVP_OUTER_FRAME.BackgroundColor3 = color_Green
        MainMenu.Label_2XExpereince.Visible = true
    else
        MainMenu.PVP_TOGGLE_TEXT.Text = "OFF"
        MainMenu.PVP_TOGGLE_TEXT.TextColor3 = color_Red
        MainMenu.PVP_OUTER_FRAME.BackgroundColor3 = color_Red
        MainMenu.Label_2XExpereince.Visible = false
    end

    if params then
        if not params.CanToggle then
            spawn(function()
                MainMenu.CantUse_Warning.Visible = true
                wait(3)
                MainMenu.CantUse_Warning.Visible = false
            end)
        end
    end

end



return MainMenu