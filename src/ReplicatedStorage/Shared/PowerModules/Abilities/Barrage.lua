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
			return
		end

		if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
			params.CanRun = false
			return params
		end

		-- require toggles to be inactive, excluding "Q"
		if not AbilityToggle.RequireOff(params.InitUserId, abilityDefs.RequireToggle_Off) then
			params.CanRun = false
			return params
		end

		-- only operate if toggle is off
		if AbilityToggle.GetToggleValue(params.InitUserId, params.InputId) == false then

			--params.Local_BarrageToggle = AbilityToggle.SetToggle(params.InitUserId, "Local_BarrageToggle", true)
			AbilityToggle.SetToggle(params.InitUserId, "Local_BarrageToggle", true)
			Barrage.RunEffect(params, abilityDefs)

			-- spawn a function to kill the barrage if the duration expires
			spawn(function()
				wait(abilityDefs.Duration)
				AbilityToggle.SetToggle(params.InitUserId, "Local_BarrageToggle", false)
				Barrage.EndEffect(params, abilityDefs)
			end)
		end

		params.CanRun = true
	end

	-- InputEnded
	if params.KeyState == "InputEnded" then

		if AbilityToggle.GetToggleValue(params.InitUserId, "Local_BarrageToggle") == true then
			AbilityToggle.SetToggle(params.InitUserId, "Local_BarrageToggle", false)
			Barrage.EndEffect(params)
		end

		params.CanRun = true
	end

end

--// Activate
function Barrage.Activate(params, abilityDefs)

	-- InputBegan
	if params.KeyState == "InputBegan" then

		-- check cooldown
		if not Cooldown.Server_IsCooled(params) then
			params.CanRun = false
			return
		end

		if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
			params.CanRun = false
			return params
		end

		-- require toggles to be inactive, excluding "Q"
		if not AbilityToggle.RequireOff(params.InitUserId, abilityDefs.RequireToggle_Off) then
			params.CanRun = false
			return params
		end

		-- only operate if toggle is off
		if AbilityToggle.GetToggleValue(params.InitUserId, params.InputId) == false then

			AbilityToggle.SetToggle(params.InitUserId, params.InputId, true)
			Barrage.CreateHitbox(params, abilityDefs)

			

			-- spawn a function to kill the barrage if the duration expires
			spawn(function()
				wait(abilityDefs.Duration)
				AbilityToggle.SetToggle(params.InitUserId, params.InputId, false)
				Barrage.DestroyHitbox(params, abilityDefs)
				Cooldown.SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)
			end)
		end
	end

	-- InputEnded
	if params.KeyState == "InputEnded" then

		if AbilityToggle.GetToggleValue(params.InitUserId, params.InputId) == true then
			AbilityToggle.SetToggle(params.InitUserId, params.InputId, false)
			Barrage.DestroyHitbox(params)
			Cooldown.SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)
		end
	end

	params.CanRun = true
	
end

--// Execute
function Barrage.Execute(params, abilityDefs)

	-- do not render for initPlayer
	if Players.LocalPlayer.UserId == params.InitUserId then
		return
	end

	if AbilityToggle.GetToggleValue(params.InitUserId, params.InputId) == true then
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

	-- create a bool inside for the hitbox to run off
	local newBool = utils.EasyInstance("BoolValue", {Name = "HitToggle", Parent = hitPart, Value = true})

	-- weld it
	local newWeld = Instance.new("Weld")
	newWeld.C1 =  CFrame.new(0, 0, 6.5)
	newWeld.Part0 = initPlayer.Character.HumanoidRootPart
	newWeld.Part1 = hitPart
	newWeld.Parent = hitPart

	-- make a new hitbox
	--local newHitbox = RaycastHitbox:Initialize(hitPart)
	local newHitbox = RayHitbox.New(initPlayer, abilityDefs, hitPart, true)
	--newHitbox:DebugMode(true)

	-- cycle the hitbox
	spawn(function()
		while newBool.Value == true do
			newWeld.C1 =  CFrame.new(0, 0, 5)
			newHitbox:HitStart()
			wait(0.125)
			newWeld.C1 =  CFrame.new(0, 0, 6.5)
			wait(0.125)
			newHitbox:HitStop()
			wait()
		end
	end)

end

--// Server Destroy Hitbox
function Barrage.DestroyHitbox(params)
	local playerHitboxFolder = workspace.ServerHitboxes[params.InitUserId]
	local hitPart = playerHitboxFolder:FindFirstChild("Barrage")
	if hitPart then
		--local hitBox = RaycastHitbox:GetHitbox(hitPart)
		local hitBox = RayHitbox.GetHitbox(hitPart)
		hitBox:HitStop()
		local hitToggle = hitPart:FindFirstChild("HitToggle")
		if hitToggle then
			hitPart.HitToggle.Value = false
		end
		Debris:AddItem(hitPart, 1)
	end
end

--// Shoot Arm 
function Barrage.ShootArm(initPlayer, effectArm)

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

	print("run barrage",params, abilityDefs)

	-- setup the stand, if its not there then dont run return
	local targetStand = workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		ManageStand.QuickRender(params)
	end

	-- move stand and play Barrage animation
	ManageStand.PlayAnimation(params, "Barrage")
	ManageStand.MoveStand(params, "Front")

	-- play the sound
	WeldedSound.NewSound(targetStand.HumanoidRootPart, abilityDefs.Sounds.Barrage, {SpeakerProperties = {Name = "Barrage"}, SoundProperties = {Looped = true}})

	-- spawn the arms shooter
	local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
	local effectArm = ReplicatedStorage.EffectParts.Abilities.Barrage[params.PowerID .. "_" .. params.PowerRarity]

	local thisToggle
	if params.SystemStage == "Initialize" then
		thisToggle = AbilityToggle.GetToggleObject(params.InitUserId, "Local_BarrageToggle")
	else
		thisToggle = AbilityToggle.GetToggleObject(params.InitUserId, params.InputId)
	end

	spawn(function()
		while thisToggle.Value == true  do
			Barrage.ShootArm(initPlayer, effectArm)
			wait(armSpawnRate)
		end
	end)

end

--// End Effect
function Barrage.EndEffect(params, abilityDefs)

	local targetStand = workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		return
	end

	-- stop animation and move stand to Idle
	ManageStand.StopAnimation(params, "Barrage")
	ManageStand.MoveStand(params, "Idle")

	-- stop the sound
	WeldedSound.StopSound(targetStand.HumanoidRootPart, "Barrage", 1)
end


return Barrage
