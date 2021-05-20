local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

return function (_, quantity)

	for i, player in pairs(Players:GetPlayers()) do
		Knit.Services.InventoryService:Give_Currency(player, "Cash", quantity, "Admin")
	end

	return ("Arrow Rain success")
end