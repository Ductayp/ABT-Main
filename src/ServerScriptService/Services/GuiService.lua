-- Gui Service
-- PDab
-- 12/20/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local GuiService = Knit.CreateService { Name = "GuiService", Client = {}}
local RemoteEvent = require(Knit.Util.Remote.RemoteEvent)

-- modules
local utils = require(Knit.Shared.Utils)

-- events
GuiService.Client.Event_Update_Notifications = RemoteEvent.new()
GuiService.Client.Event_Update_Currency = RemoteEvent.new()
GuiService.Client.Event_Update_BottomGUI = RemoteEvent.new()
GuiService.Client.Event_Update_StandReveal = RemoteEvent.new()
GuiService.Client.Event_Update_StoragePanel = RemoteEvent.new()
GuiService.Client.Event_Update_StoragePanel_Access = RemoteEvent.new()
GuiService.Client.Event_Update_Cooldown = RemoteEvent.new()
GuiService.Client.Event_Update_ItemPanel = RemoteEvent.new()
GuiService.Client.Event_Update_ItemFinderWindow = RemoteEvent.new()
GuiService.Client.Event_Update_BoostPanel = RemoteEvent.new()
GuiService.Client.Event_Update_RightGui = RemoteEvent.new()

-- public variables
GuiService.DialogueLocked = {}
GuiService.PvPToggles = {}

function GuiService:PvpToggle(player)
    --return GuiService.PvPToggles[player.UserId]
end

function GuiService:TogglePvP(player)

    local canToggle = false
    local isInSafezone = Knit.Services.ZoneService:IsPlayerInZone(player, "SafeZone") -- only allow toggling only in safe zone 
    if isInSafezone then
        print("IN SAFE ZONE")
        canToggle = true
        if  GuiService.PvPToggles[player.UserId] == true then
            GuiService.PvPToggles[player.UserId] = false
            Knit.Services.StateService:AddEntryToState(player, "Invulnerable", "GuiService", true)
            Knit.Services.StateService:RemoveEntryFromState(player, "Multiplier_Experience", "GuiService")
            --Knit.Services.StateService:RemoveEntryFromState(player, "Multiplier_Cash", "GuiService")
            --Knit.Services.StateService:RemoveEntryFromState(player, "Multiplier_Orbs", "GuiService")
        else
            GuiService.PvPToggles[player.UserId] = true
            Knit.Services.StateService:RemoveEntryFromState(player, "Invulnerable", "GuiService")
            Knit.Services.StateService:AddEntryToState(player, "Multiplier_Experience", "GuiService", 2)
            --Knit.Services.StateService:AddEntryToState(player, "Multiplier_Cash", "GuiService", 2)
            --Knit.Services.StateService:AddEntryToState(player, "Multiplier_Orbs", "GuiService", 2)
        end
    end

    local params = {CanToggle = canToggle}
    self:Update_Gui(player, "RightGui", params)

end

function GuiService.Client:TogglePvP(player)
    self.Server:TogglePvP(player)
end

--// DialogueLock
function GuiService:DialogueLock(player, isLock)

    GuiService.DialogueLocked[player.UserId] = isLock

    if isLock then
        player.Character.HumanoidRootPart.Anchored = true
        Knit.Services.StateService:AddEntryToState(player, "Invulnerable", "DialogueLock", true)
    else
        player.Character.HumanoidRootPart.Anchored = false
        Knit.Services.StateService:RemoveEntryFromState(player, "Invulnerable", "DialogueLock")
    end
    
end

--// Client:DialogueLock
function GuiService.Client:DialogueLock(player, boolean)
    self.Server:DialogueLock(player, boolean)
end

--// Update_Cooldown
function GuiService:Update_Cooldown(player, params)
    self.Client.Event_Update_Cooldown:Fire(player, params)
end

--// Update_Notifications
function GuiService:Update_Notifications(player, params)
    self.Client.Event_Update_Notifications:Fire(player, params)
end

--// Update_Gui
function GuiService:Update_Gui(player, requestName, optionalParams)

    --print("GuiService:Update_Gui", player, requestName, optionalParams)

    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    if not playerData then
        return
    end

    if requestName == "Currency" then
        self.Client.Event_Update_Currency:Fire(player, playerData.Currency)
    end

    if requestName == "BottomGUI" then
        local data = {}
        data.CurrentStand = playerData.CurrentStand
        data.CurrentHealth = player.Character.Humanoid.Health
        data.MaxHealth = require(Knit.StateModules.Health).GetMaxHealth(player)
        self.Client.Event_Update_BottomGUI:Fire(player, data, optionalParams)
    end

    if requestName == "StandReveal" then
        optionalParams.HasArrowPass = Knit.Services.GamePassService:Has_GamePass(player, "ArrowLuck")
        self.Client.Event_Update_StandReveal:Fire(player, playerData.CurrentStand, optionalParams)
    end

    if requestName == "StoragePanel" then
        local hasGamePass = Knit.Services.GamePassService:Has_GamePass(player, "MobileStandStorage")
        local isInZone = Knit.Services.ZoneService:IsPlayerInZone(player, "StorageZone")
        self.Client.Event_Update_StoragePanel:Fire(player, playerData.CurrentStand, playerData.StandStorage, hasGamePass, isInZone)
    end

    if requestName == "StoragePanel_Access" then
        local hasGamePass = Knit.Services.GamePassService:Has_GamePass(player, "MobileStandStorage")
        local isInZone = Knit.Services.ZoneService:IsPlayerInZone(player, "StorageZone")
        self.Client.Event_Update_StoragePanel_Access:Fire(player, hasGamePass, isInZone)
    end

    if requestName == "ItemPanel" then 
        self.Client.Event_Update_ItemPanel:Fire(player, playerData.ItemInventory)
    end

    if requestName == "ItemFinderWindow" then 
        local hasGamePass = Knit.Services.GamePassService:Has_GamePass(player, "ItemFinder")
        local hasBoost, expirationTime = Knit.Services.BoostService:Has_Boost(player, "ItemFinder")
        self.Client.Event_Update_ItemFinderWindow:Fire(player, hasGamePass, hasBoost, expirationTime)
    end

    if requestName == "BoostPanel" then
        self.Client.Event_Update_BoostPanel:Fire(player, optionalParams)
    end

    if requestName == "RightGui" then
        self.Client.Event_Update_RightGui:Fire(player, GuiService.PvPToggles[player.UserId], optionalParams)
    end
end

--// Client:Request_GuiUpdate
function GuiService.Client:Request_GuiUpdate(player, requestName)
    self.Server:Update_Gui(player, requestName) 
end

--// Client:GetSettings
function GuiService.Client:GetSettings(player)

end

--// Client:GetSettings
function GuiService.Client:SaveSettings(player)

end

--// PlayerAdded
function GuiService:PlayerAdded(player)
    GuiService.DialogueLocked[player.UserId] = false
    GuiService.PvPToggles[player.UserId] = true
end

function GuiService:PlayerRemoved(player)
    GuiService.DialogueLocked[player.UserId] = nil
    GuiService.PvPToggles[player.UserId] = nil
end


--// KnitStart
function GuiService:KnitStart()
    -- nothing here 
end

--// KnitInit
function GuiService:KnitInit()

    -- Player Added event
    Players.PlayerAdded:Connect(function(player)
        self:PlayerAdded(player)
    end)

    -- Player Added event for studio tesing, catches when a player has joined before the server fully starts
    for _, player in ipairs(Players:GetPlayers()) do
        self:PlayerAdded(player)
    end

    -- Player Removing event
    Players.PlayerRemoving:Connect(function(player)
        self:PlayerRemoved(player)
    end)

end


return GuiService