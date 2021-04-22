local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

return function (_, player, standName, standRank)

	--print("TESTING THE COMMAAND!", player, boostName, timeSeconds)
	local params = {}
	params.Power = standName
	if standRank > 3 then
		standRank = 3
	elseif standRank < 1 then
		standRank = 1
	end

	params.Rank = standRank
	params.Xp = 0
	params.GUID = HttpService:GenerateGUID(false)

	Knit.Services.PowersService:SetCurrentPower(player, params)

	return ("gave stand!!") 
end