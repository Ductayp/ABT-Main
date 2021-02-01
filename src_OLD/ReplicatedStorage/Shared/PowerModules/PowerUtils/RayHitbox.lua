-- RayHitbox
-- PDab
-- 1-19-2021

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local RaycastHitbox = require(Knit.Shared.RaycastHitboxV3)

local RayHitbox = {}

function RayHitbox.New(initPlayer, abilityDefs, hitPart, connectHit)

	-- make a new hitbox
	local newHitbox = RaycastHitbox:Initialize(hitPart)

	-- Makes a new event listener for raycast hits
	if connectHit then
		newHitbox.OnHit:Connect(function(hit, humanoid)
			if humanoid.Parent ~= initPlayer.Character then
				Knit.Services.PowersService:RegisterHit(initPlayer, humanoid.Parent, abilityDefs)
			end
		end)
	end
	
	return newHitbox
end

function RayHitbox.GetHitbox(hitPart)

	local hitBox = RaycastHitbox:GetHitbox(hitPart)
	return hitBox

end

return RayHitbox