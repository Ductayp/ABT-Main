-- PowersUtils
-- PDab
-- 11/17/2020

-- General set of utilities used by powers

-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local localPlayer = game.Players.LocalPlayer

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local PowerUtils = {}

--// CheckCooldown - receives the power params and returns params.CanRun as true or false
function PowerUtils.GetCooldown(player,params)

    local cooldownFolder =  ReplicatedStorage.PowerStatus[player.UserId]:FindFirstChild("Cooldowns")
    if not cooldownFolder then
        cooldownFolder = utils.EasyInstance("Folder", {Name = "Cooldowns", Parent = ReplicatedStorage.PowerStatus[player.userId]})
    end

    local thisCooldown = cooldownFolder:FindFirstChild(params.Key)
    if not thisCooldown then
        thisCooldown = utils.EasyInstance("NumberValue", {Name = params.Key, Value = os.time() - 1, Parent = cooldownFolder})
    end

    return thisCooldown
end

-- // SetCooldown - just sets it
function PowerUtils.SetCooldown(player,params,value)

    local cooldownFolder =  ReplicatedStorage.PowerStatus[player.UserId]:FindFirstChild("Cooldowns")
    if not cooldownFolder then
        cooldownFolder = utils.EasyInstance("Folder", {Name = "Cooldowns", Parent = ReplicatedStorage.PowerStatus[player.userId]})
    end

    local thisCooldown = cooldownFolder:FindFirstChild(params.Key)
    if not thisCooldown then
        thisCooldown = utils.EasyInstance("NumberValue", {Name = params.Key, Value = os.time() - 1, Parent = cooldownFolder})
    end

    thisCooldown.Value = os.time() + value
end

function PowerUtils.SetGUICooldown(key,value)

	spawn(function()

		local mainGui = localPlayer.PlayerGui:WaitForChild("MainGui")
		local coolDownFrame = mainGui:FindFirstChild("CoolDown",true)
		local newButton = coolDownFrame:FindFirstChild(key):Clone()
		newButton.Name = "Cooldown"
		newButton.Parent = coolDownFrame
		newButton.Text = value
		utils.EasyDebris(newButton,value)
		for count = 1, value do
			wait(1)
			newButton.Text = value - count
		end
	end)
end 

--// GetToggle 
function PowerUtils.GetToggle(player,toggleName)

	local toggleFolder
	local thisToggle

	if RunService:IsServer() then
		toggleFolder = ReplicatedStorage.PowerStatus[player.UserId]:FindFirstChild("Toggles")
		if not toggleFolder then
			toggleFolder = utils.EasyInstance("Folder", {Name = "Toggles", Parent = ReplicatedStorage.PowerStatus[player.userId]})
		end
		
		thisToggle = toggleFolder:FindFirstChild(toggleName)
		if not thisToggle then
			thisToggle = utils.EasyInstance("BoolValue", {Name = toggleName, Value = false, Parent = toggleFolder})
		end
	end

	if RunService:IsClient() then
		toggleFolder = ReplicatedStorage.PowerStatus[player.UserId]:FindFirstChild("Toggles")
		if toggleFolder then
			thisToggle = toggleFolder:FindFirstChild(toggleName)
		end
	end

	return thisToggle

end

-- RequireToggle
function PowerUtils.RequireToggle(player,params,toggleName)

	local boolean = false

	if RunService:IsServer() then
		local toggleFolder = ReplicatedStorage.PowerStatus[player.UserId]:FindFirstChild("Toggles")
		if toggleFolder then
			thisToggle = toggleFolder:FindFirstChild(params.Key)
			if thisToggle then
				boolean = thisToggle.Value
			end
		end
	end

	-- always let it run if its the client
	if RunService:IsClient() then
		boolean  = true
	end

	return boolean

end 



--// WeldParticles - creates a part at any position and parents a premade ParticleEmitter, destroys is after duration
function PowerUtils.WeldParticles(position,weldTo,emitter,duration)
	local partDefs = {
		Parent = workspace.LocalPowersEffects,
		Position = position,
		Anchored = false,
		CanCollide = false,
		Transparency = 1,
		Size = Vector3.new(1,1,1)
	}
	local part = utils.EasyInstance("Part",partDefs)
	local newEmitter = emitter:Clone()
	newEmitter.Enabled = true
	newEmitter.Parent = part
	
	utils.EasyWeld(part,weldTo,part)
	
	spawn(function()
		wait(duration)
		newEmitter.Enabled = false
	end)
	
	if duration then
		Debris:AddItem(part, duration * 2)
	end
	
	return part
end



return PowerUtils