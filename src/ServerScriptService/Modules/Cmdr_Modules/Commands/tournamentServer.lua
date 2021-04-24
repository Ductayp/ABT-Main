local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

local bridgeParts = {}
for i, v in pairs(workspace.DeleteWhenArenaUpdate:GetDescendants()) do
	if v:IsA("BasePart") then
		table.insert(bridgeParts, v)
	end
end

local roofPart = workspace:FindFirstChild("TournamentRoof", true)

return function (_, bridgeBool, roofBool)

	--print("TESTING THE COMMAAND!", player, boostName, timeSeconds)
	if bridgeBool == true then
		for i, v in pairs(bridgeParts) do
			v.Transparency = 1
			v.CanCollide = false
		end
	else
		for i, v in pairs(bridgeParts) do
			v.Transparency = 0
			v.CanCollide = true
		end
	end

	if roofBool == true then
		roofPart.Transparency = 1
		roofPart.CanCollide = false
	else
		roofPart.Transparency = .75
		roofPart.CanCollide = true
	end
	

	return ("Tournament Toggled")
end