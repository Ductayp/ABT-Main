-- Powers Service
-- PDab
-- 11/2/2020

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local PowersService = Knit.CreateService { Name = "PowersService", Client = {}}


-- Setup Remote Properties
local RemoteProperty = require(Knit.Util.Remote.RemoteProperty)
PowersService.PlayerProperties = {}
--PowersService.CurrentPower = {}
--PowersService.Cooldowns = {}
--PowersService.AbilityToggles = {}

function PowersService:PlayerAdded(player)
    print(player)
end


function PowersService:KnitInit()

    -- setup some fodler in Workspace
    local effectFolder = Instance.new("Folder")
    effectFolder.Name = "LocalEffects"
    effectFolder.Parent = workspace

    local standFolder = Instance.new("Folder")
    standFolder.Name = "PlayerStands"
    standFolder.Parent = workspace

    -- Player Added event
    Players.PlayerAdded:Connect(PlayerAdded)
        for _, player in ipairs(players:GetPlayers()) do
	    PowersService:PlayerAdded(player)
    end

    -- Player Removing event
    Players.PlayerRemoving:Connect(function(player)

    end)

end

return PowersService