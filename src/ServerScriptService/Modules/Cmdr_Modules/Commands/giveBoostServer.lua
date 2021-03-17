local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

return function (_, player, boostName, timeSeconds)

	--print("TESTING THE COMMAAND!", player, boostName, timeSeconds)

	Knit.Services.BoostService:AddBoost(player, boostName, timeSeconds)

	return ("gave Boost")
end