local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

--local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

return function (_, player, spawnName, respawn)

	Knit.Services.PlayerSpawnService:SetPlayerSpawn(player, spawnName, respawn)

	return ("set players spawn!") 
end