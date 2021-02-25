local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

return function (_, player, key, quantity)

	Knit.Services.InventoryService:Give_Item(player, key, quantity)
	return ("Give Item success")
end