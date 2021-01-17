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
GuiService.Client.Event_Update_ArrowPanel = RemoteEvent.new()
GuiService.Client.Event_Update_Currency = RemoteEvent.new()
GuiService.Client.Event_Update_BottomGUI = RemoteEvent.new()
GuiService.Client.Event_Update_StandReveal = RemoteEvent.new()
GuiService.Client.Event_Update_StoragePanel = RemoteEvent.new()



--// Update_Notifications
function GuiService:Update_Notifications(player, params)
    self.Client.Event_Update_Notifications:Fire(player, params)
end

--// Update_Gui
function GuiService:Update_Gui(player, requestName, optionalParams)

    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

    if requestName == "ArrowPanel" then
        self.Client.Event_Update_ArrowPanel:Fire(player, playerData.ArrowInventory)
    end

    if requestName == "Currency" then
        self.Client.Event_Update_Currency:Fire(player, playerData.Currency)
    end

    if requestName == "BottomGUI" then
        self.Client.Event_Update_BottomGUI:Fire(player, playerData.CurrentStand)
    end

    if requestName == "StandReveal" then
        self.Client.Event_Update_StandReveal:Fire(player, playerData.CurrentStand)
    end

    if requestName == "StoragePanel" then 
        self.Client.Event_Update_StoragePanel:Fire(player, playerData.CurrentStand, playerData.StandStorage)
    end
end

--// Client.Request_GuiUpdate
function GuiService.Client:Request_GuiUpdate(player, requestName)
    self.Server:Update_Gui(player, requestName) 
end

--// PlayerAdded
function GuiService:PlayerAdded(player)
    -- nothing here 
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
        --self:PlayerRemoved(player)
    end)

end


return GuiService