-- Bottom Gui
-- PDab
-- 1/2/2021

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
--local PowersService = Knit.GetService("PowersService")

-- modules
local utils = require(Knit.Shared.Utils)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)

local BottomGui = {}

BottomGui.Frame_Main = mainGui.BottomGui:FindFirstChild("Frame_BottomGui", true)
BottomGui.Text_Ping = BottomGui.Frame_Main:FindFirstChild("Text_Ping", true)

BottomGui.Frame_Stand = BottomGui.Frame_Main:FindFirstChild("Frame_Stand", true)
BottomGui.Text_StandLevel = BottomGui.Frame_Main:FindFirstChild("Text_StandLevel", true)

BottomGui.Frame_Health = BottomGui.Frame_Main:FindFirstChild("Frame_Health", true)
BottomGui.Text_Health = BottomGui.Frame_Main:FindFirstChild("Text_Health", true)
BottomGui.Frame_Xp = BottomGui.Frame_Main:FindFirstChild("Frame_Xp", true)
BottomGui.Text_Xp = BottomGui.Frame_Main:FindFirstChild("Text_Xp", true)

BottomGui.Buttons = {
    Q = BottomGui.Frame_Main:FindFirstChild("Button_Q", true),
    E = BottomGui.Frame_Main:FindFirstChild("Button_E", true),
    R = BottomGui.Frame_Main:FindFirstChild("Button_R", true),
    T = BottomGui.Frame_Main:FindFirstChild("Button_T", true),
    F = BottomGui.Frame_Main:FindFirstChild("Button_F", true),
    Z = BottomGui.Frame_Main:FindFirstChild("Button_Z", true),
    X = BottomGui.Frame_Main:FindFirstChild("Button_X", true),
    C = BottomGui.Frame_Main:FindFirstChild("Button_C", true)
}

BottomGui.Cooldowns = {
    Q = BottomGui.Frame_Main:FindFirstChild("Cooldown_Q", true),
    E = BottomGui.Frame_Main:FindFirstChild("Cooldown_E", true),
    R = BottomGui.Frame_Main:FindFirstChild("Cooldown_R", true),
    T = BottomGui.Frame_Main:FindFirstChild("Cooldown_T", true),
    F = BottomGui.Frame_Main:FindFirstChild("Cooldown_F", true),
    Z = BottomGui.Frame_Main:FindFirstChild("Cooldown_Z", true),
    X = BottomGui.Frame_Main:FindFirstChild("Cooldown_X", true),
    C = BottomGui.Frame_Main:FindFirstChild("Cooldown_C", true)
 }

-- Constants
local EMPTY_COOLDOWN_SIZE = UDim2.new(1,0,0,0)
local FULL_COOLDOWN_SIZE = UDim2.new(1,0,1,0)


--// Setup ------------------------------------------------------------
function BottomGui.Setup()

    -- update the health bar when the player joins
    BottomGui.UpdateHealth()

    -- setup all the cooldowns
    for _,cooldown in pairs(BottomGui.Cooldowns) do
        cooldown.Size = EMPTY_COOLDOWN_SIZE
    end

    -- connect a health changed event
    Players.LocalPlayer.Character.Humanoid.HealthChanged:Connect(function()
        BottomGui.UpdateHealth()
    end)

    Players.LocalPlayer.CharacterAdded:Connect(function()
        repeat wait() until Players.LocalPlayer.Character.Humanoid
        BottomGui.UpdateHealth()
        Players.LocalPlayer.Character.Humanoid.HealthChanged:Connect(function()
            BottomGui.UpdateHealth()
        end)
    end)
    

    -- connect buttons to InputController
    for buttonName,buttonInstance in pairs(BottomGui.Buttons) do
        buttonInstance.Active = true
        buttonInstance.Activated:Connect(function()
            Knit.Controllers.InputController:SendToPowersService({InputId = buttonName, KeyState = "InputBegan"})
        end)
    end

    -- connect the ping
    local pingValue = ReplicatedStorage.PlayerPings:WaitForChild(Players.LocalPlayer.UserId)
    pingValue.Changed:Connect(function()
        local roundedNumber = tonumber(string.format("%." .. (3 or 0) .. "f", pingValue.Value))
        --print(roundedNumber)
        BottomGui.Text_Ping.Text = tostring(roundedNumber)
    end)

end

--// Update ------------------------------------------------------------
function BottomGui.Update(data)
    
    print("BottomGui.Update", data)

    -- delete the old stand icon if it exists
    local oldIcon = BottomGui.Frame_Stand:FindFirstChild("StandIcon")
    if oldIcon then
        oldIcon:Destroy()
    end

    -- set the stand icon
    if data.CurrentStand.Power == "Standless" then
        BottomGui.Frame_Stand.Standless.Visible = true
        BottomGui.Text_StandLevel.Visible = false
        BottomGui.Text_Xp.Text = "0 / 0"
        BottomGui.Frame_Xp.Size = UDim2.new(0,BottomGui.Frame_Health.Size.X.Offset,BottomGui.Frame_Health.Size.Y.Scale,BottomGui.Frame_Health.Size.Y.Offset)
    else
        BottomGui.Frame_Stand.Standless.Visible = false

        -- make a new icon
        local newStandIcon =  mainGui.Stand_Icons:FindFirstChild(data.CurrentStand.Power .. "_" .. data.CurrentStand.Rarity):Clone()
        newStandIcon.Name = "StandIcon"
        newStandIcon.Parent = BottomGui.Frame_Stand
        newStandIcon.Visible = true
        newStandIcon.BackgroundTransparency = 1

        -- set the level
        BottomGui.Text_StandLevel.Visible = true
        BottomGui.Text_StandLevel.Text = data.XpData.Level

        -- set the XP bar
        BottomGui.Text_Xp.Text = data.XpData.XpThisLevel .. " / " .. data.XpData.XpPerLevel
        local percent = data.XpData.XpThisLevel / data.XpData.XpPerLevel
        BottomGui.Frame_Xp.Size = UDim2.new(percent,BottomGui.Frame_Health.Size.X.Offset,BottomGui.Frame_Health.Size.Y.Scale,BottomGui.Frame_Health.Size.Y.Offset)
    end
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

function BottomGui.UpdateCooldown(params)

    local thisCooldown = BottomGui.Cooldowns[params.CooldownName] 
    if not thisCooldown then
        print("BottomGui.UpdateCooldown: CANT FIND COOLDOWN", params)
        return
    end

    thisCooldown.Size = FULL_COOLDOWN_SIZE

    --print("BottomGui.UpdateCooldown - params: ", params)
    --print("BottomGui.UpdateCooldown - thisCooldown: ", thisCooldown)
    --print("BottomGui.UpdateCooldown - params.CooldownTime: ", params.CooldownTime)

    -- get a length of time for the tween based on the actual 
    local tweenTime = params.CooldownTime - (os.time())

    if tweenTime <= 1 then
        tweenTime = 1
    end
    --local cooldownTween = TweenService:Create(thisCooldown,TweenInfo.new(tweenTime),{Size = EMPTY_COOLDOWN_SIZE})
    local cooldownTween = TweenService:Create(thisCooldown,TweenInfo.new(tweenTime),{Size = EMPTY_COOLDOWN_SIZE})
    cooldownTween:Play()
    
end

function BottomGui.HideStand()
    
end

function BottomGui.ShowStand()
    
end



return BottomGui