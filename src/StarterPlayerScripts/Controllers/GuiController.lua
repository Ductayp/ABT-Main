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
GuiController.ItemFinderWindow = require(Knit.GuiModules.ItemFinderWindow)
GuiController.StoragePanel = require(Knit.GuiModules.StoragePanel)
GuiController.ItemPanel = require(Knit.GuiModules.ItemPanel)
GuiController.BoostPanel = require(Knit.GuiModules.BoostPanel)
GuiController.StandReveal = require(Knit.GuiModules.StandReveal)
GuiController.BottomGui = require(Knit.GuiModules.BottomGui)
GuiController.LeftGui = require(Knit.GuiModules.LeftGui)
GuiController.RightGui = require(Knit.GuiModules.RightGui)
GuiController.Notifications = require(Knit.GuiModules.Notifications)
GuiController.CurrencyBar = require(Knit.GuiModules.CurrencyBar)
GuiController.SettingsWindow = require(Knit.GuiModules.SettingsWindow)
GuiController.CodesWindow = require(Knit.GuiModules.CodesWindow)
GuiController.NPCDialogueWindow = require(Knit.GuiModules.NPCDialogueWindow)
GuiController.ShopWindow = require(Knit.GuiModules.ShopWindow)
GuiController.ShopWindow_LootPanel = require(Knit.GuiModules.ShopWindow_LootPanel)
GuiController.ShopWindow_StoragePanel = require(Knit.GuiModules.ShopWindow_StoragePanel)
GuiController.ShopWindow_PassesPanel = require(Knit.GuiModules.ShopWindow_PassesPanel)

GuiController.InDialogue = false -- this is a variable we can check from anywhere to see if the player is in a dialgue gui
GuiController.CurrentWindow = nil

-- Gui Defs
local mainGui = PlayerGui:WaitForChild("MainGui", 120)

--// ToggleDialogue
function GuiController:ToggleDialogue(boolean)

    GuiController.InDialogue = boolean
    GuiService:DialogueLock(boolean)

end

--// CloseAllWindows ------------------------------------------------------------
function GuiController:CloseAllWindows()
    for _,instance in pairs(mainGui.Windows.ScaleFrame:GetChildren()) do
        if instance:IsA("Frame") then
            instance.Visible = false
        end
    end
    GuiController.CurrentWindow = nil
end


--// Request_GuiUpdate ------------------------------------------------------------
function GuiController:Request_GuiUpdate(requestName)
    GuiService:Request_GuiUpdate(requestName)
end

--// TimerLoop
function GuiController:TimerLoop()
    spawn(function()
        local lastUpdate = 0
        while game:GetService("RunService").Heartbeat:Wait() do
            if lastUpdate < os.clock() - 1 then
                for _, module in pairs(Knit.GuiModules:GetChildren()) do
                    local thisModule = require(module)
                    if thisModule.UpdateTimer then
                        thisModule.UpdateTimer()
                    end
                end
                lastUpdate = os.clock()
            end
        end
    end)
end


--// KnitStart ------------------------------------------------------------
function GuiController:KnitStart()

    repeat wait() until Players.LocalPlayer.Character
    repeat wait() until Players.LocalPlayer.PlayerGui

    -- do some setups
    GuiController.InventoryWindow.Setup()
    GuiController.StoragePanel.Setup()
    GuiController.ItemPanel.Setup()
    GuiController.BoostPanel.Setup()
    GuiController.StandReveal.Setup()
    GuiController.BottomGui.Setup()
    GuiController.LeftGui.Setup()
    GuiController.RightGui.Setup()
    GuiController.Notifications.Setup()
    GuiController.SettingsWindow.Setup()
    GuiController.CodesWindow.Setup()
    GuiController.NPCDialogueWindow.Setup()
    GuiController.ShopWindow.Setup()
    GuiController.ShopWindow_LootPanel.Setup()
    GuiController.ShopWindow_StoragePanel.Setup()
    GuiController.ShopWindow_PassesPanel.Setup()
    GuiController.ItemFinderWindow.Setup()

    -- request Gui Updates
    self:Request_GuiUpdate("Currency")
    self:Request_GuiUpdate("SoulOrb")
    self:Request_GuiUpdate("ItemPanel")
    self:Request_GuiUpdate("ItemFinderWindow")
    self:Request_GuiUpdate("RightGui")

    -- connect events
    GuiService.Event_Update_Notifications:Connect(function(params)
        GuiController.Notifications.Update(params)
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

    GuiService.Event_Update_StoragePanel:Connect(function(currentStand, storageData, hasGamePass, isInZone)
        GuiController.StoragePanel.Update(currentStand, storageData, hasGamePass, isInZone)
    end)

    GuiService.Event_Update_Cooldown:Connect(function(params)
        GuiController.BottomGui.UpdateCooldown(params)
    end)

    GuiService.Event_Update_ItemPanel:Connect(function(data)
        GuiController.ItemPanel.Update(data)
    end)

    GuiService.Event_Update_BoostPanel:Connect(function(data)
        GuiController.BoostPanel.Update(data)
    end)

    GuiService.Event_Update_ItemFinderWindow:Connect(function(hasGamePass, hasBoost, expirationTime)
        GuiController.ItemFinderWindow.Update(hasGamePass, hasBoost, expirationTime)
    end)

    GuiService.Event_Update_RightGui:Connect(function(pvpToggle, params)
        GuiController.RightGui.Update(pvpToggle, params)
    end)

    self:TimerLoop()

end

--// KnitInit ------------------------------------------------------------
function GuiController:KnitInit()

end


return GuiController