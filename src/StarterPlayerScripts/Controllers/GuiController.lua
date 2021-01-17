-- GUI controller
-- PDab
-- 12 / 15/ 2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
local powerUtils = require(Knit.Shared.PowerUtils)

-- gui modules
GuiController.InventoryWindow = require(Knit.GuiModules.InventoryWindow)
GuiController.StoragePanel = require(Knit.GuiModules.StoragePanel)
GuiController.ArrowPanel = require(Knit.GuiModules.ArrowPanel)
GuiController.StandReveal = require(Knit.GuiModules.StandReveal)
GuiController.BottomGui = require(Knit.GuiModules.BottomGui)
GuiController.LeftGui = require(Knit.GuiModules.LeftGui)
GuiController.Notifications = require(Knit.GuiModules.Notifications)

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

--// KnitStart ------------------------------------------------------------
function GuiController:KnitStart()

    -- do some setups
    GuiController.InventoryWindow.Setup()
    GuiController.StoragePanel.Setup()
    GuiController.ArrowPanel.Setup()
    GuiController.StandReveal.Setup()
    GuiController.BottomGui.Setup()
    GuiController.LeftGui.Setup()
    GuiController.Notifications.Setup()
    
    GuiController.ShopWindow.Setup()
    GuiController.ShopWindow_LootPanel.Setup()
    GuiController.ShopWindow_StoragePanel.Setup()
    GuiController.ShopWindow_PassesPanel.Setup()


    -- request Gui Updates
    self:Request_GuiUpdate("ArrowPanel")
    self:Request_GuiUpdate("Currency")
    self:Request_GuiUpdate("SoulOrb")
    self:Request_GuiUpdate("StoragePanel")
    self:Request_GuiUpdate("BottomGUI")


    -- connect events
    GuiService.Event_Update_Notifications:Connect(function(params)
        GuiController.Notifications.Update(params)
    end)

    GuiService.Event_Update_ArrowPanel:Connect(function(data)
        GuiController.ArrowPanel.Update(data)
    end)

    GuiService.Event_Update_Currency:Connect(function(value)
        GuiController.ShopWindow.Update_Currency(value)
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

end

--// KnitInit ------------------------------------------------------------
function GuiController:KnitInit()

end


return GuiController