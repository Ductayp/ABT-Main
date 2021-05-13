local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

return function (_, player, boostName, timeSeconds)

	
	local playerData = Knit.Services.PlayerDataService:ResetPlayerData(player)
	--wait(3)
	--player:Kick()

	return ("reset player data: " .. player.Name)
end