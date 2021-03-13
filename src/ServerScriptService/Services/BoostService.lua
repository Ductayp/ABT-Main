-- BoostService
-- PDab
-- 2/12/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local BoostService = Knit.CreateService { Name = "BoostService", Client = {}}

-- modules
local utils = require(Knit.Shared.Utils)
local Timer = require(Knit.Shared.TimerModule)

-- public variables
BoostService.PlayerTimers = {}

--// AddBoost
function BoostService:AddBoost(player, boostName, duration)

    -- get thisBoostDef
    local thisBoostDef = BoostService.PlayerTimers[player.UserId][boostName]
    if not thisBoostDef then
        print("BoostService:AddBoost - Boost Def not found")
        return
    end

    -- see if there is a timerobject in the bostdef, make it if not
    if not thisBoostDef.TimerObject then
        thisBoostDef.TimerObject = Timer.new(duration)
        thisBoostDef.TimerObject:Start()
        thisBoostDef.TimerObject:OnFinished(function()
            self:UpdateGui(player)
        end)
    elseif thisBoostDef.TimerObject:GetState() == "Dead" then
        thisBoostDef.TimerObject = Timer.new(duration)
        thisBoostDef.TimerObject:Start()
        thisBoostDef.TimerObject:OnFinished(function()
            self:UpdateGui(player)
        end)
    else
        local timeRemaining = thisBoostDef.TimerObject:GetRemaining()
        local newDuration = timeRemaining + duration
        thisBoostDef.TimerObject:IncrementTime(newDuration)
    end

    self:UpdateGui(player)
end

--// UpdateGui
function BoostService:UpdateGui(player)

    print("ALL OF THE", BoostService.PlayerTimers[player.userId])

    local guiDefs = {}

    for boostName, boostDefs in pairs(BoostService.PlayerTimers[player.userId]) do

        local timeLeft
        local timerState
        if boostDefs.TimerObject == nil then
            timeLeft = 0
            isRunning = false
        else
            timerState = boostDefs.TimerObject:GetState()
            if timerState == "Running" then
                timeLeft = boostDefs.TimerObject:GetRemaining()
                isRunning = true
            elseif timerState == "Paused" then
                timeLeft = boostDefs.TimerObject:GetRemaining()
                isRunning = false
            else
                timeLeft = 0
                isRunning = false
            end
        end

        local thisDef = {}
        thisDef.BoostName = boostName
        thisDef.TimeRemaining = timeLeft
        thisDef.TimeEnding = os.time() + timeLeft
        thisDef.TimerState = timerState
        table.insert(guiDefs, thisDef)

    end

    Knit.Services.GuiService:Update_Gui(player, "BoostPanel", guiDefs)
end

--// Has_Boost
function BoostService:Has_Boost(player, boostName, BoostValue)
    --print("BoostService:Has_Boost", player, boostName, BoostValue)
end

--// Cient:Has_Boost
function BoostService.Client:Has_Boost(player, boostName, BoostValue)
    self.Server:Has_Boost(player, boostName, BoostValue)
end

--// FinalSaveOnLeave - this is fied from ProfileService, we do it there intead of here to be sure it happens before the profiles final save
function BoostService:FinalSaveOnLeave(player)

    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

    for boostName, boostDefs in pairs(BoostService.PlayerTimers[player.userId]) do

        local timeLeft = 0
        if boostDefs.TimerObject~= nil then
            local timerState = boostDefs.TimerObject:GetState()
            if timerState == "Running" or timerState == "Paused" then
                timeLeft = boostDefs.TimerObject:GetRemaining()
            end
        end

        playerData.BoostTimeRemaining[boostName] = timeLeft

    end

    -- remove player entry in the timer table
    BoostService.PlayerTimers[player.UserId] = nil

    print("FINAL PLAYERDATA", playerData)

end

--// PlayerAdded
function BoostService:PlayerAdded(player)

    -- make sure the players data is loaded
    local playerDataStatuses = ReplicatedStorage:WaitForChild("PlayerDataLoaded")
    local playerDataBoolean = playerDataStatuses:WaitForChild(player.UserId)
    repeat wait(1) until playerDataBoolean.Value == true -- wait until the value is true, this is set by PlayerDataService when the data is fully loaded for this player

    -- create an entry for the player in the timer table
    BoostService.PlayerTimers[player.UserId] = {}

    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

    -- first we will make a table entry for this boost
    for boostName, boostDuration in pairs(playerData.BoostTimeRemaining) do
        BoostService.PlayerTimers[player.UserId][boostName] = {}
    end

    -- second we will then addbost based on what the save values are
    for boostName, boostDuration in pairs(playerData.BoostTimeRemaining) do
        self:AddBoost(player, boostName, boostDuration)
    end

end

--// PlayerRemoved
function BoostService:PlayerRemoved(player)

    -- do not remove the players table here! It is removed after final save initiated from PlayerDataService

end
   
--// KnitStart
function BoostService:KnitStart()

end

--// KnitInit
function BoostService:KnitInit()

    -- create a boost folder
    local boostFolder = Instance.new("Folder")
    boostFolder.Name = "BoostService"
    boostFolder.Parent = ReplicatedStorage

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


return BoostService