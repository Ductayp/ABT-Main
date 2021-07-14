local hitboxModule = {}

local rayMod = require(script.RayModule)

function hitboxModule:GetSquarePoints(CF, x, y, resolutionX, resolutionY)

	local hSizex
	local hSizey
	
	if resolutionX then
		hSizex = resolutionX
	else 
		hSizex = 2
	end

	if resolutionY then
		hSizey = resolutionY
	else 
		hSizey = 5
	end

	--local hSizex, hSizey = 1, 1
	local splitx, splity = 1 + math.floor(x / hSizex), 1 + math.floor(y / hSizey)
	local studPerPointX = x / splitx
	local studPerPointY = y / splity

	local startCFrame = CF * CFrame.new(-x / 2 - studPerPointX / 2 , -y / 2 - studPerPointY / 2, 0)
	local points = {CF}

	for x = 1, splitx do
		for y = 1, splity do
			points[#points + 1] = startCFrame * CFrame.new(studPerPointX * x, studPerPointY * y, 0)
		end
	end
	
	return points
end

function hitboxModule:CastProjectileHitbox(Data)

	local Points = Data.Points
	local Direction = Data.Direction 
	local Velocity = Data.Velocity 
	local Lifetime = Data.Lifetime 
	local Iterations = Data.Iterations 
	local Visualize = Data.Visualize
	local BreakOnHit = Data.BreakOnHit
	local BreakifNotHuman = Data.BreakifNotHuman
	local BreakifHuman = Data.BreakifHuman
	local BreakOnBlockAbility = Data.BreakOnBlockAbility
	
	if Data.BreakOnHit == nil then BreakOnHit = true end
	--if Data.BreakifNotHuman == nil then BreakifNotHuman = false end
	if Data.BreakifHuman == nil then BreakifHuman = false end
	local Function = Data.Function or function()
		warn("There was no function provided for projectile hitbox")
	end

	local Ignore = Data.Ignore or {}
	local WhiteList = Data.WhiteList
	local Start = os.clock()
	
	spawn(function()

		local LastCast = nil
		local Interception = false
		local CastInterval = Lifetime / Iterations

		while os.clock() - Start < Lifetime and not Interception do
			
			local Delta = LastCast and os.clock() - LastCast or CastInterval

			if not LastCast or Delta >= CastInterval then
				
				local Distance = Velocity * Delta
				
				LastCast = os.clock()

				for Index, Point in ipairs(Points) do

					local StartPosition = Point.Position
					
					local EndPosition = Point.Position + Direction * Distance
					
					local Result
					
					if WhiteList then
						 Result = rayMod:Cast(StartPosition, EndPosition, WhiteList, Enum.RaycastFilterType.Whitelist, true)
					else
						 Result = rayMod:Cast(StartPosition, EndPosition, Ignore, Enum.RaycastFilterType.Blacklist, true)
					end	

					if Visualize then rayMod:Visualize(StartPosition, EndPosition) end

					if Result then
						
						Function(Result)
						if BreakOnHit == true then
							--print("RAY - BREAK ON HIT")
							Interception = true
							break
						end
						
						if BreakOnHit == false and BreakifHuman == true  then

							if Result.Instance.Parent and Result.Instance.Parent:FindFirstChild("HumanoidRootPart") then
								--print("RAY - BREAK IF HUMAN")
								Interception = true
								break
							end
						end

						if BreakOnHit == false and BreakOnBlockAbility == true  then

							if Result.Instance.Parent and Result.Instance.Parent.Name == "RenderedEffects_BlockAbility" then
								--print("RAY - BREAK ON BLOCK ABILITY")
								Interception = true
								break
							end
						end

					end
					
					Points[Index] = CFrame.new(EndPosition)
				end
			end

			game:GetService("RunService").Stepped:Wait()
		end
	end)
end

return hitboxModule