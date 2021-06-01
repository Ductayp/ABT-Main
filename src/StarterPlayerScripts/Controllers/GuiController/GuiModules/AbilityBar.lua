-- Bottom Gui
-- PDab
-- 1/2/2021

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

-- modules
local utils = require(Knit.Shared.Utils)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)

local AbilityBar = {}

AbilityBar.Frame_Main = mainGui:FindFirstChild("AbilityBar", true)

AbilityBar.Frames = {
    Q = AbilityBar.Frame_Main:FindFirstChild("Frame_Q", true),
    E = AbilityBar.Frame_Main:FindFirstChild("Frame_E", true),
    R = AbilityBar.Frame_Main:FindFirstChild("Frame_R", true),
    T = AbilityBar.Frame_Main:FindFirstChild("Frame_T", true),
    F = AbilityBar.Frame_Main:FindFirstChild("Frame_F", true),
    Z = AbilityBar.Frame_Main:FindFirstChild("Frame_Z", true),
    X = AbilityBar.Frame_Main:FindFirstChild("Frame_X", true),
    C = AbilityBar.Frame_Main:FindFirstChild("Frame_C", true)
}

AbilityBar.Buttons = {
    Q = AbilityBar.Frame_Main:FindFirstChild("Button_Q", true),
    E = AbilityBar.Frame_Main:FindFirstChild("Button_E", true),
    R = AbilityBar.Frame_Main:FindFirstChild("Button_R", true),
    T = AbilityBar.Frame_Main:FindFirstChild("Button_T", true),
    F = AbilityBar.Frame_Main:FindFirstChild("Button_F", true),
    Z = AbilityBar.Frame_Main:FindFirstChild("Button_Z", true),
    X = AbilityBar.Frame_Main:FindFirstChild("Button_X", true),
    C = AbilityBar.Frame_Main:FindFirstChild("Button_C", true)
}

AbilityBar.Cooldowns = {
    Q = AbilityBar.Frame_Main:FindFirstChild("Cooldown_Q", true),
    E = AbilityBar.Frame_Main:FindFirstChild("Cooldown_E", true),
    R = AbilityBar.Frame_Main:FindFirstChild("Cooldown_R", true),
    T = AbilityBar.Frame_Main:FindFirstChild("Cooldown_T", true),
    F = AbilityBar.Frame_Main:FindFirstChild("Cooldown_F", true),
    Z = AbilityBar.Frame_Main:FindFirstChild("Cooldown_Z", true),
    X = AbilityBar.Frame_Main:FindFirstChild("Cooldown_X", true),
    C = AbilityBar.Frame_Main:FindFirstChild("Cooldown_C", true)
 }

 AbilityBar.AbilityNames = {
    Q = AbilityBar.Frame_Main:FindFirstChild("AbilityName_Q", true),
    E = AbilityBar.Frame_Main:FindFirstChild("AbilityName_E", true),
    R = AbilityBar.Frame_Main:FindFirstChild("AbilityName_R", true),
    T = AbilityBar.Frame_Main:FindFirstChild("AbilityName_T", true),
    F = AbilityBar.Frame_Main:FindFirstChild("AbilityName_F", true),
    Z = AbilityBar.Frame_Main:FindFirstChild("AbilityName_Z", true),
    X = AbilityBar.Frame_Main:FindFirstChild("AbilityName_X", true),
    C = AbilityBar.Frame_Main:FindFirstChild("AbilityName_C", true)
 }

-- Constants
local EMPTY_COOLDOWN_SIZE = UDim2.new(1,0,0,0)
local FULL_COOLDOWN_SIZE = UDim2.new(1,0,1,0)


--// Setup ------------------------------------------------------------
function AbilityBar.Setup()

    -- setup all the cooldowns
    for _,cooldown in pairs(AbilityBar.Cooldowns) do
        cooldown.Size = EMPTY_COOLDOWN_SIZE
    end

    -- connect buttons to InputController
    for buttonName,buttonInstance in pairs(AbilityBar.Buttons) do
        buttonInstance.Active = true
        buttonInstance.MouseButton1Down:Connect(function()
            print("MobileClicked", buttonInstance.Name)
            Knit.Controllers.InputController:SendToPowersService({InputId = buttonName, KeyState = "InputBegan"})
        end)
    end

end

--// Update ------------------------------------------------------------
function AbilityBar.Update(data, params)
    
    --print("AbilityBar.Update", data)

    local currentPowerModule = require(Knit.Powers[data.CurrentStand.Power])

    -- setup the ability buttons
    for i, v in pairs(currentPowerModule.Defs.KeyMap) do
        if v.AbilityName == "-" then
            AbilityBar.Buttons[i].Parent.Visible = false
            AbilityBar.AbilityNames[i].Text = v.AbilityName
        else
            AbilityBar.Buttons[i].Parent.Visible = true
            AbilityBar.AbilityNames[i].Text = v.AbilityName
        end
        
    end
    
end

function AbilityBar.UpdateCooldown(params)

    local thisCooldown = AbilityBar.Cooldowns[params.CooldownName] 
    if not thisCooldown then
        print("AbilityBar.UpdateCooldown: CANT FIND COOLDOWN", params)
        return
    end

    thisCooldown.Size = FULL_COOLDOWN_SIZE

    --print("AbilityBar.UpdateCooldown - params: ", params)
    --print("AbilityBar.UpdateCooldown - thisCooldown: ", thisCooldown)
    --print("AbilityBar.UpdateCooldown - params.CooldownTime: ", params.CooldownTime)

    -- get a length of time for the tween based on the actual 
    local tweenTime = params.CooldownTime - (os.time())

    if tweenTime <= 1 then
        tweenTime = 1
    end

    local cooldownTween = TweenService:Create(thisCooldown,TweenInfo.new(tweenTime),{Size = EMPTY_COOLDOWN_SIZE})
    cooldownTween:Play()
    
end

function AbilityBar.HideAbilities()
    for _, abilityName in pairs(AbilityBar.AbilityNames) do
        abilityName.Visible = false
    end
end

function AbilityBar.ShowAbilities()
    for _, abilityName in pairs(AbilityBar.AbilityNames) do
        if abilityName.Text == "-" then
            abilityName.Visible = false
        else
            abilityName.Visible = true
        end
    end
end

return AbilityBar