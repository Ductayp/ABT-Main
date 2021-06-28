local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

return function (_, player, key, value)

	Knit.Services.InventoryService:Give_Currency(player, key, value, "Admin")

	return ("gave currency success")
end