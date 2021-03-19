local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

return function (_, player, value)

	--print("TESTING THE COMMAAND!", player, boostName, timeSeconds)

	Knit.Services.InventoryService:Give_Xp(player, value)

	return ("gave Expereince/ Soul Orbs")
end