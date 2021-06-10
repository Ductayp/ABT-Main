local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

return function (context, boolean)

	local player = context.Executor
	Knit.Services.GuiService:ToggleGUI(player, boolean)

	return ("Toggle GUI success")
end