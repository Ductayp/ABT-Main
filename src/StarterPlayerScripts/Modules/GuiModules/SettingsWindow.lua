--SettingsWindow
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

local SettingsWindow = {}

SettingsWindow.Frame = mainGui.Windows:FindFirstChild("SettingsWindow", true)
SettingsWindow.Close_Button = SettingsWindow.Frame:FindFirstChild("Close_Button", true)
SettingsWindow.Music_ON_Button = SettingsWindow.Frame:FindFirstChild("Music_ON_Button", true)
SettingsWindow.Music_OFF_Button = SettingsWindow.Frame:FindFirstChild("Music_OFF_Button", true)
SettingsWindow.Music_VolumeUP_Button = SettingsWindow.Frame:FindFirstChild("Music_VolumeUP_Button", true)
SettingsWindow.Music_VolumeDOWN_Button = SettingsWindow.Frame:FindFirstChild("Music_VolumeDOWN_Button", true)
SettingsWindow.Music_Volume_TextLabel = SettingsWindow.Frame:FindFirstChild("Music_Volume_Text", true)

SettingsWindow.SFX_ON_Button = SettingsWindow.Frame:FindFirstChild("SFX_ON_Button", true)
SettingsWindow.SFX_OFF_Button = SettingsWindow.Frame:FindFirstChild("SFX_OFF_Button", true)
SettingsWindow.SFX_VolumeUP_Button = SettingsWindow.Frame:FindFirstChild("SFX_VolumeUP_Button", true)
SettingsWindow.SFX_VolumeDOWN_Button = SettingsWindow.Frame:FindFirstChild("SFX_VolumeDOWN_Button", true)
SettingsWindow.SFX_Volume_TextLabel = SettingsWindow.Frame:FindFirstChild("SFX_Volume_TextLabel", true)


--// Setup
function SettingsWindow.Setup()

    -- turn it off on setup
    SettingsWindow.Frame.Visible = false

    -- Close Button
    SettingsWindow.Close_Button.Activated:Connect(function()
        SettingsWindow.Frame.Visible = false
    end)

    SettingsWindow.Music_ON_Button.Activated:Connect(function()
        Knit.Controllers.SoundController:ToggleMusic(true)
        SettingsWindow.Music_ON_Button.BackgroundColor3 = Color3.fromRGB (0, 127, 0)
        SettingsWindow.Music_OFF_Button.BackgroundColor3 = Color3.fromRGB (25,25,25)
    end)

    SettingsWindow.Music_OFF_Button.Activated:Connect(function()
        Knit.Controllers.SoundController:ToggleMusic(false)
        SettingsWindow.Music_ON_Button.BackgroundColor3 = Color3.fromRGB (25,25,25)
        SettingsWindow.Music_OFF_Button.BackgroundColor3 = Color3.fromRGB (206, 0, 0)
    end)

    SettingsWindow.Music_VolumeUP_Button.Activated:Connect(function()
        Knit.Controllers.SoundController:IncrementGroupVolume("AmbientMusic", 0.1)
        SettingsWindow.Music_Volume_TextLabel.Text = math.floor(SoundService.AmbientMusic.Volume * 10) 
    end)

    SettingsWindow.Music_VolumeDOWN_Button.Activated:Connect(function()
        Knit.Controllers.SoundController:IncrementGroupVolume("AmbientMusic", -0.1)
        SettingsWindow.Music_Volume_TextLabel.Text = math.floor(SoundService.AmbientMusic.Volume * 10) 
    end)

    SettingsWindow.SFX_ON_Button.Activated:Connect(function()
        SettingsWindow.SFX_ON_Button.BackgroundColor3 = Color3.fromRGB (0, 127, 0)
        SettingsWindow.SFX_OFF_Button.BackgroundColor3 = Color3.fromRGB (25,25,25)
        Knit.Controllers.SoundController:ToggleSFX(true)
        SettingsWindow.SFX_Volume_TextLabel.Text = math.floor(SoundService.SFX.Volume * 10) 
    end)

    SettingsWindow.SFX_OFF_Button.Activated:Connect(function()
        SettingsWindow.SFX_ON_Button.BackgroundColor3 = Color3.fromRGB (25,25,25)
        SettingsWindow.SFX_OFF_Button.BackgroundColor3 = Color3.fromRGB (206, 0, 0)
        Knit.Controllers.SoundController:ToggleSFX(false)
        --SettingsWindow.SFX_Volume_TextLabel.Text = math.floor(SoundService.SFX.Volume * 10) 
    end)

    SettingsWindow.SFX_VolumeUP_Button.Activated:Connect(function()
        Knit.Controllers.SoundController:IncrementGroupVolume("SFX", 0.1)
        SettingsWindow.SFX_Volume_TextLabel.Text = math.floor(SoundService.SFX.Volume * 10) 
    end)

    SettingsWindow.SFX_VolumeDOWN_Button.Activated:Connect(function()
        Knit.Controllers.SoundController:IncrementGroupVolume("SFX", -0.1)
        SettingsWindow.SFX_Volume_TextLabel.Text = math.floor(SoundService.SFX.Volume * 10) 
    end)
    
    -- set the volume numbers
    SettingsWindow.Music_Volume_TextLabel.Text = math.floor(SoundService.AmbientMusic.Volume * 10) 
    SettingsWindow.SFX_Volume_TextLabel.Text = math.floor(SoundService.SFX.Volume * 10)

    -- set the music toggle buttons
    if Knit.Controllers.SoundController.MusicOn then
        SettingsWindow.Music_ON_Button.BackgroundColor3 = Color3.fromRGB (0, 127, 0)
        SettingsWindow.Music_OFF_Button.BackgroundColor3 = Color3.fromRGB (25,25,25)
    else
        SettingsWindow.Music_ON_Button.BackgroundColor3 = Color3.fromRGB (25,25,25)
        SettingsWindow.Music_OFF_Button.BackgroundColor3 = Color3.fromRGB (206, 0, 0)
    end

    -- set the SFX toggle buttons
    if SoundService.SFX.Volume == 0 then
        SettingsWindow.SFX_ON_Button.BackgroundColor3 = Color3.fromRGB (25,25,25)
        SettingsWindow.SFX_OFF_Button.BackgroundColor3 = Color3.fromRGB (206, 0, 0)
    else
        SettingsWindow.SFX_ON_Button.BackgroundColor3 = Color3.fromRGB (0, 127, 0)
        SettingsWindow.SFX_OFF_Button.BackgroundColor3 = Color3.fromRGB (25,25,25)
    end
    
end

function SettingsWindow.Open()
    SettingsWindow.Frame.Visible = true
end


return SettingsWindow