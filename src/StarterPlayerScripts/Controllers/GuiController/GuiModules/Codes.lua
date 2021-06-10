--Codes

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local GuiService = Knit.GetService("GuiService")
local CodesService = Knit.GetService("CodesService")
local utils = require(Knit.Shared.Utils)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)

local Codes = {}

Codes.Frame = mainGui.Windows:FindFirstChild("Codes", true)
Codes.Button_Close = Codes.Frame:FindFirstChild("Button_Close", true)
Codes.Submit_Button = Codes.Frame:FindFirstChild("Submit_Button", true)
Codes.Code_Input_Box = Codes.Frame:FindFirstChild("Code_Input_Box", true)
Codes.Return_Message = Codes.Frame:FindFirstChild("Return_Message", true)

--// Setup
function Codes.Setup()

    Codes.Frame.Visible = false

    Codes.Button_Close.MouseButton1Down:Connect(function()
        Codes.Close()
    end)

    Codes.Submit_Button.MouseButton1Down:Connect(function()
        Codes.SubmitCode()
    end)

end

function Codes.Open()
    Knit.Controllers.GuiController:CloseAllWindows()
    Codes.Frame.Visible = true
    Knit.Controllers.GuiController.CurrentWindow = "Codes"
end

function Codes.Close()
    Knit.Controllers.GuiController:CloseAllWindows()
    Codes.Frame.Visible = false
    Knit.Controllers.GuiController.CurrentWindow = nil
end

function Codes.SubmitCode()

    local returnMessage = CodesService:RedeemCode(string.lower(Codes.Code_Input_Box.Text))
    Codes.DisplayMessage(returnMessage)
    Codes.Code_Input_Box.Text = " "
end

function Codes.DisplayMessage(message)

    spawn(function()
        Codes.Return_Message.Text = message
        wait(10)
        if Codes.Return_Message.Text == message then
            Codes.Return_Message.Text = "FRESH CODES EVERY WEEK"
        end
    end)
    
end


return Codes