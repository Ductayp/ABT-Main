-- NPCDialogueWindow
-- PDab
-- 2/11/2021

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local GuiService = Knit.GetService("GuiService")
local utils = require(Knit.Shared.Utils)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)

local NPCDialogueWindow = {}

NPCDialogueWindow.Frame = mainGui.Windows:FindFirstChild("NPCDialogueWindow", true)


--// Setup
function NPCDialogueWindow.Setup()

    -- turn it off on setup
    NPCDialogueWindow.Frame.Visible = false

    -- Close Button
    NPCDialogueWindow.Close_Button.MouseButton1Down:Connect(function()
        NPCDialogueWindow.Frame.Visible = false
    end)

    
end

function NPCDialogueWindow.Open()
    NPCDialogueWindow.Frame.Visible = true
end


return NPCDialogueWindow