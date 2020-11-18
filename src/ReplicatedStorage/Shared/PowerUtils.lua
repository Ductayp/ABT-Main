-- PowersUtils
-- PDab
-- 11/17/2020

-- General set of utilities used by powers

-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local PowerUtils = {}

--// CheckCooldown - receives the power params and returns params.CanRun as true or false
function PowerUtils.CheckCooldown(player,params)

    local cooldownFolder =  ReplicatedStorage.PowerStatus[player.UserId]:FindFirstChild("Cooldowns")
    if not cooldownFolder then
        cooldownFolder = utils.EasyInstance("Folder", {Name = "Cooldowns", Parent = ReplicatedStorage.PowerStatus[player.userId]})
    end

    local thisCooldown = cooldownFolder:FindFirstChild(params.Key)
    if not thisCooldown then
        thisCooldown = utils.EasyInstance("NumberValue", {Name = params.Key, Value = os.time() - 1, Parent = cooldownFolder})
    end

    if os.time() > thisCooldown.Value then
        params.CanRun = true
    end

    return params
end

-- // SetCooldown - just sets it
function PowerUtils.SetCooldown(player,params,value)

    local cooldownFolder =  ReplicatedStorage.PowerStatus[player.UserId]:FindFirstChild("Cooldowns")
    if not cooldownFolder then
        cooldownFolder = utils.EasyInstance("Folder", {Name = "Cooldowns", Parent = ReplicatedStorage.PowerStatus[player.userId]})
    end

    local thisCooldown = cooldownFolder:FindFirstChild(params.Key)
    if not thisCooldown then
        cooldownFolder = utils.EasyInstance("NumberValue", {Name = params.Key, Value = os.time() - 1, Parent = cooldownFolder})
    end

    thisCooldown.Value = value
end

--// WeldParticles - creates a part at any position and parents a premade ParticleEmitter, destroys is after duration
function PowerUtils.WeldParticles(position,weldTo,emitter,duration)
	local partDefs = {
		Parent = workspace,
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
		debris:AddItem(part, duration * 2)
	end
	
	return part
end

function PowerUtils.TweenCharacterParts(model,tweenInfoArray,parametersDictionary)

	local tweenInfo = TweenInfo.new(tweenInfoArray)
	
	for i,v in pairs(model:GetDescendants()) do
		if v:IsA("BasePart") then
			if v.Name == "HumanoidRootPart" then
				--print("nope")
			else
				local thisTween = TweenService:Create(v,tweenInfo,parametersDictionary)
				thisTween:Play()
			end
		end
	end
end


return PowerUtils