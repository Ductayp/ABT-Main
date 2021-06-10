--ToggleGUI

-- roblox services
local Players = game:GetService("Players")

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)

local ToggleGUI = {}

--// Setup
function ToggleGUI.Setup()
    -- nothign here
end

function ToggleGUI.Toggle(boolean)
    mainGui.Enabled = boolean
end


return ToggleGUI