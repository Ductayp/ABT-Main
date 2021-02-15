-- GUI controller
-- PDab
-- 12 / 15/ 2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer.PlayerGui


-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local GuiController = Knit.CreateController { Name = "GuiController" }
local GuiService = Knit.GetService("GuiService")
local InventoryService = Knit.GetService("InventoryService")
local PowersService = Knit.GetService("PowersService")
local GamePassService = Knit.GetService("GamePassService")

-- utility modules
local utils = require(Knit.Shared.Utils)

-- gui modules
GuiController.InventoryWindow = require(Knit.GuiModules.InventoryWindow)
GuiController.StoragePanel = require(Knit.GuiModules.StoragePanel)
GuiController.ArrowPanel = require(Knit.GuiModules.ArrowPanel)
GuiController.StandReveal = require(Knit.GuiModules.StandReveal)
GuiController.BottomGui = require(Knit.GuiModules.BottomGui)
GuiController.LeftGui = require(Knit.GuiModules.LeftGui)
GuiController.Notifications = require(Knit.GuiModules.Notifications)
GuiController.CurrencyBar = require(Knit.GuiModules.CurrencyBar)
GuiController.SettingsWindow = require(Knit.GuiModules.SettingsWindow)
GuiController.CodesWindow = require(Knit.GuiModules.CodesWindow)

GuiController.ShopWindow = require(Knit.GuiModules.ShopWindow)
GuiController.ShopWindow_LootPanel = require(Knit.GuiModules.ShopWindow_LootPanel)
GuiController.ShopWindow_StoragePanel = require(Knit.GuiModules.ShopWindow_StoragePanel)
GuiController.ShopWindow_PassesPanel = require(Knit.GuiModules.ShopWindow_PassesPanel)

-- Gui Defs
local mainGui = PlayerGui:WaitForChild("MainGui", 120)

--// CloseAllWindows ------------------------------------------------------------
function GuiController:CloseAllWindows()
    for _,instance in pairs(mainGui.Windows.ScaleFrame:GetChildren()) do
        if instance:IsA("Frame") then
            instance.Visible = false
        end
    end
end


--// Request_GuiUpdate ------------------------------------------------------------
function GuiController:Request_GuiUpdate(requestName)
    GuiService:Request_GuiUpdate(requestName)
end

--// HandleAction - ContextActionService
GuiController.ButtonHover = false
function GuiController:HandleHover(bool)
    GuiController.ButtonHover = bool
end


--// KnitStart ------------------------------------------------------------
function GuiController:KnitStart()

    repeat wait() until Players.LocalPlayer.Character
    repeat wait() until Players.LocalPlayer.PlayerGui
    print("FOUND IT!!!!")

    -- setup Hover handling for Gui buttons
    for _, instance in pairs(Players.LocalPlayer.PlayerGui:GetDescendants()) do
        if instance:IsA("TextButton") or instance:IsA("ImageButton") or instance:IsA("Frame") then

            instance.MouseEnter:Connect(function()
                self:HandleHover(true)
            end)
            
            instance.MouseLeave:Connect(function()
                self:HandleHover(false)
            end)
        end
    end

    -- do some setups
    GuiController.InventoryWindow.Setup()
    GuiController.StoragePanel.Setup()
    GuiController.ArrowPanel.Setup()
    GuiController.StandReveal.Setup()
    GuiController.BottomGui.Setup()
    GuiController.LeftGui.Setup()
    GuiController.Notifications.Setup()
    GuiController.SettingsWindow.Setup()
    GuiController.CodesWindow.Setup()
    
    GuiController.ShopWindow.Setup()
    GuiController.ShopWindow_LootPanel.Setup()
    GuiController.ShopWindow_StoragePanel.Setup()
    GuiController.ShopWindow_PassesPanel.Setup()


    -- request Gui Updates
    self:Request_GuiUpdate("ArrowPanel")
    self:Request_GuiUpdate("Currency")
    self:Request_GuiUpdate("SoulOrb")
    --self:Request_GuiUpdate("StoragePanel") -- not required because PowerService updates this gui on startup when it sets the CurrentPower
    --self:Request_GuiUpdate("BottomGUI") -- not required because PowerService updates this gui on startup when it sets the CurrentPower


    -- connect events
    GuiService.Event_Update_Notifications:Connect(function(params)
        GuiController.Notifications.Update(params)
    end)

    GuiService.Event_Update_ArrowPanel:Connect(function(data)
        GuiController.ArrowPanel.Update(data)
    end)

    GuiService.Event_Update_Currency:Connect(function(data)
        GuiController.ShopWindow.Update_Currency(data)
        GuiController.CurrencyBar.Update(data)
    end)

    GuiService.Event_Update_BottomGUI:Connect(function(data)
        GuiController.BottomGui.Update(data)
    end)

    GuiService.Event_Update_StandReveal:Connect(function(data)
        GuiController.StandReveal.Update(data)
    end)

    GuiService.Event_Update_StoragePanel:Connect(function(currentStand, storageData)
        GuiController.StoragePanel.Update(currentStand, storageData)
    end)

    GuiService.Event_Update_Cooldown:Connect(function(params)
        GuiController.BottomGui.UpdateCooldown(params)
    end)

end

--// KnitInit ------------------------------------------------------------
function GuiController:KnitInit()

end


return GuiController