--// POWER UTILS
-- Just a few functions to help offload regular tasks in the Power Controller

local replicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")
local soundService = game:GetService("SoundService")
local debris = game:GetService("Debris")
local utils = require(replicatedStorage.SRC.Modules.Utilities)
local powerDefs = replicatedStorage.SRC.Definitions.PowerDefs

local module = {}

--//-- SERVER FUNCTIONS --//--

--// Set Cooldown - sets the cooldown value object
function module.SetCooldown(player,dictionary)
	local defintionsModule = powerDefs:FindFirstChild(dictionary.PowerID)
	local requiredModule = require(defintionsModule)
	local playerCooldownFolder = replicatedStorage.PowerStatus.Cooldowns[player.UserId]
	local cooldownValueObject = playerCooldownFolder[dictionary.AbilityID]

	cooldownValueObject.Value = os.time() + requiredModule[dictionary.AbilityID].Cooldown
end

--//-- CLIENT FUNCTIONS --//--

--// Load Animations -this is done when a stand is spawned/equipped
function module.LoadAnimations(standModel)
	local defsModule = powerDefs:FindFirstChild(standModel.Name)
	local defs = require(defsModule)
	
	for _,animationDef in pairs(defs.Animations)do
		local newAnimation = Instance.new("Animation")
		newAnimation.Name = animationDef.Name
		newAnimation.Parent = standModel
		newAnimation.AnimationId = animationDef.Address
	end
end

--// Play Animation - gets an animation by name and plays it
function module.PlayAnimation(standModel,animName)
	local animationController = standModel:FindFirstChild("AnimationController")
	if not animationController then
		animationController = utils.EasyInstance("AnimationController",{Parent = standModel})
	end
	
	local newTrack = animationController:LoadAnimation(standModel:FindFirstChild(animName))
	newTrack:Play()
	
	return newTrack
end

--// Stop Animation - stops an animation by name
function module.StopAnimation(standModel,animName)
	local animationController = standModel:FindFirstChild("AnimationController")
	local tracks = animationController:GetPlayingAnimationTracks()
	for i,v in pairs (tracks) do
		if v.Name == animName then
			v:Stop()
		end
	end
end

--// Trail Settings - used to change the stands trails during different events
function module.TrailSettings(player,dictionary)
	local targetStand = workspace.LocalEffects.PlayerStands[player.UserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		print("PowersUtil-TrailSettings - stand not active")
		return
	end
	
	local trailsFolder = targetStand:FindFirstChild("Trails")
	if trailsFolder then
		for _,trail in pairs(trailsFolder:GetChildren()) do
			for key,value in pairs(dictionary) do
				trail[key] = value
			end
		end
	end
end

--// ParticleEmitter - creates a part at any position and parents a premade ParticleEmitter, destroys is after duration
function module.WeldParticles(position,weldTo,emitter,duration)
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


--// Tween Character Parts - used for minor tweens and animations
function module:TweenCharacterParts(model,tweenInfoArray,parametersDictionary)

	local tweenInfo = TweenInfo.new(tweenInfoArray)
	
	for i,v in pairs(model:GetDescendants()) do
		if v:IsA("BasePart") then
			if v.Name == "HumanoidRootPart" then
				--print("nope")
			else
				local thisTween = tweenService:Create(v,tweenInfo,parametersDictionary)
				thisTween:Play()
			end
		end
	end
end

--// Selective Debris - nameArry is an arry of object names to debris, targetArray is the objects to search, duration is the :Debris time
function module.SelectiveDebris(nameArray,targetArray,duration)
	for _,object in pairs(targetArray) do
		for _,name in pairs(nameArray) do
			if object.Name == name then
				if duration then
					debris:AddItem(object,duration)
				else
					debris:AddItem(object,0)
				end
			end
		end
	end
end

--// Play 3D Sound - accepts a sound, a parent, and dictionary of properties.
-- Creates a part in the parent named "Sounds" that acts as a folder sound we can easily find the sounds if we need them
function module.Play3DSound(sound,parent,propertiesDictionary)
	local soundsPart = parent:FindFirstChild("Sounds")
	if not soundsPart then
		soundsPart = utils.EasyInstance("Part",{Parent = parent,Name = "Sounds"})
	end
	
	local thisSound = soundsPart:FindFirstChild(sound)
	if not thisSound then
		thisSound = utils.EasyClone(sound, {Parent = soundsPart})
	end
	
	local newSound = sound:Clone()
	if parent then
		newSound.Parent = soundsPart
	end
	
	for Name, Value in pairs(propertiesDictionary) do
		newSound[Name] = Value;
	end
	
	newSound:Play()
end



return module
