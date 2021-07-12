-- StandData

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

-- modules
local utils = require(Knit.Shared.Utils)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)

local StandData = {}

StandData.Frame_Main = mainGui:FindFirstChild("TopLeftGui", true)

StandData.Frame_Stand = StandData.Frame_Main:FindFirstChild("Frame_Stand", true)
StandData.Text_StandLevel = StandData.Frame_Main:FindFirstChild("Text_StandLevel", true)

StandData.Frame_Health = StandData.Frame_Main:FindFirstChild("Frame_Health", true)
StandData.Text_Health = StandData.Frame_Main:FindFirstChild("Text_Health", true)
StandData.Frame_Xp = StandData.Frame_Main:FindFirstChild("Frame_Xp", true)
StandData.Text_Xp = StandData.Frame_Main:FindFirstChild("Text_Xp", true)


--// Setup ------------------------------------------------------------
function StandData.Setup()

    -- update the health bar when the player joins
    StandData.UpdateHealth()

    -- connect a health changed event
    Players.LocalPlayer.Character.Humanoid.HealthChanged:Connect(function()
        StandData.UpdateHealth()
    end)

    Players.LocalPlayer.CharacterAdded:Connect(function()
        local humanoid = Players.LocalPlayer.Character:WaitForChild("Humanoid")
        --repeat wait() until Players.LocalPlayer.Character.Humanoid
        StandData.UpdateHealth()
        humanoid.HealthChanged:Connect(function()
            StandData.UpdateHealth()
        end)
    end)
    
end

--// Update ------------------------------------------------------------
function StandData.Update(data, params)
    
    --print("StandData.Update", data)

    -- delete the old stand icon if it exists
    local oldIcon = StandData.Frame_Stand:FindFirstChild("StandIcon")
    if oldIcon then
        oldIcon:Destroy()
    end

    -- if the player is standless
    if data.CurrentStand.Power == "Standless" then
        StandData.Frame_Stand.Standless.Visible = true
        StandData.Text_StandLevel.Visible = false
        StandData.Text_Xp.Text = "0 / 0"
        StandData.Frame_Xp.Size = UDim2.new(0,StandData.Frame_Health.Size.X.Offset,StandData.Frame_Health.Size.Y.Scale,StandData.Frame_Health.Size.Y.Offset)
        return
    end

    StandData.Frame_Stand.Standless.Visible = false

    local currentPowerModule = require(Knit.Powers[data.CurrentStand.Power])

    -- make a new icon
    local standIcon =  mainGui.Stand_Icons:FindFirstChild(data.CurrentStand.Power .. "_" .. tostring(data.CurrentStand.Rank))
    if standIcon then
        local newStandIcon = mainGui.Stand_Icons:FindFirstChild(data.CurrentStand.Power .. "_" .. tostring(data.CurrentStand.Rank)):Clone()
        newStandIcon.Name = "StandIcon"
        newStandIcon.Parent = StandData.Frame_Stand
        newStandIcon.Visible = true
        newStandIcon.BackgroundTransparency = 1
    else
        warn("GuiModule:StandData - Cannot find stand icon for GUI: ", data.CurrentStand.Power, data.CurrentStand.Rank)
    end
    
    -- set the XP bar
    local maxExperience = currentPowerModule.Defs.MaxXp
    StandData.Text_Xp.Text = data.CurrentStand.Xp .. " / " .. maxExperience
    local percent = data.CurrentStand.Xp / maxExperience
    StandData.Frame_Xp.Size = UDim2.new(percent,StandData.Frame_Health.Size.X.Offset,StandData.Frame_Health.Size.Y.Scale,StandData.Frame_Health.Size.Y.Offset)

end

--// SetHealth - we do this seperately becuse it is fired from both the Update function and a Changed event
function StandData.UpdateHealth()

    StandData.Text_Health.Text = math.floor(Players.LocalPlayer.Character.Humanoid.Health) .. " / " .. Players.LocalPlayer.Character.Humanoid.MaxHealth
    local percent = Players.LocalPlayer.Character.Humanoid.Health / Players.LocalPlayer.Character.Humanoid.MaxHealth
    if percent >= 1 then
        percent = 1
    end
    StandData.Frame_Health.Size = UDim2.new(percent,StandData.Frame_Health.Size.X.Offset,StandData.Frame_Health.Size.Y.Scale,StandData.Frame_Health.Size.Y.Offset)
end

function StandData.HideStand()
    StandData.Frame_Stand.Visible = false
end

function StandData.ShowStand()
    StandData.Frame_Stand.Visible = true
end



return StandData