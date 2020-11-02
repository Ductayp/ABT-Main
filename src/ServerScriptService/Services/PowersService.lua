-- Powers Service
-- PDab
-- 11/2/2020

-- setup Knit
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local PowersService = Knit.CreateService { Name = "PowersService", Client = {}}

function PowersService:KnitInit()

    -- setup some fodler in Workspace
    local effectFolder = Instance.new("Folder")
    effectFolder.Name = "LocalEffects"
    effectFolder.Parent = workspace

    local standFolder = Instance.new("Folder")
    standFolder.Name = "PlayerStands"
    standFolder.Parent = workspace

    -- Player Added event
    players.PlayerAdded:Connect(PlayerAdded)
        for _, player in ipairs(players:GetPlayers()) do
	    PowersService:PlayerAdded(player)
    end

    -- Player Removing event
    players.PlayerRemoving:Connect(function(player)

    end)

end

return PowersService