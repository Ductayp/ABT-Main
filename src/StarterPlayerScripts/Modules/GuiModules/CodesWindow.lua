--CodesWindow
-- PDab
-- 2/11/2021

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

local CodesWindow = {}

CodesWindow.Frame = mainGui.Windows:FindFirstChild("CodesWindow", true)
CodesWindow.Close_Button = CodesWindow.Frame:FindFirstChild("Close_Button", true)
CodesWindow.Submit_Button = CodesWindow.Frame:FindFirstChild("Submit_Button", true)
CodesWindow.Code_Input_Box = CodesWindow.Frame:FindFirstChild("Code_Input_Box", true)
CodesWindow.Return_Message = CodesWindow.Frame:FindFirstChild("Return_Message", true)

--// Setup
function CodesWindow.Setup()

    CodesWindow.Frame.Visible = false

    CodesWindow.Close_Button.Activated:Connect(function()
        CodesWindow.Frame.Visible = false
    end)

    CodesWindow.Submit_Button.Activated:Connect(function()
        CodesWindow.SubmitCode()
    end)

end

function CodesWindow.Open()
    CodesWindow.Frame.Visible = true
end

function CodesWindow.SubmitCode()

    local returnMessage = CodesService:RedeemCode(string.lower(CodesWindow.Code_Input_Box.Text))
    CodesWindow.DisplayMessage(returnMessage)
    CodesWindow.Code_Input_Box.Text = " "
end

function CodesWindow.DisplayMessage(message)

    spawn(function()
        CodesWindow.Return_Message.Text = message
        wait(10)
        if CodesWindow.Return_Message.Text == message then
            CodesWindow.Return_Message.Text = "FRESH CODES EVERY WEEK"
        end
    end)
    
end


return CodesWindow