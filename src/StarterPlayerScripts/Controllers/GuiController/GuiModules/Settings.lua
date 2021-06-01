--Settings
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

local Settings = {}

Settings.Frame = mainGui.Windows:FindFirstChild("Settings", true)
Settings.Button_Close = Settings.Frame:FindFirstChild("Button_Close", true)
Settings.Music_ON_Button = Settings.Frame:FindFirstChild("Music_ON_Button", true)
Settings.Music_OFF_Button = Settings.Frame:FindFirstChild("Music_OFF_Button", true)
Settings.Music_VolumeUP_Button = Settings.Frame:FindFirstChild("Music_VolumeUP_Button", true)
Settings.Music_VolumeDOWN_Button = Settings.Frame:FindFirstChild("Music_VolumeDOWN_Button", true)
Settings.Music_Volume_TextLabel = Settings.Frame:FindFirstChild("Music_Volume_Text", true)

Settings.SFX_ON_Button = Settings.Frame:FindFirstChild("SFX_ON_Button", true)
Settings.SFX_OFF_Button = Settings.Frame:FindFirstChild("SFX_OFF_Button", true)
Settings.SFX_VolumeUP_Button = Settings.Frame:FindFirstChild("SFX_VolumeUP_Button", true)
Settings.SFX_VolumeDOWN_Button = Settings.Frame:FindFirstChild("SFX_VolumeDOWN_Button", true)
Settings.SFX_Volume_TextLabel = Settings.Frame:FindFirstChild("SFX_Volume_TextLabel", true)


--// Setup
function Settings.Setup()

    -- turn it off on setup
    Settings.Frame.Visible = false

    -- Close Button
    Settings.Button_Close.Activated:Connect(function()
        Settings.Close()
    end)

    Settings.Music_ON_Button.Activated:Connect(function()
        Knit.Controllers.SoundController:ToggleMusic(true)
        Settings.Music_ON_Button.BackgroundColor3 = Color3.fromRGB (0, 127, 0)
        Settings.Music_OFF_Button.BackgroundColor3 = Color3.fromRGB (25,25,25)
    end)

    Settings.Music_OFF_Button.Activated:Connect(function()
        Knit.Controllers.SoundController:ToggleMusic(false)
        Settings.Music_ON_Button.BackgroundColor3 = Color3.fromRGB (25,25,25)
        Settings.Music_OFF_Button.BackgroundColor3 = Color3.fromRGB (206, 0, 0)
    end)

    Settings.Music_VolumeUP_Button.Activated:Connect(function()
        Knit.Controllers.SoundController:IncrementGroupVolume("AmbientMusic", 0.1)
        Settings.Music_Volume_TextLabel.Text = math.floor(SoundService.AmbientMusic.Volume * 10) 
    end)

    Settings.Music_VolumeDOWN_Button.Activated:Connect(function()
        Knit.Controllers.SoundController:IncrementGroupVolume("AmbientMusic", -0.1)
        Settings.Music_Volume_TextLabel.Text = math.floor(SoundService.AmbientMusic.Volume * 10) 
    end)

    Settings.SFX_ON_Button.Activated:Connect(function()
        Settings.SFX_ON_Button.BackgroundColor3 = Color3.fromRGB (0, 127, 0)
        Settings.SFX_OFF_Button.BackgroundColor3 = Color3.fromRGB (25,25,25)
        Knit.Controllers.SoundController:ToggleSFX(true)
        Settings.SFX_Volume_TextLabel.Text = math.floor(SoundService.SFX.Volume * 10) 
    end)

    Settings.SFX_OFF_Button.Activated:Connect(function()
        Settings.SFX_ON_Button.BackgroundColor3 = Color3.fromRGB (25,25,25)
        Settings.SFX_OFF_Button.BackgroundColor3 = Color3.fromRGB (206, 0, 0)
        Knit.Controllers.SoundController:ToggleSFX(false)
    end)

    Settings.SFX_VolumeUP_Button.Activated:Connect(function()
        Knit.Controllers.SoundController:IncrementGroupVolume("SFX", 0.1)
        Settings.SFX_Volume_TextLabel.Text = math.floor(SoundService.SFX.Volume * 10) 
    end)

    Settings.SFX_VolumeDOWN_Button.Activated:Connect(function()
        Knit.Controllers.SoundController:IncrementGroupVolume("SFX", -0.1)
        Settings.SFX_Volume_TextLabel.Text = math.floor(SoundService.SFX.Volume * 10) 
    end)
    
    -- set the volume numbers
    Settings.Music_Volume_TextLabel.Text = math.floor(SoundService.AmbientMusic.Volume * 10) 
    Settings.SFX_Volume_TextLabel.Text = math.floor(SoundService.SFX.Volume * 10)

    -- set the music toggle buttons
    if Knit.Controllers.SoundController.MusicOn then
        Settings.Music_ON_Button.BackgroundColor3 = Color3.fromRGB (0, 127, 0)
        Settings.Music_OFF_Button.BackgroundColor3 = Color3.fromRGB (25,25,25)
    else
        Settings.Music_ON_Button.BackgroundColor3 = Color3.fromRGB (25,25,25)
        Settings.Music_OFF_Button.BackgroundColor3 = Color3.fromRGB (206, 0, 0)
    end

    -- set the SFX toggle buttons
    if SoundService.SFX.Volume == 0 then
        Settings.SFX_ON_Button.BackgroundColor3 = Color3.fromRGB (25,25,25)
        Settings.SFX_OFF_Button.BackgroundColor3 = Color3.fromRGB (206, 0, 0)
    else
        Settings.SFX_ON_Button.BackgroundColor3 = Color3.fromRGB (0, 127, 0)
        Settings.SFX_OFF_Button.BackgroundColor3 = Color3.fromRGB (25,25,25)
    end
    
end

function Settings.Open()
    Knit.Controllers.GuiController:CloseAllWindows()
    Knit.Controllers.GuiController.CurrentWindow = "Settings"
    Settings.Frame.Visible = true
end

function Settings.Close()
    Knit.Controllers.GuiController:CloseAllWindows()
    Knit.Controllers.GuiController.CurrentWindow = nil
    Settings.Frame.Visible = false
end


return Settings