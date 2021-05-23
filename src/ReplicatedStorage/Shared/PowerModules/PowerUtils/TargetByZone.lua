-- TargetByZone

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)


local TargetByZone = {}

function TargetByZone.GetAllInRange(initPlayer, origin, range, excludeInitPlayer)

	local initPlayer_MapZone = Knit.Services.PlayerUtilityService.PlayerMapZone[initPlayer.UserId]

	local hitCharacters = {}

    -- hit all players in range, subject to immunity
	local playersInZone = Knit.Services.PlayerUtilityService:GetPlayersInMapZone(initPlayer_MapZone)
    for _, player in pairs(playersInZone) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			if player.Character.Humanoid.Health > 0 then
				local distance = (player.Character.HumanoidRootPart.Position - origin).magnitude
				if distance <= range then
					if excludeInitPlayer then
						if player ~= initPlayer then
							if not require(Knit.StateModules.Invulnerable).IsInvulnerable(player) then
								table.insert(hitCharacters, player.Character)
							end
						end
					else
						if not require(Knit.StateModules.Invulnerable).IsInvulnerable(player) then
							table.insert(hitCharacters, player.Character)
						end
					end
				end
			end
        end
    end

	-- hit all Mobs in range
	local mobsInZone = Knit.Services.MobService:GetMobsInMapZone(initPlayer_MapZone)
	print("MOBS IN ZONE", mobsInZone)
	for _, mob in pairs(mobsInZone) do
		if mob.Model:FindFirstChild("Humanoid") then
			if mob.Model.Humanoid.Health > 0 then
				local distance = (mob.Model.HumanoidRootPart.Position - origin).magnitude
				if distance <= range then
					table.insert(hitCharacters, mob.Model)
				end
			end
		end
	end

	-- hit all dummies
	for _, dummy in pairs(Workspace.Dummies:GetChildren()) do
		local distance = (dummy.HumanoidRootPart.Position - origin).magnitude
		if distance <= range then
			table.insert(hitCharacters, dummy)
		end
	end

	return hitCharacters
end

function TargetByZone.GetAll(initPlayer, excludeInitPlayer)

	print("GET ALL - initPlayer", initPlayer)

	local initPlayer_MapZone = Knit.Services.PlayerUtilityService.PlayerMapZone[initPlayer.UserId]
	print("initPlayer_MapZone", initPlayer_MapZone)

	local hitCharacters = {}

    -- hit all players, subject to immunity
	local playersInZone = Knit.Services.PlayerUtilityService:GetPlayersInMapZone(initPlayer_MapZone)
    for _, player in pairs(playersInZone) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			if player.Character.Humanoid.Health > 0 then
				if excludeInitPlayer then
					if player ~= initPlayer then
						if not require(Knit.StateModules.Invulnerable).IsInvulnerable(player) then
							table.insert(hitCharacters, player.Character)
						end
					end
				else
					if not require(Knit.StateModules.Invulnerable).IsInvulnerable(player) then
						table.insert(hitCharacters, player.Character)
					end
				end
			end
        end
    end

	-- hit all Mobs in range
	local mobsInZone = Knit.Services.MobService:GetMobsInMapZone(initPlayer_MapZone)
	print("MOBS IN ZONE", mobsInZone)
	for _, mob in pairs(mobsInZone) do
		if mob.Model:FindFirstChild("Humanoid") then
			if mob.Model.Humanoid.Health > 0 then
				table.insert(hitCharacters, mob.Model)
			end
		end
	end

	--[[
	-- hit all dummies
	for _, dummy in pairs(Workspace.Dummies:GetChildren()) do
		table.insert(hitCharacters, dummy)
	end
	]]--

	return hitCharacters

end

function TargetByZone.GetPlayers(initPlayer)

	local hitCharacters = {}

	local playersInZone = Knit.Services.PlayerUtilityService:GetPlayersInMapZone(initPlayer_MapZone)

    for _, player in pairs(playersInZone) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			if player.Character.Humanoid.Health > 0 then
				if player ~= initPlayer then
					if not require(Knit.StateModules.Invulnerable).IsInvulnerable(player) then
						table.insert(hitCharacters, player.Character)
					end
				end
			end
        end
    end

	return hitCharacters

end

function TargetByZone.GetMobs(initPlayer)

	local hitCharacters = {}

	-- hit all Mobs in range
	local mobsInZone = Knit.Services.MobService:GetMobsInMapZone(initPlayer_MapZone)
	for _, mob in pairs(mobsInZone) do
		if mob.Model:FindFirstChild("Humanoid") then
			if mob.Model.Humanoid.Health > 0 then
				table.insert(hitCharacters, mob.Model)
			end
		end
	end

	return hitCharacters

end


return TargetByZone