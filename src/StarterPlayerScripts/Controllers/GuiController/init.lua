-- GUI controller

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer.PlayerGui
local StarterGui = game:GetService("StarterGui")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local GuiController = Knit.CreateController { Name = "GuiController" }
local GuiService = Knit.GetService("GuiService")

local utils = require(Knit.Shared.Utils)

GuiController.InDialogue = false -- this is a variable we can check from anywhere to see if the player is in a dialgue gui
GuiController.CurrentWindow = nil

-- build table of gui modules
GuiController.Modules = {}
for i, v in pairs(Knit.GuiModules:GetChildren()) do
    if v:IsA("ModuleScript") then
        GuiController.Modules[v.Name] = require(v)
    end
end

local mainGui = PlayerGui:WaitForChild("MainGui", 120)

--// ToggleMainMenu
function GuiController:ToggleMainMenu()

end

--// ToggleDialogue ------------------------------------------------------------
function GuiController:ToggleDialogue(boolean)
    GuiController.InDialogue = boolean
    GuiService:DialogueLock(boolean)
end

--// CloseAllWindows ------------------------------------------------------------
function GuiController:CloseAllWindows()
    for _,instance in pairs(mainGui.Windows:GetChildren()) do
        if instance:IsA("Frame") then
            instance.Visible = false
        end
    end
    GuiController.CurrentWindow = nil
end

--// PlayerSpawn -- fired when a player teleports/respawns using the cusotm spawn service -----------------------------------------------------
function GuiController:PlayerTransported()
    self:CloseAllWindows()
    self:ToggleDialogue(false)
end


--// KnitStart ------------------------------------------------------------
function GuiController:KnitStart()

    repeat wait() until Players.LocalPlayer.Character
    repeat wait() until Players.LocalPlayer.PlayerGui

    -- make sure the players data is loaded
    local playerDataStatuses = ReplicatedStorage:WaitForChild("PlayerDataLoaded")
    local playerDataBoolean = playerDataStatuses:WaitForChild(Players.LocalPlayer.UserId)
    repeat wait(1) until playerDataBoolean.Value == true -- wait until the value is true, this is set by PlayerDataService when the data is fully loaded for this player

    for i, v in pairs(GuiController.Modules) do
        if v.Setup() then
            v.Setup()
        end
    end

    -- connect events
    GuiService.Event_Update_Notifications:Connect(function(params)
        GuiController.Modules.Notifications.Update(params)
    end)

    GuiService.Event_Update_Currency:Connect(function(data)
        GuiController.Modules.CurrencyBar.Update(data)
        GuiController.Modules.NPCShop.Update(data)
    end)

    GuiService.Event_Update_StandData:Connect(function(data, params)
        GuiController.Modules.StandData.Update(data, params)
    end)

    GuiService.Event_Update_StandReveal:Connect(function(standData, params)
        GuiController.Modules.StandReveal.Update(standData, params)
    end)

    GuiService.Event_Update_StoragePanel:Connect(function(currentStand, storageData, hasGamePass, isInZone)
        GuiController.Modules.Storage.Update(currentStand, storageData, hasGamePass, isInZone)
    end)

    GuiService.Event_Update_StoragePanel_Access:Connect(function(hasGamePass, isInZone)
        GuiController.Modules.Storage.Update_Access(hasGamePass, isInZone)
    end)

    GuiService.Event_Update_Cooldown:Connect(function(params)
        GuiController.Modules.AbilityBar.UpdateCooldown(params)
    end)

    GuiService.Event_Update_AbilityBar:Connect(function(params)
        GuiController.Modules.AbilityBar.Update(params)
    end)

    GuiService.Event_Update_ItemPanel:Connect(function(data)
        GuiController.Modules.Items.Update(data)
        GuiController.Modules.NPCDungeon.UpdateKeys(data)
    end)

    GuiService.Event_Update_DungeonTimes:Connect(function(data)
        GuiController.Modules.NPCDungeon.UpdateDungeonTimes(data)
        GuiController.Modules.DungeonTimer.UpdateDungeonTimes(data)
    end)

    GuiService.Event_Update_CraftingWindow:Connect(function(inventoryData, currencyData)
        GuiController.Modules.Crafting.Update(inventoryData, currencyData)
    end)

    GuiService.Event_Update_ItemFinderWindow:Connect(function(hasGamePass, mapZone)
        GuiController.Modules.ItemFinder.Update(hasGamePass, mapZone)
    end)

    GuiService.Event_Update_PvPToggle:Connect(function(pvpToggle, params)
        GuiController.Modules.MainMenu.Update_PvPButton(pvpToggle, params)
    end)

    GuiService.Event_ToggleGUI:Connect(function(boolean)
        GuiController.Modules.ToggleGUI.Toggle(boolean)
    end)

    GuiService.Event_PlayerTransported:Connect(function()
       self:PlayerTransported()
    end)

    GuiService.Event_ToggleDungeonTimer:Connect(function(boolean, dungeonId)
        GuiController.Modules.DungeonTimer.ToggleTimer(boolean, dungeonId)
     end)
    

end

--// KnitInit ------------------------------------------------------------
function GuiController:KnitInit()

    StarterGui:SetCore("ChatWindowPosition", UDim2.new(0,0,0.2,0))

end


return GuiController