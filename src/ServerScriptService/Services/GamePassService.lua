-- Game Pass Service
-- PDab
-- 12/27/2020

-- services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local GamePassService = Knit.CreateService { Name = "GamePassService", Client = {}}

-- modules
local utils = require(Knit.Shared.Utils)


--// PlayerAdded
function GamePassService:PlayerAdded(player)


end

--// PlayerRemoved
function GamePassService:PlayerRemoved(player)

end

--// KnitStart
function GamePassService:KnitStart()


end

--// KnitInit
function GamePassService:KnitInit()

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

return GamePassService