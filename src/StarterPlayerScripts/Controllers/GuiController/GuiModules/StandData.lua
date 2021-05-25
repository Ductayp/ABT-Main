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

print("MAIN GUI", mainGui)
local BottomGui = {}

BottomGui.Frame_Main = mainGui:FindFirstChild("TopLeftGui", true)

BottomGui.Frame_Stand = BottomGui.Frame_Main:FindFirstChild("Frame_Stand", true)
BottomGui.Text_StandLevel = BottomGui.Frame_Main:FindFirstChild("Text_StandLevel", true)

BottomGui.Frame_Health = BottomGui.Frame_Main:FindFirstChild("Frame_Health", true)
BottomGui.Text_Health = BottomGui.Frame_Main:FindFirstChild("Text_Health", true)
BottomGui.Frame_Xp = BottomGui.Frame_Main:FindFirstChild("Frame_Xp", true)
BottomGui.Text_Xp = BottomGui.Frame_Main:FindFirstChild("Text_Xp", true)


--// Setup ------------------------------------------------------------
function BottomGui.Setup()

    -- update the health bar when the player joins
    BottomGui.UpdateHealth()

    -- connect a health changed event
    Players.LocalPlayer.Character.Humanoid.HealthChanged:Connect(function()
        BottomGui.UpdateHealth()
    end)

    Players.LocalPlayer.CharacterAdded:Connect(function()
        local humanoid = Players.LocalPlayer.Character:WaitForChild("Humanoid")
        --repeat wait() until Players.LocalPlayer.Character.Humanoid
        BottomGui.UpdateHealth()
        humanoid.HealthChanged:Connect(function()
            BottomGui.UpdateHealth()
        end)
    end)
    
end

--// Update ------------------------------------------------------------
function BottomGui.Update(data, params)
    
    print("StandData.Update", data)

    -- delete the old stand icon if it exists
    local oldIcon = BottomGui.Frame_Stand:FindFirstChild("StandIcon")
    if oldIcon then
        oldIcon:Destroy()
    end

    -- if the player is standless
    if data.CurrentStand.Power == "Standless" then
        BottomGui.Frame_Stand.Standless.Visible = true
        BottomGui.Text_StandLevel.Visible = false
        BottomGui.Text_Xp.Text = "0 / 0"
        BottomGui.Frame_Xp.Size = UDim2.new(0,BottomGui.Frame_Health.Size.X.Offset,BottomGui.Frame_Health.Size.Y.Scale,BottomGui.Frame_Health.Size.Y.Offset)
        for i, v in pairs(BottomGui.AbilityNames) do
            v.Text = "-"
        end
        return
    end

    BottomGui.Frame_Stand.Standless.Visible = false

    local currentPowerModule = require(Knit.Powers[data.CurrentStand.Power])

    -- make a new icon
    local newStandIcon =  mainGui.Stand_Icons:FindFirstChild(data.CurrentStand.Power .. "_" .. tostring(data.CurrentStand.Rank)):Clone()
    newStandIcon.Name = "StandIcon"
    newStandIcon.Parent = BottomGui.Frame_Stand
    newStandIcon.Visible = true
    newStandIcon.BackgroundTransparency = 1

    -- set the XP bar
    local maxExperience = currentPowerModule.Defs.MaxXp[data.CurrentStand.Rank]
    BottomGui.Text_Xp.Text = data.CurrentStand.Xp .. " / " .. maxExperience
    local percent = data.CurrentStand.Xp / maxExperience
    BottomGui.Frame_Xp.Size = UDim2.new(percent,BottomGui.Frame_Health.Size.X.Offset,BottomGui.Frame_Health.Size.Y.Scale,BottomGui.Frame_Health.Size.Y.Offset)

end

--// SetHealth - we do this seperately becuse it is fired from both the Update function and a Changed event
function BottomGui.UpdateHealth()

    BottomGui.Text_Health.Text = math.floor(Players.LocalPlayer.Character.Humanoid.Health) .. " / " .. Players.LocalPlayer.Character.Humanoid.MaxHealth
    local percent = Players.LocalPlayer.Character.Humanoid.Health / Players.LocalPlayer.Character.Humanoid.MaxHealth
    if percent >= 1 then
        percent = 1
    end
    BottomGui.Frame_Health.Size = UDim2.new(percent,BottomGui.Frame_Health.Size.X.Offset,BottomGui.Frame_Health.Size.Y.Scale,BottomGui.Frame_Health.Size.Y.Offset)
end

function BottomGui.HideStand()
    BottomGui.Frame_Stand.Visible = false
    for _, name in pairs(BottomGui.AbilityNames) do
        name.Visible = false
    end

end

function BottomGui.ShowStand()
    BottomGui.Frame_Stand.Visible = true
    for _, name in pairs(BottomGui.AbilityNames) do
        name.Visible = true
    end
end



return BottomGui