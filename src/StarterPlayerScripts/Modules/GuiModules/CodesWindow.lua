--CodesWindow
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

local CodesWindow = {}

CodesWindow.Frame = mainGui.Windows:FindFirstChild("CodesWindow", true)


--// Setup
function CodesWindow.Setup()


    
end

function CodesWindow.Open()
    CodesWindow.Frame.Visible = true
end


return CodesWindow