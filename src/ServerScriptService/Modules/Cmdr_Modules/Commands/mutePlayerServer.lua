local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

return function (_, player, muteBoolean)

	--print("TESTING THE COMMAAND!", player, boostName, timeSeconds)

	Knit.Services.GameChatService:MutePlayer(player, muteBoolean)

	return ("Muted" .. player.Name)
end