local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

return function (_, player, key, rarity, quantity)

	Knit.Services.InventoryService:Give_Arrow(player, key, rarity, quantity)
	return ("gave arrow success")
end