-- Barrage Effect Script

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

-- local variables
local armSpawnRate = .05
local armDebrisTime = .15
local damageLoopTime = 0.25

local Barrage = {}

--// --------------------------------------------------------------------
--// Handler Functions
--// --------------------------------------------------------------------

--// Initialize
function Barrage.Initialize(params, abilityDefs)


	-- InputBegan
	if params.KeyState == "InputBegan" then

		-- check cooldown
		if not Cooldown.Client_IsCooled(params) then
			params.CanRun = false
			return params
		end

		if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
			params.CanRun = false
			return params
		end

		params.CanRun = true
	end

	-- InputEnded
	if params.KeyState == "InputEnded" then

		if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
			params.CanRun = false
			return params
		end

		-- require the barrage ot be on before sending InutEnded to the server
		if not AbilityToggle.RequireOn(params.InitUserId, {"E"}) then
			params.CanRun = false
			return params
		end

		params.CanRun = true
	end

	return params
end

--// Activate
function Barrage.Activate(params, abilityDefs)

	-- InputBegan
	if params.KeyState == "InputBegan" then

		if not Cooldown.Server_IsCooled(params) then
			params.CanRun = false
			return params
		end

		if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
			params.CanRun = false
			return params
		end

		if AbilityToggle.GetToggleValue(params.InitUserId, params.InputId) == false then

			AbilityToggle.SetToggle(params.InitUserId, params.InputId, true)
			BlockInput.AddBlock(params.InitUserId, params.InputId, abilityDefs.Duration)

			Barrage.CreateHitbox(params, abilityDefs)
			params.BarrageOn = true


			spawn(function()
				wait(abilityDefs.Duration)
				if AbilityToggle.GetToggleValue(params.InitUserId, params.InputId) then
					AbilityToggle.SetToggle(params.InitUserId, params.InputId, false)
					Cooldown.Server_SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)
					BlockInput.RemoveBlock(params.InitUserId, params.InputId)
					Barrage.DestroyHitbox(params, abilityDefs)
					params.BarrageOn = false
				end
			end)

		end
	end

	-- InputEnded
	if params.KeyState == "InputEnded" then

		if AbilityToggle.GetToggleValue(params.InitUserId, params.InputId) == true then
			AbilityToggle.SetToggle(params.InitUserId, params.InputId, false)
			Cooldown.Server_SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)
			BlockInput.RemoveBlock(params.InitUserId, params.InputId)
			Barrage.DestroyHitbox(params)
			params.BarrageOn = false
		end
	end

	params.CanRun = true
	
end

--// Execute
function Barrage.Execute(params, abilityDefs)

	if params.BarrageOn == true then
		Barrage.RunEffect(params, abilityDefs)
	else
		Barrage.EndEffect(params, abilityDefs)
	end

end


--// --------------------------------------------------------------------
--// Ability Functions
--// --------------------------------------------------------------------

--// Server Create Hitbox -- we have a unique hitbox for Barrage
function Barrage.CreateHitbox(params, abilityDefs)

	-- get initPlayer
	local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

	-- clone out a new hitpart
	local hitPart = ReplicatedStorage.EffectParts.Abilities.Barrage.HitBox:Clone()
	hitPart.Name = "Barrage"
	hitPart.Parent = Workspace.ServerHitboxes[params.InitUserId]
	--hitPart.Transparency = .7

	local newWeld = Instance.new("Weld")
	newWeld.C1 =  CFrame.new(0, 0, 6.5)
	newWeld.Part0 = initPlayer.Character.HumanoidRootPart
	newWeld.Part1 = hitPart
	newWeld.Parent = hitPart

	hitPart.Touched:Connect(function() end)

	spawn(function()
		
		local playerHitboxFolder = Workspace.ServerHitboxes[params.InitUserId]
		if playerHitboxFolder ~= nil then
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
		end

	end)
end

--// Server Destroy Hitbox
function Barrage.DestroyHitbox(params)
	local playerHitboxFolder = workspace.ServerHitboxes[params.InitUserId]
	local hitPart = playerHitboxFolder:FindFirstChild("Barrage")
	if hitPart then
		hitPart:Destroy()
	end
end

--// Shoot Arm 
function Barrage.ShootArm(initPlayer, effectArm)

	if not initPlayer.Character.HumanoidRootPart then return end

	-- clone a single arm and parent it, add it to the Debris
	local newArm = effectArm:Clone()
	newArm.Parent = Workspace.RenderedEffects
	Debris:AddItem(newArm, armDebrisTime)

	-- set up random position and set the goals
	local posX = math.random(-2.5,2.5)
	local posY = 0.5 * math.random(-1.5, 3.5)
	newArm.CFrame = initPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(posX, posY, -3)
	local armGoal =  initPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(posX, posY, -6) --newArm.CFrame:ToWorldSpace(CFrame.new(0,0,-3))

	-- add in the body movers and let it go!
	newArm.BodyPosition.Position = armGoal.Position
	newArm.BodyPosition.D = 300
	newArm.BodyPosition.P = 20000
	newArm.BodyPosition.MaxForce = Vector3.new(2000,2000,2000)
end

--// Run Effect
function Barrage.RunEffect(params, abilityDefs)

	local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
	if not initPlayer.Character.HumanoidRootPart then return end

	-- setup the stand, if its not there then dont run return
	local targetStand = workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		ManageStand.QuickRender(params)
	end

	-- move stand and play Barrage animation
	ManageStand.PlayAnimation(params, "Barrage")
	ManageStand.MoveStand(params, "Front")

	-- play the sound
	WeldedSound.NewSound(initPlayer.Character.HumanoidRootPart, abilityDefs.Sounds.Barrage, {SpeakerProperties = {Name = "Barrage"}, SoundProperties = {Looped = true}})

	-- spawn the arms shooter
	local effectArm = ReplicatedStorage.EffectParts.Abilities.Barrage[params.PowerID .. "_" .. tostring(params.PowerRank)]
	local endTime = os.clock() + abilityDefs.Duration
	while os.clock() < endTime do
		local thisToggle = AbilityToggle.GetToggleValue(params.InitUserId, params.InputId)
		if thisToggle == true then
			Barrage.ShootArm(initPlayer, effectArm)
			wait(armSpawnRate)
		else
			Barrage.EndEffect(params, abilityDefs)
			return
		end
	end
	
	Barrage.EndEffect(params, abilityDefs)
end

--// End Effect
function Barrage.EndEffect(params, abilityDefs)

	local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
	if not initPlayer.Character.HumanoidRootPart then return end

	--[[
	local targetStand = workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		return
	end
	]]--

	-- stop animation and move stand to Idle
	ManageStand.StopAnimation(params, "Barrage")
	ManageStand.MoveStand(params, "Idle")

	-- stop the sound
	WeldedSound.StopSound(initPlayer.Character.HumanoidRootPart, "Barrage", 1)
end


return Barrage
