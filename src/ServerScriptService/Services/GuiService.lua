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
GuiService.Client.Event_Update_ArrowPanel = RemoteEvent.new()
GuiService.Client.Event_Update_Cash = RemoteEvent.new()
GuiService.Client.Event_Update_Character = RemoteEvent.new()
GuiService.Client.Event_Update_StandReveal = RemoteEvent.new()
GuiService.Client.Event_Update_StoragePanel = RemoteEvent.new()

--// Update_Gui
function GuiService:Update_Gui(player, requestName, optionalParams)

    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

    if requestName == "ArrowPanel" then
        self.Client.Event_Update_ArrowPanel:Fire(player,playerData.ArrowInventory)
    end
    if requestName == "Cash" then
        self.Client.Event_Update_Cash:Fire(player,playerData.ItemInventory.Cash)
    end
    if requestName == "Character" then
        self.Client.Event_Update_Character:Fire(player,playerData.Character)
    end
    if requestName == "StandReveal" then
        self.Client.Event_Update_StandReveal:Fire(player,playerData.Character)
    end
    if requestName == "StoragePanel" then 
        print("yes")
        self.Client.Event_Update_StoragePanel:Fire(player, playerData.Character, playerData.StandStorage)
    end
end

--// Client.Request_GuiUpdate
function GuiService.Client:Request_GuiUpdate(player, requestName)
    self.Server:Update_Gui(player, requestName) 
end

--// PlayerAdded
function GuiService:PlayerAdded(player)

    --[[
    -- make sure the players data is loaded
    local playerDataStatuses = ReplicatedStorage:WaitForChild("PlayerDataLoaded")
    local playerDataBoolean = playerDataStatuses:WaitForChild(player.UserId)
    repeat wait(1) until playerDataBoolean.Value == true -- wait until the value is true
    ]]--

end


--// KnitStart
function GuiService:KnitStart()
    
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