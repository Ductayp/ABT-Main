-- Barrage_Spec Effect Script

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")

-- knite and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local ManageStand = require(Knit.Abilities.ManageStand)
local AbilityToggle = require(Knit.PowerUtils.AbilityToggle)
local Cooldown = require(Knit.PowerUtils.Cooldown)
local RayHitbox = require(Knit.PowerUtils.RayHitbox)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)
local BlockInput = require(Knit.PowerUtils.BlockInput)

local Barrage_Spec = {}

--// --------------------------------------------------------------------
--// Handler Functions
--// --------------------------------------------------------------------

--// Initialize
function Barrage_Spec.Initialize(params, abilityDefs)


	-- InputBegan
	if params.KeyState == "InputBegan" then

		-- check cooldown
		if not Cooldown.Client_IsCooled(params) then
			params.CanRun = false
			return params
		end

		if abilityDefs.RequireToggle_On then
			if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
				params.CanRun = false
				return params
			end
		end

		params.CanRun = true
	end

	-- InputEnded
	if params.KeyState == "InputEnded" then
		params.CanRun = true
	end

	return params
end

--// Activate
function Barrage_Spec.Activate(params, abilityDefs)

	-- InputBegan
	if params.KeyState == "InputBegan" then

		if not Cooldown.Server_IsCooled(params) then
			params.CanRun = false
			return params
		end

		if abilityDefs.RequireToggle_On then
			if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
				params.CanRun = false
				return params
			end
		end

		if AbilityToggle.GetToggleValue(params.InitUserId, params.InputId) == false then

			AbilityToggle.SetToggle(params.InitUserId, params.InputId, true)
			BlockInput.AddBlock(params.InitUserId, params.InputId, abilityDefs.Duration)

			Barrage_Spec.RunServer(params, abilityDefs)
			params.Barrage_SpecOn = true


			spawn(function()
				wait(abilityDefs.Duration)
				if AbilityToggle.GetToggleValue(params.InitUserId, params.InputId) then
					AbilityToggle.SetToggle(params.InitUserId, params.InputId, false)
					Cooldown.SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)
					BlockInput.RemoveBlock(params.InitUserId, params.InputId)
					Barrage_Spec.EndServer(params, abilityDefs)
					params.Barrage_SpecOn = false
				end
			end)

		end
	end

	-- InputEnded
	if params.KeyState == "InputEnded" then

		if AbilityToggle.GetToggleValue(params.InitUserId, params.InputId) == true then
			AbilityToggle.SetToggle(params.InitUserId, params.InputId, false)
			Cooldown.SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)
			BlockInput.RemoveBlock(params.InitUserId, params.InputId)
			Barrage_Spec.EndServer(params)
			params.Barrage_SpecOn = false
		end
	end

	params.CanRun = true
	
end

--// Execute
function Barrage_Spec.Execute(params, abilityDefs)

	if params.Barrage_SpecOn == true then
		Barrage_Spec.RunClient(params, abilityDefs)
	else
		Barrage_Spec.EndClient(params, abilityDefs)
	end

end


--// --------------------------------------------------------------------
--// Ability Functions
--// --------------------------------------------------------------------

--// Server Create Hitbox -- we have a unique hitbox for Barrage_Spec
function Barrage_Spec.RunServer(params, abilityDefs)

	local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
	if not initPlayer then return end

	Knit.Services.PlayerUtilityService.PlayerAnimations[initPlayer.UserId].Barrage_Spec:Play()

	-- clone out a new hitpart
	local hitPart = Instance.new("Part")
	hitPart.Size = Vector3.new(5,5,3)
	hitPart.CanCollide = false
	hitPart.Transparency = 1
	hitPart.Name = "Barrage_Spec"
	hitPart.Parent = Workspace.ServerHitboxes[params.InitUserId]
	

	local newWeld = Instance.new("Weld")
	newWeld.C1 =  CFrame.new(0, 0, 3)
	newWeld.Part0 = initPlayer.Character.HumanoidRootPart
	newWeld.Part1 = hitPart
	newWeld.Parent = hitPart

	hitPart.Touched:Connect(function() end)

	spawn(function()
		while hitPart.Parent == Workspace.ServerHitboxes[params.InitUserId] do
			local hitParts = hitPart:GetTouchingParts()
			local hitCharacters = {}
			for _, part in pairs(hitParts) do
				if part.Parent:FindFirstChild("Humanoid") then
					hitCharacters[part.Parent] = true
				end
			end
			for character, _ in pairs(hitCharacters) do
				local thisPlayer = utils.GetPlayerFromCharacter(character)
				if thisPlayer ~= initPlayer then
					Knit.Services.PowersService:RegisterHit(initPlayer, character, abilityDefs)
				end
			end
			wait(.25)
		end
	end)
end

--// Server Destroy Hitbox
function Barrage_Spec.EndServer(params)

	local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
	if not initPlayer then return end

	Knit.Services.PlayerUtilityService.PlayerAnimations[initPlayer.UserId].Barrage_Spec:Stop()

	local playerHitboxFolder = workspace.ServerHitboxes[params.InitUserId]
	local hitPart = playerHitboxFolder:FindFirstChild("Barrage_Spec")
	if hitPart then
		hitPart:Destroy()
	end
end

--// Run Effect
function Barrage_Spec.RunClient(params, abilityDefs)

	local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
	if not initPlayer.Character.HumanoidRootPart then return end

	local barrageSound = ReplicatedStorage.Audio.Abilities.GenericBarrage
	WeldedSound.NewSound(initPlayer.Character.HumanoidRootPart, barrageSound, {SpeakerProperties = {Name = "Barrage_Spec"}, SoundProperties = {Looped = true}})

	local endTime = os.clock() + abilityDefs.Duration
	while os.clock() < endTime do
		wait()
	end
	
	Barrage_Spec.EndClient(params, abilityDefs)
end

--// End Effect
function Barrage_Spec.EndClient(params, abilityDefs)

	local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
	if not initPlayer.Character.HumanoidRootPart then return end

	WeldedSound.StopSound(initPlayer.Character.HumanoidRootPart, "Barrage_Spec", 1)
end


return Barrage_Spec
