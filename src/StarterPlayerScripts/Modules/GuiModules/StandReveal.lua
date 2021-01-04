-- Stand Reveal
-- PDab
-- 1/3/2021

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local InventoryService = Knit.GetService("InventoryService")
local GamePassService = Knit.GetService("GamePassService")

-- utils
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)

-- Constants
local GUI_COLOR = {
    COMMON = Color3.new(239/255, 239/255, 239/255),
    RARE = Color3.new(10/255, 202/255, 0/255),
    LEGENDARY = Color3.new(255/255, 149/255, 43/255)
}

local StandReveal = {}

StandReveal.Main_Frame = mainGui.Overlays:FindFirstChild("Stand_Reveal", true)
StandReveal.Asset_Folder = StandReveal.Main_Frame:FindFirstChild("Assets", true)
StandReveal.Temp_Assets = StandReveal.Main_Frame:FindFirstChild("TempAssets", true)

StandReveal.Button_Frame = StandReveal.Main_Frame:FindFirstChild("Button_Frame", true)
StandReveal.Icon_Frame = StandReveal.Main_Frame:FindFirstChild("Icon_Frame", true)
StandReveal.Storage_Warning = StandReveal.Main_Frame:FindFirstChild("Storage_Warning", true)
StandReveal.Stand_Name = StandReveal.Main_Frame:FindFirstChild("Stand_Name", true)
StandReveal.Stand_Rarity = StandReveal.Main_Frame:FindFirstChild("Stand_Rarity", true)
StandReveal.Rays_1 = StandReveal.Main_Frame:FindFirstChild("Rays_1", true)
StandReveal.Rays_2 = StandReveal.Main_Frame:FindFirstChild("Rays_2", true)
StandReveal.Rays_3 = StandReveal.Main_Frame:FindFirstChild("Rays_3", true)
StandReveal.Burst_1 = StandReveal.Main_Frame:FindFirstChild("Burst_1", true)
StandReveal.Burst_2 = StandReveal.Main_Frame:FindFirstChild("Burst_2", true)
StandReveal.Balls_1 = StandReveal.Main_Frame:FindFirstChild("Balls_1", true)
StandReveal.Balls_2 = StandReveal.Main_Frame:FindFirstChild("Balls_2", true)

StandReveal.Equip_Button = StandReveal.Main_Frame:FindFirstChild("Equip_Button", true)
StandReveal.Store_Button = StandReveal.Main_Frame:FindFirstChild("Store_Button", true)
StandReveal.MobileStorage_BuyButton = StandReveal.Main_Frame:FindFirstChild("MobileStorage_Buy_Button", true)

-- a table of elements for convenience
local elements = {
    StandReveal.Button_Frame,
    StandReveal.Icon_Frame,
    StandReveal.Storage_Warning,
    StandReveal.Stand_Name,
    StandReveal.Stand_Rarity,
    StandReveal.Rays_1,
    StandReveal.Rays_2,
    StandReveal.Rays_3,
    StandReveal.Burst_1,
    StandReveal.Burst_2,
    StandReveal.Balls_1,
    StandReveal.Balls_2
}



--// Setup_StandReveal ------------------------------------------------------------
function StandReveal.Setup()

    -- be sure the stand reveal is closed
    StandReveal.Main_Frame.Visible = false

    -- also be sure all elements have visibility off, we can turn them on one by one
    for _,element in pairs(elements) do
        element.Visible = false
    end

    -- setup the buttons
    StandReveal.Equip_Button.Activated:Connect(function()
        StandReveal.ActivateClose()
    end)
    StandReveal.Store_Button.Activated:Connect(function()
        StandReveal.ActivateQuickStore()
    end)
    StandReveal.MobileStorage_BuyButton.Activated:Connect(function()
        GamePassService:Prompt_GamePassPurchase("MobileStandStorage")
    end)

end

--// ActivateQuickStore ------------------------------------------------------------
function StandReveal.ActivateQuickStore()


    if GamePassService:Has_GamePass("MobileStandStorage") then
        InventoryService:StoreStand()
        StandReveal.ActivateClose()
    else
        StandReveal.StorageWarning()
    end
    
end

--// ActivateClose ------------------------------------------------------------
function StandReveal.ActivateClose()

    StandReveal.Temp_Assets:ClearAllChildren()

    -- make it invisible
    StandReveal.Main_Frame.Visible = false 

    -- also be sure all elements have visibility off, we can turn them on one by one next time we run it
    for _,element in pairs(elements) do
        element.Visible = false
    end

    -- show the stand in BottomGui when we close this
    require(Knit.GuiModules.BottomGui).ShowPower()

end

--// StorageWarning
function StandReveal.StorageWarning()

    -- stroe the destination position
    local finalPosition = StandReveal.Storage_Warning.Position

    -- move it over and mae it visible
    StandReveal.Storage_Warning.Position = StandReveal.Storage_Warning.Position + UDim2.new(1,0,0,0)
    StandReveal.Storage_Warning.Visible = true

    -- setup tween
    local moveTween = TweenService:Create(StandReveal.Storage_Warning,TweenInfo.new(.5),{Position = finalPosition})
    moveTween:Play()

    spawn(function()

        local originalSize = StandReveal.Store_Button.Size
        local originalColor = StandReveal.Store_Button.TextColor3
        local originalText = StandReveal.Store_Button.Text
        local originalBackgroundColor = StandReveal.Store_Button.BackgroundColor3

        StandReveal.Store_Button.Size = defs.Stand_Reveal.Buttons.Store_Button.Size + UDim2.new(.01,0,.01,0)
        StandReveal.Store_Button.BackgroundColor3 = Color3.new(45/255, 45/255, 45/255)
        StandReveals.Store_Button.TextColor3 = Color3.new(255/255, 0/255, 0/255)
        StandReveal.Store_Button.Text = "NOPE"
        StandReveal.Store_Button.Active = false

        wait(3)

        StandReveal.Store_Button.Size = originalSize
        StandReveal.Store_Button.BackgroundColor3 = originalBackgroundColor
        StandReveal.Store_Button.TextColor3 = originalColor
        StandReveal.Store_Button.Text = originalText
        StandReveal.Store_Button.Active = true

    end)

end

--// Update ------------------------------------------------------------
function StandReveal.Update(data)

    -- hide the current stand text until after the reveal
    require(Knit.GuiModules.BottomGui).HidePower()
    
    -- get the module for the stand that just got revealed, also the players CurrentStand, we need this to get the actual name
    local currentPowerModule = Knit.Powers:FindFirstChild(data.Power)
    local powerModule = require(currentPowerModule)

    -- set things based on rarity
    StandReveal.Stand_Name.Text = powerModule.Defs.PowerName
    StandReveal.Stand_Rarity.Text = data.Rarity
    if data.Rarity == "Common" then
        StandReveal.Stand_Rarity.TextColor3 = Color3.new(255/255, 255/255, 255/255)
    elseif data.Rarity == "Rare" then
        StandReveal.Stand_Rarity.TextColor3 = Color3.new(10/255, 202/255, 0/255)
    elseif data.Rarity == "Legendary" then
        StandReveal.Stand_Rarity.TextColor3 = Color3.new(255/255, 149/255, 43/255)
    end

    -- clear old icons out of the container
    StandReveal.Icon_Frame.Icon_Container:ClearAllChildren()

    -- clone in a new icon
    --local newIcon = mainGui.Stand_Icons:FindFirstChild(data.CurrentPower):Clone()
    local standIcon = data.Power .. "_" .. data.Rarity
    local newIcon = mainGui.Stand_Icons:FindFirstChild(standIcon):Clone()
    newIcon.Visible = true
    newIcon.Parent = StandReveal.Icon_Frame.Icon_Container

    StandReveal.RevealStand()

end

--// RevealStand ------------------------------------------------------------
function StandReveal.RevealStand()

    -- create some new animation objects, so we leave to originals in place
    local newRay_1 = StandReveal.Rays_1:Clone()
    local newRay_2 = StandReveal.Rays_2:Clone()
    local newRay_3 = StandReveal.Rays_3:Clone()
    local newRay_4 = StandReveal.Rays_3:Clone()

    local newBurst_1 = StandReveal.Burst_1:Clone()
    local newBurst_2 = StandReveal.Burst_2:Clone()

    local newBalls_1 = StandReveal.Balls_1:Clone()
    local newBalls_2 = StandReveal.Balls_2:Clone()

    newRay_1.Parent = StandReveal.Temp_Assets
    newRay_2.Parent = StandReveal.Temp_Assets
    newRay_3.Parent = StandReveal.Temp_Assets
    newRay_4.Parent = StandReveal.Temp_Assets
    newBurst_1.Parent = StandReveal.Temp_Assets
    newBurst_2.Parent = StandReveal.Temp_Assets
    newBalls_1.Parent = StandReveal.Temp_Assets
    newBalls_2.Parent = StandReveal.Temp_Assets

    -- save some final sizes for elements
    local finalIconFrame_Size = StandReveal.Icon_Frame.Size
    local finalName_Size = StandReveal.Stand_Name.Size
    local finalRays_1_Size = StandReveal.Rays_1.Size
    local finalRays_2_Size = StandReveal.Rays_2.Size
    local finalRays_3_Size = StandReveal.Rays_3.Size
    local finalRays_4_Size = StandReveal.Rays_3.Size
    local finalBurst_1_Size = StandReveal.Burst_1.Size
    local finalBurst_2_Size = StandReveal.Burst_2.Size
    local finalBalls_1_Size = StandReveal.Balls_1.Size
    local finalBalls_2_Size = StandReveal.Balls_2.Size

    --now lets make some smaller so we can pop them
    StandReveal.Icon_Frame.Size = UDim2.new(0, 0, 0, 0)
    StandReveal.Stand_Name.Size = UDim2.new(0, 0, 0, 0)
    newRay_1.Size = UDim2.new(0, 0, 0, 0)
    newRay_2.Size = UDim2.new(0, 0, 0, 0)
    newRay_3.Size = UDim2.new(0, 0, 0, 0)
    newRay_4.Size = UDim2.new(0, 0, 0, 0)
    newBurst_1.Size = UDim2.new(2, 0, 2, 0)
    newBurst_2.Size = UDim2.new(0, 0, 0, 0)
    newBalls_1.Size = UDim2.new(2, 0, 2, 0)
    newBalls_2.Size = UDim2.new(0, 0, 0, 0)

    -- tweens 
    local tweenInfo_Size = TweenInfo.new(.5,Enum.EasingStyle.Bounce)

    -- icon and text
    local sizeTween_IconFrame = TweenService:Create(StandReveal.Icon_Frame,tweenInfo_Size,{Size = finalIconFrame_Size})
    local sizeTween_Name = TweenService:Create(StandReveal.Stand_Name,tweenInfo_Size,{Size = finalName_Size})

    -- Rays_1
    local sizeTween_Rays_1 = TweenService:Create(newRay_1,tweenInfo_Size,{Size = finalRays_1_Size})
    local spinTween_Rays_1 = TweenService:Create(newRay_1,TweenInfo.new(40,Enum.EasingStyle.Linear),{Rotation = 359})

    -- Ray_2
    local sizeTween_Rays_2 = TweenService:Create(newRay_2,tweenInfo_Size,{Size = finalRays_2_Size})
    local spinTween_Rays_2 = TweenService:Create(newRay_2,TweenInfo.new(60,Enum.EasingStyle.Linear),{Rotation = -359})

    -- Ray_3
    local sizeTween_Rays_3 = TweenService:Create(newRay_3,tweenInfo_Size,{Size = finalRays_3_Size})
    local spinTween_Rays_3 = TweenService:Create(newRay_3,TweenInfo.new(10,Enum.EasingStyle.Linear),{Rotation = 359})

    -- Ray_3
    local sizeTween_Rays_4 = TweenService:Create(newRay_4,tweenInfo_Size,{Size = finalRays_4_Size})
    local spinTween_Rays_4 = TweenService:Create(newRay_4,TweenInfo.new(10,Enum.EasingStyle.Linear),{Rotation = -359})

    -- newBurst_1
    local sizeTween_newBurst_1 = TweenService:Create(newBurst_1,TweenInfo.new(2,Enum.EasingStyle.Elastic),{Size = finalBurst_1_Size})
    local spinTween_newBurst_1 = TweenService:Create(newBurst_1,TweenInfo.new(5,Enum.EasingStyle.Linear),{Rotation = -359})

    -- newBalls_1
    local sizeTween_newBalls_1 = TweenService:Create(newBalls_1,tweenInfo_Size,{Size = finalBalls_1_Size})
    local spinTween_newBalls_1 = TweenService:Create(newBalls_1,TweenInfo.new(10,Enum.EasingStyle.Linear),{Rotation = 359})

    -- newBurst_2
    local sizeTween_newBurst_2 = TweenService:Create(newBurst_2,TweenInfo.new(1,Enum.EasingStyle.Elastic),{Size = finalBurst_2_Size})
    local spinTween_newBurst_2 = TweenService:Create(newBurst_2,TweenInfo.new(60,Enum.EasingStyle.Linear),{Rotation = 359})

    -- newBalls_2
    local sizeTween_newBalls_2 = TweenService:Create(newBalls_2,tweenInfo_Size,{Size = finalBalls_2_Size})
    local spinTween_newBalls_2 = TweenService:Create(newBalls_2,TweenInfo.new(180,Enum.EasingStyle.Linear),{Rotation = -359})

    -- completed event
    spinTween_Rays_1.Completed:Connect(function(playbackState)
        if playbackState == Enum.PlaybackState.Completed then
            StandReveal.ActivateClose()
        end
    end)

    spawn(function()

        -- make some things visible
        StandReveal.Main_Frame.Visible = true
        newBurst_1.Visible = true
        newBalls_1.Visible = true
        newRay_3.Visible = true
        newRay_4.Visible = true

        -- start the initial tweens
        sizeTween_Rays_3:Play()
        spinTween_Rays_3:Play()
        sizeTween_Rays_4:Play()
        spinTween_Rays_4:Play()
        sizeTween_newBurst_1:Play()
        sizeTween_newBalls_1:Play()
        spinTween_newBurst_1:Play()
        spinTween_newBalls_1:Play()

        wait(1.5)

        -- more makign of things visible
        StandReveal.Icon_Frame.Visible = true
        StandReveal.Button_Frame.Visible = true
        StandReveal.Stand_Name.Visible = true
        StandReveal.Stand_Rarity.Visible = true
        newRay_1.Visible = true
        newRay_2.Visible = true
        newBurst_2.Visible = true
        newBalls_2.Visible = true

        sizeTween_IconFrame:Play()
        sizeTween_Name:Play()

        sizeTween_Rays_1:Play()
        sizeTween_Rays_2:Play()
        spinTween_Rays_1:Play()
        spinTween_Rays_2:Play()

        sizeTween_newBurst_2:Play()
        spinTween_newBurst_2:Play()

        sizeTween_newBalls_2:Play()
        spinTween_newBalls_2:Play()

        newBurst_1:Destroy()
        newBalls_1:Destroy()
        newRay_3:Destroy()
        newRay_4:Destroy()
    
    end)

end

return StandReveal