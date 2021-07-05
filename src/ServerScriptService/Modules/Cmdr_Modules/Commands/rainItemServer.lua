local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

return function (_, key, quantity)

	for i, player in pairs(Players:GetPlayers()) do
		Knit.Services.InventoryService:Give_Item(player, key, quantity)
	end

	return ("Item Rain success")
end