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
GuiService.Client.Event_Update_Cooldown = RemoteEvent.new()
GuiService.Client.Event_Update_ItemPanel = RemoteEvent.new()
GuiService.Client.Event_Update_ItemFinderWindow = RemoteEvent.new()

-- public variables
GuiService.DialogueLocked = {}

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

    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

    if requestName == "Currency" then
        self.Client.Event_Update_Currency:Fire(player, playerData.Currency)
    end

    if requestName == "BottomGUI" then
        local data = {}
        data.CurrentStand = playerData.CurrentStand
        data.XpData = Knit.Services.PowersService:GetXpData(playerData.CurrentStand.Xp, playerData.CurrentStand.Rarity)
        data.CurrentHealth = player.Character.Humanoid.Health
        data.MaxHealth = require(Knit.StateModules.Health).GetMaxHealth(player)
        self.Client.Event_Update_BottomGUI:Fire(player, data)
    end

    if requestName == "StandReveal" then
        self.Client.Event_Update_StandReveal:Fire(player, playerData.CurrentStand)
    end

    if requestName == "StoragePanel" then 
        self.Client.Event_Update_StoragePanel:Fire(player, playerData.CurrentStand, playerData.StandStorage)
    end

    if requestName == "ItemPanel" then 
        self.Client.Event_Update_ItemPanel:Fire(player, playerData.ItemInventory)
    end

    if requestName == "ItemFinderWindow" then 

        local hasGamePass = Knit.Services.GamePassService:Has_GamePass(player, "ItemFinder")
        local hasBoost, expirationTime = Knit.Services.BoostService:Has_Boost(player, "ItemFinder")
        self.Client.Event_Update_ItemFinderWindow:Fire(player, hasGamePass, hasBoost, expirationTime)
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
end

function GuiService:PlayerRemoved(player)
    GuiService.DialogueLocked[player.UserId] = nil
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