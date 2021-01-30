-- SimpleHitbox
-- PDab
-- 1-19-2021

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

--modules
local utils = require(Knit.Shared.Utils)

local SimpleHitBox = {}

function SimpleHitBox.NewHitBox(initPlayer,boxParams)

	local hitBox = Instance.new("Part")

	-- set some defaults but we can override them with boxParams
	hitBox.Color = Color3.new(255/255, 102/255, 204/255)
	hitBox.Transparency = 1
	hitBox.Massless = true
	hitBox.CanCollide = false
	hitBox.Anchored = true
	hitBox.Parent = workspace.ServerHitboxes[initPlayer.UserId] -- parented to the initPlayer folder, this is so we can find the owner if we ever need to

	-- set anything from boxParams, this override defaults, OBVIOUSLY lol
	for key,value in pairs(boxParams) do
		hitBox[key] = value
	end

	-- a list of characters already hit, these get added in the Touched
	local hitList = {} -- this is characters that were already touching the box when it sapwned

	-- get all touching parts and hit them, this allows us to hit anything that was inside the hitbox when it spawned
	local connection = hitBox.Touched:Connect(function() end)
	local results = hitBox:GetTouchingParts()
	connection:Disconnect()

	-- add hit character to hitList without any duplicates
	for _,hit in pairs (results) do
		if hit.Parent:FindFirstChild("Humanoid") then
			hitList[hit.Parent] = true
		end
	end

	-- add value objects for hitList
	spawn(function()
		wait() -- essential! any script creating this hitbox needs to get its :ChildAdded event started before we add the children here
		for characterHit,_ in pairs (hitList) do 
			local newValueObject = Instance.new("ObjectValue") -- will store a character
			newValueObject.Name = "CharacterHit"
			newValueObject.Value = characterHit
			newValueObject.Parent = hitBox
		end
	end)
	
	-- the Touched event for new hits
	hitBox.Touched:Connect(function(hit)

		local humanoid = hit.Parent:FindFirstChildWhichIsA("Humanoid")
		if humanoid and humanoid.Health ~= 0 then 

			local canHit = true
			for alreadyHit,_ in pairs(hitList) do
				if hit.Parent == alreadyHit then
					canHit = false
				end
			end

			if canHit == true then
				local newValueObject = Instance.new("ObjectValue") -- will store a character
				newValueObject.Name = "CharacterHit"
				newValueObject.Value = hit.Parent
				newValueObject.Parent = hitBox
				
			end

		end
	end)

	return hitBox
end

return SimpleHitBox