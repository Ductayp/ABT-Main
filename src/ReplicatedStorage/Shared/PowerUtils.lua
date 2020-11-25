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
local RayastHitbox = require(Knit.Shared.RaycastHitboxV3)

local PowerUtils = {}

--// CheckCooldown - receives the power params and returns params.CanRun as true or false
function PowerUtils.GetCooldown(player,params)

    local cooldownFolder =  ReplicatedStorage.PowerStatus[player.UserId]:FindFirstChild("Cooldowns")
    if not cooldownFolder then
        cooldownFolder = utils.EasyInstance("Folder", {Name = "Cooldowns", Parent = ReplicatedStorage.PowerStatus[player.userId]})
    end

    local thisCooldown = cooldownFolder:FindFirstChild(params.InputId)
    if not thisCooldown then
        thisCooldown = utils.EasyInstance("NumberValue", {Name = params.InputId, Value = os.time() - 1, Parent = cooldownFolder})
    end

    return thisCooldown
end

-- // SetCooldown - just sets it
function PowerUtils.SetCooldown(player,params,value)

    local cooldownFolder =  ReplicatedStorage.PowerStatus[player.UserId]:FindFirstChild("Cooldowns")
    if not cooldownFolder then
        cooldownFolder = utils.EasyInstance("Folder", {Name = "Cooldowns", Parent = ReplicatedStorage.PowerStatus[player.userId]})
    end

    local thisCooldown = cooldownFolder:FindFirstChild(params.InputId)
    if not thisCooldown then
        thisCooldown = utils.EasyInstance("NumberValue", {Name = params.InputId, Value = os.time() - 1, Parent = cooldownFolder})
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
			thisToggle = toggleFolder:FindFirstChild(params.InputId)
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

-- SetInputBlock - can optionally name it and optionally send it to Debris with a time
function PowerUtils.SetInputBlock(player,params)

	-- get folder
	local inputBlockFolder = ReplicatedStorage.PowerStatus[player.UserId]:FindFirstChild("InputBlocks")
	if not inputBlockFolder then
		inputBlockedBool = utils.EasyInstance("Folder",{Name = "InputBlocks", Parent = ReplicatedStorage.PowerStatus[player.UserId]})
	end

	-- setup block value
	local inputBlockedBool = Instance.new("BoolValue")
	inputBlockedBool.Value = true
	inputBlockedBool.Parent = inputBlockFolder
	if params.Name then
		inputBlockedBool.Name = params.Name
	end

	if params.Duration then
		Debris:AddItem(inputBlockedBool, params.Duartion)
	end

	return inputBlockedBool
end

-- CheckInputBlock - checks the folder for any blocks and will return a bool value of TRUE if any blocks exist
function PowerUtils.CheckInputBlock(player)

	local isBlocked = false
	local inputBlockFolder = ReplicatedStorage.PowerStatus[player.UserId]:FindFirstChild("InputBlocks")
	if inputBlockFolder then
		local inputBlocks = inputBlockFolder:GetChildren()
		if inputBlocks ~= nil then
			for i,v in pairs(inputBlocks) do
				if v.value == true then
					isBlocked = true
				end
			end
		end
	end

	return isBlocked
end



--// WeldParticles - creates a part at any position and parents a premade ParticleEmitter, destroys is after duration
function PowerUtils.WeldParticles(position,weldTo,emitter,duration)
	local partDefs = {
		Parent = workspace.RenderedEffects,
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

--// WeldedHitBox - will run until the part is destroyed
function PowerUtils.WeldedHitbox(initPlayer,params)

	--[[
		--// required params
		params.Size = Vector3
		params.Name = something to find it again by
		params.CFrame = the CFrame
		params.WeldTo = the part to weld it to
		params.Damage = how much per tick
		params.Tick = time per tick
		
		--// optional params
		params.Exclude = an array of characters to exclude. DOES NOT ACCEPT players. Instead do player.Character.
	]]

	-- get the right folder if server or client
	local hitboxFolder
	if RunService:IsServer() then
		hitboxFolder = workspace.ServerHitboxes:FindFirstChild(initPlayer.UserId)
	else
		hitboxFolder = workspace.ClientHitboxes:FindFirstChild(initPlayer.UserId)
	end

	-- basic part setup
	local newHitBox = Instance.new("Part")
	newHitBox.Size = params.Size -- must be Vector3
	newHitBox.Massless = true
    newHitBox.Transparency = .5
	newHitBox.CanCollide = false
	newHitBox.Parent = hitboxFolder
	newHitBox.Name = params.AbilityId
	newHitBox.CFrame = params.CFrame

	print(newHitBox.Massless)

	if params.Debug then
		newHitBox.Transparency = .7
		newHitBox.Color = Color3.new(170, 0, 0)
	else
		newHitBox.Transparency = 1
	end


	-- weld it
	local hitboxWeld = utils.EasyWeld(newHitBox,params.WeldTo,newHitBox)

	-- run it
	spawn(function()
		repeat 
			print("tick")
			local connection = newHitBox.Touched:Connect(function() end)
			local results = newHitBox:GetTouchingParts()
			connection:Disconnect()

			local charactersHit = {}
			for _,part in pairs (results) do
				if part.Parent:FindFirstChild("Humanoid") then
						charactersHit[part.Parent] = true -- insert into table with no duplicates
				end
			end

			-- remove excluded targets
			if params.Exclude then
				for _,excludeCharacter in pairs (params.Exclude) do
					if charactersHit[excludeCharacter] then
						charactersHit[excludeCharacter] = nil
					end
				end
			end

			if charactersHit ~= nil then
				for characterHit,boolean in pairs (charactersHit) do -- we stored the character hit in the InputId above
					Knit.Services.PowersService:RegisterHit(initPlayer,characterHit,params)
				end
			end	

			-- check if hitbox still exists
			local canRun = false
			local checkHitbox = hitboxFolder:FindFirstChild(params.AbilityId) -- this checks of the hitbox part still exists
			if checkHitbox then
				canRun = true
			end

			-- clear hit tabel and wait
			charactersHit = nil
			wait(params.Tick)
			
		until canRun == false
	end)

	return newHitBox

end



--// WeldSpeakerSound - weld a speaker into the target and plays sounds according to params
function PowerUtils.WeldSpeakerSound(target,sound,params)

    -- find a speaker part, if not exists create it, name it the same as sound
    local thisSpeaker = target:FindFirstChild("SoundSpeaker")
	if not thisSpeaker then
		thisSpeaker = Instance.new("Part")
		thisSpeaker.Name = sound.Name
		thisSpeaker.CFrame = target.CFrame
		thisSpeaker.Size = Vector3.new(1,1,1)
		thisSpeaker.Anchored = false
		thisSpeaker.Massless = true
		thisSpeaker.CanCollide = false
		thisSpeaker.Transparency = 1
		thisSpeaker.Parent = target
        utils.EasyWeld(thisSpeaker,target,thisSpeaker)
    end

    -- get sound in speaker, make a new one if not exists
    local thisSound = thisSpeaker:FindFirstChild(sound.Name)
    if not thisSound then
        thisSound = sound:Clone()
        thisSound.Parent = thisSpeaker
    end

	if params then
		-- set properties for sound
		if params.SoundProperties ~= nil then
			for propertyName,propertyValue in pairs(params.SoundProperties) do 
				thisSound[propertyName] = propertyValue
			end
		end

		-- set Debris
		if params.Debris ~= nil then
			Debris:AddItem(thisSpeaker, params.Debris)
		end
	end

	-- play it
	thisSound:Play()

	-- if the sound isnt looping, destroy this speaker when its done
	spawn(function()
		thisSound.Ended:Wait()
		thisSpeaker:Destroy()
	end)
	

end

--// StopSpeakerSound - stops a sound by name by destroying its speaker, can also optionally fade
function PowerUtils.StopSpeakerSound(target,name,fadeTime)
	local thisSpeaker = target:FindFirstChild(name)
	
	if thisSpeaker then
		for _,sound in pairs(thisSpeaker:GetChildren()) do 
			if sound:IsA ("Sound") then
				if fadeTime then
					local tween = TweenService:Create(sound,TweenInfo.new(fadeTime),{Volume = 0})
					tween:Play()
					tween.Completed:Connect(function(State)
						if State == Enum.PlaybackState.Completed then
							sound:Destroy()
							tween:Destroy()
							thisSpeaker:Destroy()
						end
					end)
				else
					thisSpeaker:Destroy()
				end
			end
		end
	end 
end

return PowerUtils