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

--// AddBoost
function BoostService:AddBoost(player, boostName, duration)

    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
    if not playerData.BoostTimers then
        playerData.BoostTimers = {}
    end

    if playerData.BoostTimers[boostName] == nil then
        playerData.BoostTimers[boostName] = 0
    end

    playerData.BoostTimers[boostName] += duration

end

--// UpdateLoop
function BoostService:UpdateLoop()

    spawn(function()
        local lastUpdate = os.time()
        local loopTime = 1
        while game:GetService("RunService").Heartbeat:Wait() do

            if lastUpdate <= (os.time() -loopTime) then
                lastUpdate = os.time()

                for _, player in pairs(Players:GetPlayers()) do

                    local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
                    if playerData ~= nil then
                        if playerData.BoostTimers ~= nil then
                            for boostName,_ in pairs(playerData.BoostTimers) do

                                -- update the counter in player data
                                if playerData.BoostTimers[boostName] > 0 then
                                    playerData.BoostTimers[boostName] = playerData.BoostTimers[boostName] - 1
                                end

                                -- updateStateService
                                self:UpdateStateService(player, boostName, playerData.BoostTimers[boostName])
                            end
                        end 
                    end 
                end
            end
        end
    end)
end

--// Has_Boost
function BoostService:Has_Boost(player, boostName, BoostValue)
    --print("BoostService:Has_Boost", player, boostName, BoostValue)
end

--// Has_Boost
function BoostService.Client:Has_Boost(player, boostName, BoostValue)
    self.Server:Has_Boost(player, boostName, BoostValue)
end

--// PlayerAdded
function BoostService:PlayerAdded(player)

end

--// PlayerRemoved
function BoostService:PlayerRemoved(player)

end
   
--// KnitStart
function BoostService:KnitStart()
    self:UpdateLoop()
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