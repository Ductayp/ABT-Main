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

-- local variables
local boostDefs = require(Knit.Shared.Defs.BoostDefs)
--[[
local boostDefs = {
    DoubleExperience = {
        StateName = "Multiplier_Experience",
        StateValue = 2,
        CashPrice_1 = 1000,
        CashPrice_2 = 5000,
    },
    DoubleCash = {
        StateName = "Multiplier_Cash",
        StateValue = 2,
        CashPrice_1 = 1000,
        CashPrice_2 = 5000,
    },
    DoubleSoulOrbs = {
        StateName = "Multiplier_Orbs",
        StateValue = 2,
        CashPrice_1 = 1000,
        CashPrice_2 = 5000,
    },
    FastWalker = {
        StateName = "WalkSpeed",
        StateValue = 5,
        CashPrice_1 = 1000,
        CashPrice_2 = 5000,
    },
    ItemFinder = {
        StateName = nil, 
        StateValue = nil,
        CashPrice_1 = nil,
        CashPrice_2 = nil,
    },
}
]]--

-- public variables
BoostService.PlayerTimers = {}

--// BuyBoost
function BoostService:BuyBoost(player, currency, boostKey, productId)

    if currency == "Robux" then
        Knit.Services.GamePassService:Prompt_ProductPurchase(player, "Boost_" .. boostKey .. "_" .. productId)
        return
    end

    if currency == "Cash" then

        --print("BuyBoost(player, currency, boostKey, productId)", player, currency, boostKey, productId)

        local thisCost = boostDefs[boostKey]["CashPrice_" .. productId]
        local thisDuration = boostDefs[boostKey]["Duration_" .. productId]

        -- get player data
        local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)

        if playerData.Currency.Cash >= thisCost then
            playerData.Currency.Cash = playerData.Currency.Cash  - thisCost
            Knit.Services.GuiService:Update_Gui(player, "Currency")
            self:AddBoost(player, boostKey, thisDuration)
        else
            print("Cant Afford this Boost")
            return
        end
    end
        
end

--// Client:BuyBoost
function BoostService.Client:BuyBoost(player, currency, boost, productId)
    self.Server:BuyBoost(player, currency, boost, productId)
end

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
            self:ToggleState(player, boostName, false)
        end)
    elseif thisBoostDef.TimerObject:GetState() == "Dead" then
        thisBoostDef.TimerObject = Timer.new(duration)
        thisBoostDef.TimerObject:Start()
        thisBoostDef.TimerObject:OnFinished(function()
            self:UpdateGui(player)
            self:ToggleState(player, boostName, false)
        end)
    else
        local timeRemaining = thisBoostDef.TimerObject:GetRemaining()
        thisBoostDef.TimerObject:IncrementTime(duration)
    end

    self:UpdateGui(player)
    self:ToggleState(player, boostName, true)
end

--// UpdateGui
function BoostService:UpdateGui(player)

    local guiDefs = {}
    for boostName, boostDefs in pairs(BoostService.PlayerTimers[player.userId]) do

        local timeLeft
        if boostDefs.TimerObject == nil then
            timeLeft = 0
        else
            timeLeft = boostDefs.TimerObject:GetRemaining()
        end

        local thisDef = {}
        thisDef.BoostName = boostName
        thisDef.TimeEnding = os.time() + timeLeft
        table.insert(guiDefs, thisDef)
    end

    Knit.Services.GuiService:Update_Gui(player, "BoostPanel", guiDefs)
    Knit.Services.GuiService:Update_Gui(player, "ItemFinderWindow")
end

--// ToggleState
function BoostService:ToggleState(player, boostName, toggleBool)

    --print("BoostService:ToggleState",player, boostName, toggleBool)

    local boostDef = boostDefs[boostName]
    if boostDef.StateName ~= nil then
        if toggleBool == true then
            Knit.Services.StateService:AddEntryToState(player, boostDef.StateName, "BoostService", boostDef.StateValue)
        else
            Knit.Services.StateService:RemoveEntryFromState(player, boostDef.StateName, "BoostService")
        end
    end
end

--// Has_Boost
function BoostService:Has_Boost(player, boostName)

    local hasBoost = false
    
    local thisBoostDef = BoostService.PlayerTimers[player.UserId][boostName]
    if not thisBoostDef then
        print("BoostService:Has_Boost - Boost Def not found")
        return
    end

    if thisBoostDef.TimerObject then
        if thisBoostDef.TimerObject:GetRemaining() > 0 then
            hasBoost = true
        end
    end

    return hasBoost
end

--// Cient:Has_Boost
function BoostService.Client:Has_Boost(player, boostName)
    local hasBoost = self.Server:Has_Boost(player, boostName)
    return hasBoost
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

end
   
--// KnitStart
function BoostService:KnitStart()

end

--// KnitInit
function BoostService:KnitInit()

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