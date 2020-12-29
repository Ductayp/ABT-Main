-- GUI controller
-- PDab
-- 12 / 15/ 2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local PlayerGui = Players.LocalPlayer.PlayerGui
local TweenService = game:GetService("TweenService")


-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local GuiController = Knit.CreateController { Name = "GuiController" }
local GuiService = Knit.GetService("GuiService")
local InventoryService = Knit.GetService("InventoryService")
local PowersService = Knit.GetService("PowersService")

-- Knit modules
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)

-- Gui Defs
local mainGui = PlayerGui:WaitForChild("MainGui", 120)
local defs = {}


--// ====================================================================================================================================
--//  BOTTOM GUI
--// ====================================================================================================================================

--// DEFS - BOTTOM GUI ------------------------------------------------------------
defs.Bottom_Gui = {
    Current_Power = mainGui.BottomGui:FindFirstChild("Current_Power", true)
}


--// Setup_PowerButton ------------------------------------------------------------
function GuiController:Setup_PowerButton()

    --local mainGui = Players.LocalPlayer.PlayerGui:WaitForChild("MainGui")
    local powerButtonFrame = mainGui:FindFirstChild("PowerButtons",true)

    for _,button in pairs(powerButtonFrame:GetDescendants()) do
        if button:IsA("TextButton") then
            button.Activated:Connect(function()
                Knit.Controllers.InputController:SendToPowersService({InputId = button.Name, KeyState = "InputBegan"})
            end)
        end
    end
end

--// UpdateCharacter ------------------------------------------------------------
function GuiController:Update_Character(data)
    defs.Bottom_Gui.Current_Power.Text = data.CurrentPower
end


--// ====================================================================================================================================
--//  LEFT GUI
--// ====================================================================================================================================

--// DEFS - LEFT GUI ------------------------------------------------------------
defs.LeftGui = {
    Cash_Value = mainGui.LeftGui:FindFirstChild("Cash_Value", true),
    Buttons = {
        MainMenu_Button = mainGui.LeftGui:FindFirstChild("MainMenu_Button", true),
        Arrow_Button = mainGui.LeftGui:FindFirstChild("Arrow_Button", true),
        Storage_Button = mainGui.LeftGui:FindFirstChild("Storage_Button", true),
    },
}

--// Setup_LeftGui() ------------------------------------------------------------
function GuiController:Setup_LeftGui()

    -- connect the clickies
    defs.LeftGui.Buttons.MainMenu_Button.Activated:Connect(function()
        self:ActivateWindow(defs.Windows.MainWindow,defs.Windows.MainWindow.Panels.Item_Panel)
    end)

    defs.LeftGui.Buttons.Arrow_Button.Activated:Connect(function()
        self:ActivateWindow(defs.Windows.MainWindow,defs.Windows.MainWindow.Panels.Arrow_Panel)
    end)

    defs.LeftGui.Buttons.Storage_Button.Activated:Connect(function()
        self:ActivateWindow(defs.Windows.MainWindow,defs.Windows.MainWindow.Panels.Storage_Panel)
    end)
end

--// UpdateCash ------------------------------------------------------------
function GuiController:Update_Cash(value)
    if value ~= nil then
        defs.LeftGui.Cash_Value.Text = value
    end
end


--// ====================================================================================================================================
--//  WINDOW GUI
--// ====================================================================================================================================

--// DEFS - WINDOW GUI ------------------------------------------------------------
defs.Windows = {}
defs.Windows.MainWindow = {
    Window = mainGui.Windows:FindFirstChild("MainWindow", true),
    Buttons = {
        Item_Button = mainGui.Windows.MainWindow:FindFirstChild("Item_Button", true),
        Storage_Button = mainGui.Windows.MainWindow:FindFirstChild("Storage_Button", true),
        Arrow_Button = mainGui.Windows.MainWindow:FindFirstChild("Arrow_Button", true),
        Shop_Button = mainGui.Windows.MainWindow:FindFirstChild("Shop_Button", true),
        Code_Button = mainGui.Windows.MainWindow:FindFirstChild("Code_Button", true),
        Setting_Button = mainGui.Windows.MainWindow:FindFirstChild("Setting_Button", true),
        Close_Button = mainGui.Windows.MainWindow:FindFirstChild("CloseButton", true)
    },
    Panels = {
        Arrow_Panel = mainGui.Windows.MainWindow:FindFirstChild("Arrow_Panel", true),
        Code_Panel = mainGui.Windows.MainWindow:FindFirstChild("Code_Panel", true),
        Item_Panel = mainGui.Windows.MainWindow:FindFirstChild("Item_Panel", true),
        Shop_Panel = mainGui.Windows.MainWindow:FindFirstChild("Shop_Panel", true),
        Storage_Panel = mainGui.Windows.MainWindow:FindFirstChild("Storage_Panel", true),
        Setting_Panel = mainGui.Windows.MainWindow:FindFirstChild("Setting_Panel", true)
    }
}

--// Setup_MainWindow ------------------------------------------------------------
function GuiController:Setup_MainWindow()

    -- just be sure main window is off
    defs.Windows.MainWindow.Window.Visible = false

    -- connect buttons
    defs.Windows.MainWindow.Buttons.Close_Button.Activated:Connect(function()
        defs.Windows.MainWindow.Window.Visible = false
    end)

    defs.Windows.MainWindow.Buttons.Item_Button.Activated:Connect(function()
        self:ActivatePanel(defs.Windows.MainWindow,defs.Windows.MainWindow.Panels.Item_Panel)
    end)

    defs.Windows.MainWindow.Buttons.Arrow_Button.Activated:Connect(function()
        self:ActivatePanel(defs.Windows.MainWindow,defs.Windows.MainWindow.Panels.Arrow_Panel)
    end)

    defs.Windows.MainWindow.Buttons.Storage_Button.Activated:Connect(function()
        self:ActivatePanel(defs.Windows.MainWindow,defs.Windows.MainWindow.Panels.Storage_Panel)
    end)

    defs.Windows.MainWindow.Buttons.Shop_Button.Activated:Connect(function()
        self:ActivatePanel(defs.Windows.MainWindow,defs.Windows.MainWindow.Panels.Shop_Panel)
    end)

    defs.Windows.MainWindow.Buttons.Code_Button.Activated:Connect(function()
        self:ActivatePanel(defs.Windows.MainWindow,defs.Windows.MainWindow.Panels.Code_Panel)
    end)

    defs.Windows.MainWindow.Buttons.Setting_Button.Activated:Connect(function()
        self:ActivatePanel(defs.Windows.MainWindow,defs.Windows.MainWindow.Panels.Setting_Panel)
    end)

end

--// ActivateWindow ------------------------------------------------------------
function GuiController:ActivateWindow(windowDef,panelDef)

    -- turn off all panels, then turn on the one we want to start on
    for i,v in pairs(windowDef.Panels) do
        v.Visible = false
    end
    panelDef.Visible = true

    -- toggle the window 
    if windowDef.Window.Visible then
        windowDef.Window.Visible = false
    else
        windowDef.Window.Visible = true
    end
end

--// ActivatePanel
function GuiController:ActivatePanel(windowDef,panelDef)

    -- make sure the window is on
    if windowDef.Window.Visible == false then
    windowDef.Window.Visible = true
    end

    -- turn off all panels, then turn on the one we want to start on
    for i,v in pairs(windowDef.Panels) do
        v.Visible = false
    end
    panelDef.Visible = true

end

--// ====================================================================================================================================
--//  ARROW PANEL
--// ====================================================================================================================================

--// DEFS - ARROW PANEL ------------------------------------------------------------
defs.ArrowPanel = {
    Scrolling_Frame = defs.Windows.MainWindow.Panels.Arrow_Panel:FindFirstChild("ScrollingFrame", true),
    Item_Template = defs.Windows.MainWindow.Panels.Arrow_Panel:FindFirstChild("ItemTemplate", true),
    UseArrowFrame = defs.Windows.MainWindow.Panels.Arrow_Panel:FindFirstChild("UserArrowPanels"),
    UseArrowPanels = {
        Default_Panel = defs.Windows.MainWindow.Panels.Arrow_Panel:FindFirstChild("Default_Panel", true),
        UniversalArrow_Common = defs.Windows.MainWindow.Panels.Arrow_Panel:FindFirstChild("UniversalArrow_Common", true),
        UniversalArrow_Rare = defs.Windows.MainWindow.Panels.Arrow_Panel:FindFirstChild("UniversalArrow_Rare", true),
        UniversalArrow_Legendary = defs.Windows.MainWindow.Panels.Arrow_Panel:FindFirstChild("UniversalArrow_Legendary", true),
    },
    UseArrowButtons = {
        UniversalArrow_Common = defs.Windows.MainWindow.Panels.Arrow_Panel:FindFirstChild("UseArrow_Universal_Common", true),
        UniversalArrow_Rare = defs.Windows.MainWindow.Panels.Arrow_Panel:FindFirstChild("UseArrow_Universal_Rare", true),
        UniversalArrow_Legendary = defs.Windows.MainWindow.Panels.Arrow_Panel:FindFirstChild("UseArrow_Universal_Legendary", true),
    }
}

--// Setup_ArrowPanel ------------------------------------------------------------
function GuiController:Setup_ArrowPanel()
    defs.ArrowPanel.Item_Template.Visible = false

    -- connect Use Arrow buttons
    defs.ArrowPanel.UseArrowButtons.UniversalArrow_Common.Activated:Connect(function()
            params = {}
            params.Type = "UniversalArrow"
            params.Rarity = "Common"
            button = defs.ArrowPanel.UseArrowButtons.UniversalArrow_Common
            self:Request_UseArrow(params,button)
    end)
    defs.ArrowPanel.UseArrowButtons.UniversalArrow_Rare.Activated:Connect(function()
        params = {}
        params.Type = "UniversalArrow"
        params.Rarity = "Rare"
        button = defs.ArrowPanel.UseArrowButtons.UniversalArrow_Rare
        self:Request_UseArrow(params,button)
    end)
    defs.ArrowPanel.UseArrowButtons.UniversalArrow_Legendary.Activated:Connect(function()
        params = {}
        params.Type = "UniversalArrow"
        params.Rarity = "Legendary"
        button = defs.ArrowPanel.UseArrowButtons.UniversalArrow_Legendary
        self:Request_UseArrow(params,button)
    end)
end

--// Update_ArrowPanel ------------------------------------------------------------
function GuiController:Update_ArrowPanel(data)

    -- destroy all arrows int he scrolling frame
    for _,object in pairs(defs.ArrowPanel.Scrolling_Frame:GetChildren()) do
        if object.Name == "arrowItem" then
            object:Destroy()
        end
    end

    -- turn off all right panels and show default panel
    for i,v in pairs(defs.ArrowPanel.UseArrowFrame:GetChildren()) do
        if v:IsA("Frame") then
        v.Visible = false
        end
    end
    defs.ArrowPanel.UseArrowPanels.Default_Panel.Visible = true


    -- build all the arrows and put them in the scrollign frame
    for i,arrow in pairs(data) do

        -- make a new list item
        local newListItem = defs.ArrowPanel.Item_Template:Clone()
        newListItem.Parent = defs.ArrowPanel.Scrolling_Frame
        newListItem.Visible = true
        newListItem.Name = "arrowItem"

        -- change text
        local textLabel = newListItem:FindFirstChild("Arrow_Name", true)
        textLabel.Text = arrow.ArrowName

        -- set some values based on rarity
        local icon = newListItem:FindFirstChild("Arrow_Icon", true)
        local targetPanel
        if arrow.Rarity == "Common" then
            targetPanel = defs.ArrowPanel.UseArrowPanels.UniversalArrow_Common
        elseif arrow.Rarity == "Rare" then
            icon.ImageColor3 = Color3.new(10/255, 202/255, 0/255)
            textLabel.TextColor3 = Color3.new(10/255, 202/255, 0/255)
            targetPanel = defs.ArrowPanel.UseArrowPanels.UniversalArrow_Rare
        elseif arrow.Rarity == "Legendary" then
            icon.ImageColor3 = Color3.new(255/255, 149/255, 43/255)
            textLabel.TextColor3 = Color3.new(255/255, 149/255, 43/255)
            targetPanel = defs.ArrowPanel.UseArrowPanels.UniversalArrow_Legendary
        end

        -- connect the click to open the arrow panel
        newListItem.Activated:Connect(function()

            -- turn off all the use arrow panels
            for i,v in pairs(defs.ArrowPanel.UseArrowFrame:GetChildren()) do
                if v:IsA("Frame") then
                v.Visible = false
                end
            end

            targetPanel.Visible = true
        end)
    end

    -- finally, update the ScrollingFrame CanvasSize to match the UiListLayout
    defs.ArrowPanel.Scrolling_Frame.CanvasSize = UDim2.new(0, 0, 0, defs.ArrowPanel.Scrolling_Frame.UIListLayout.AbsoluteContentSize.Y)
end

--// Request_UseArrow ------------------------------------------------------------
function GuiController:Request_UseArrow(params,button)
    local currentPower = PowersService:GetCurrentPower()
    if currentPower == "Standless" then
        InventoryService:UseArrow(params)
    else
        print("USE ARROW BUTTON: You Must Be Standless")
        spawn(function()
            local buttonColor = button.BorderColor3
            local buttonText = button.Text
            local textColor = button.TextColor3
            local buttonSize = button.Size

            button.BorderColor3 = Color3.new(255/255, 0/255, 0/255)
            button.Text = "MUST BE STANDLESS"
            button.TextColor3 = Color3.new(255/255, 0/255, 0/255)
            button.Size = button.Size + UDim2.new(0,0,.5,0)
            button.Active = false

            wait(3)

            button.BorderColor3 = buttonColor
            button.Text = buttonText
            button.TextColor3 = textColor
            button.Size = buttonSize
            button.Active = true
        end)
    end
end

--// ====================================================================================================================================
--//  STAND STORAGE PANEL
--// ====================================================================================================================================

--// DEFS - STAND PANEL ------------------------------------------------------------

--// Setup_StandPanel ------------------------------------------------------------
function GuiController:Setup_StandPanel()

end

--// Update_StandPanel ------------------------------------------------------------
function GuiController:Update_StandPanel()

end

--// Request_EquipStand ------------------------------------------------------------
function GuiController:Request_EquipStand()

end

--// Request_StoreStand ------------------------------------------------------------
function GuiController:Request_StoreStand()

end

--// Request_EvolveStand ------------------------------------------------------------
function GuiController:Request_EvolveStand()

end

--// Request_SellStand ------------------------------------------------------------
function GuiController:Request_SellStand()

end

--// ====================================================================================================================================
--//  OVERLAY - STAND REVEAL
--// ====================================================================================================================================

--// DEFS - OVERLAY - STAND REVEAL ------------------------------------------------------------
defs.Stand_Reveal = {
    Main_Frame = mainGui.Overlays:FindFirstChild("Stand_Reveal", true),
    Elements = {
        Button_Frame = mainGui.Overlays.Stand_Reveal:FindFirstChild("Button_Frame", true),
        Icon_Frame = mainGui.Overlays.Stand_Reveal:FindFirstChild("Icon_Frame", true),
        Storage_Warning = mainGui.Overlays.Stand_Reveal:FindFirstChild("Storage_Warning", true),
        Stand_Name = mainGui.Overlays.Stand_Reveal:FindFirstChild("Stand_Name", true),
        Stand_Rarity = mainGui.Overlays.Stand_Reveal:FindFirstChild("Stand_Rarity", true),
        Rays_1 = mainGui.Overlays.Stand_Reveal:FindFirstChild("Rays_1", true),
        Rays_2 = mainGui.Overlays.Stand_Reveal:FindFirstChild("Rays_2", true),
    },
    Buttons = {
        Equip_Button = mainGui.Overlays.Stand_Reveal:FindFirstChild("Equip_Button", true),
        Store_Button = mainGui.Overlays.Stand_Reveal:FindFirstChild("Store_Button", true),
    }
}

--// Setup_StandReveal ------------------------------------------------------------
function GuiController:Setup_StandReveal()

    -- be sure the stand reveal is closed
    defs.Stand_Reveal.Main_Frame.Visible = false

    -- also be sure all elements have visibility off, we can turn them on one by one
    for _,element in pairs(defs.Stand_Reveal.Elements) do
        element.Visible = false
    end

    -- setup the buttons
    defs.Stand_Reveal.Buttons.Equip_Button.Activated:Connect(function()
        self:StandReveal_ActivateClose()
    end)
    defs.Stand_Reveal.Buttons.Store_Button.Activated:Connect(function()
        self:StandReveal_ActivateQuickStore()
    end)

end

--// StandReveal_QuickStore ------------------------------------------------------------
function GuiController:StandReveal_ActivateQuickStore()

    if Knit.StateModules.GamePass:HasPass(player,"MobileStandStorage") then
        print("Quick Store the stand - BEEP!")
    else
        print("NOPE! - You dont have the MobileStandStorage pass")
    end
    
end

--// Update_StandReveal ------------------------------------------------------------
function GuiController:Update_StandReveal(data)

    print("data.CurrentPower: ", data.CurrentPower)
    print("data.CurrentPowerRarity: ", data.CurrentPowerRarity)

    -- get the module for the stand that just got revealed, also the players CurrentStand, we need this to get the actual name
    local currentPowerModule = Knit.Powers:FindFirstChild(data.CurrentPower)
    local powerModule = require(currentPowerModule)

    -- set the text and do some colors
    defs.Stand_Reveal.Elements.Stand_Name.Text = powerModule.Defs.PowerName
    defs.Stand_Reveal.Elements.Stand_Rarity.Text = data.CurrentPowerRarity
    if data.CurrentPowerRarity == "Common" then
        defs.Stand_Reveal.Elements.Stand_Rarity.TextColor3 = Color3.new(255/255, 255/255, 255/255)
    elseif data.CurrentPowerRarity == "Rare" then
        defs.Stand_Reveal.Elements.Stand_Rarity.TextColor3 = Color3.new(10/255, 202/255, 0/255)
    elseif data.CurrentPowerRarity == "Legendary" then
        defs.Stand_Reveal.Elements.Stand_Rarity.TextColor3 = Color3.new(255/255, 149/255, 43/255)
    end

    -- clear old icons out of the container
    defs.Stand_Reveal.Elements.Icon_Frame.Icon_Container:ClearAllChildren()

    print(data.CurrentPower)
    -- clone in a new icon
    local newIcon = mainGui.Stand_Icons:FindFirstChild(data.CurrentPower):Clone()
    newIcon.Visible = true
    newIcon.Parent = defs.Stand_Reveal.Elements.Icon_Frame.Icon_Container

    self:Show_StandReveal()

end

--// Show_StandReveal ------------------------------------------------------------
function GuiController:Show_StandReveal()

    -- create some new rays, so we leave to originals in place
    local newRay_1 = defs.Stand_Reveal.Elements.Rays_1:Clone()
    local newRay_2 = defs.Stand_Reveal.Elements.Rays_2:Clone()
    newRay_1.Parent = defs.Stand_Reveal.Main_Frame
    newRay_2.Parent = defs.Stand_Reveal.Main_Frame
    newRay_1.Name = "TempRay"
    newRay_2.Name = "TempRay"

    -- save some final sizes for elements
    local finalIconFrame_Size = defs.Stand_Reveal.Elements.Icon_Frame.Size
    local finalName_Size = defs.Stand_Reveal.Elements.Stand_Name.Size
    local finalRays_1_Size = defs.Stand_Reveal.Elements.Rays_1.Size
    local finalRays_2_Size = defs.Stand_Reveal.Elements.Rays_2.Size

    --now lets make them all smaller so we can pop them
    defs.Stand_Reveal.Elements.Icon_Frame.Size = UDim2.new(0, 0, 0, 0)
    defs.Stand_Reveal.Elements.Stand_Name.Size = UDim2.new(0, 0, 0, 0)
    defs.Stand_Reveal.Elements.Rays_1.Size = UDim2.new(0, 0, 0, 0)
    defs.Stand_Reveal.Elements.Rays_1.Size = UDim2.new(0, 0, 0, 0)

    -- tweens 
    local tweenInfo_Size = TweenInfo.new(.5,Enum.EasingStyle.Bounce)
    local sizeTween_IconFrame = TweenService:Create(defs.Stand_Reveal.Elements.Icon_Frame,tweenInfo_Size,{Size = finalIconFrame_Size})
    local sizeTween_Name = TweenService:Create(defs.Stand_Reveal.Elements.Stand_Name,tweenInfo_Size,{Size = finalName_Size})
    local sizeTween_Rays_1 = TweenService:Create(defs.Stand_Reveal.Elements.Rays_1,tweenInfo_Size,{Size = finalRays_1_Size})
    local sizeTween_Rays_2 = TweenService:Create(defs.Stand_Reveal.Elements.Rays_2,tweenInfo_Size,{Size = finalRays_2_Size})
    local spinTween_Rays_1 = TweenService:Create(newRay_1,TweenInfo.new(40,Enum.EasingStyle.Linear),{Rotation = 359})
    local spinTween_Rays_2 = TweenService:Create(newRay_2,TweenInfo.new(60,Enum.EasingStyle.Linear),{Rotation = -359})

    sizeTween_IconFrame:Play()
    sizeTween_Name:Play()
    sizeTween_Rays_1:Play()
    sizeTween_Rays_2:Play()
    spinTween_Rays_1:Play()
    spinTween_Rays_2:Play()


    spinTween_Rays_1.Completed:Connect(function(playbackState)
        if playbackState == Enum.PlaybackState.Completed then
            self:StandReveal_ActivateClose()
        end
    end)

    -- make the whole thing visible
    defs.Stand_Reveal.Main_Frame.Visible = true
    defs.Stand_Reveal.Elements.Icon_Frame.Visible = true
    defs.Stand_Reveal.Elements.Button_Frame.Visible = true
    defs.Stand_Reveal.Elements.Stand_Name.Visible = true
    defs.Stand_Reveal.Elements.Stand_Rarity.Visible = true
    newRay_1.Visible = true
    newRay_2.Visible = true

end

--// Close_StandReveal ------------------------------------------------------------
function GuiController:StandReveal_ActivateClose()

    -- destroy the TempRays
    for _,object in pairs(defs.Stand_Reveal.Main_Frame:GetChildren()) do
        if object.Name == "TempRay" then
            object:Destroy()
        end
    end

    -- make it invisible
    defs.Stand_Reveal.Main_Frame.Visible = false -- just turn off the stand reveal frame. The player already has stand equipped
end


--// ====================================================================================================================================
--//  GENERAL UTILITY
--// ====================================================================================================================================

--// Request_GuiUpdate ------------------------------------------------------------
function GuiController:Request_GuiUpdate(requestName)
    GuiService:Request_GuiUpdate(requestName)
end

--// ====================================================================================================================================
--//  KNIT
--// ====================================================================================================================================

--// KnitStart ------------------------------------------------------------
function GuiController:KnitStart()

    -- do some setups
    self:Setup_PowerButton()
    self:Setup_LeftGui()
    self:Setup_MainWindow()
    self:Setup_ArrowPanel()
    self:Setup_StandReveal()

    -- request Gui Updates
    self:Request_GuiUpdate("ArrowPanel")
    self:Request_GuiUpdate("Cash")
    self:Request_GuiUpdate("Character")


    -- connect events
    GuiService.Event_Update_ArrowPanel:Connect(function(data)
        self:Update_ArrowPanel(data)
    end)

    GuiService.Event_Update_Cash:Connect(function(value)
        self:Update_Cash(value)
    end)

    GuiService.Event_Update_Character:Connect(function(data)
        self:Update_Character(data)
    end)

    GuiService.Event_Update_StandReveal:Connect(function(data)
        self:Update_StandReveal(data)
    end)

end

--// KnitInit ------------------------------------------------------------
function GuiController:KnitInit()

end


return GuiController