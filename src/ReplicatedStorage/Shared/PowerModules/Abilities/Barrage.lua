-- Barrage Effect Script

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")

-- knite and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local ManageStand = require(Knit.Abilities.ManageStand)
local DamageEffect = require(Knit.Effects.Damage)
local AbilityToggle = require(Knit.PowerUtils.AbilityToggle)

-- local variables
local armSpawnRate = .05
local armDebrisTime = .15
local damageLoopTime = 0.25

local Barrage = {}

--// Server Create Hitbox -- we have a unique hitbox for Barrage
function Barrage.Activate(initPlayer,params)

	-- basic part setup
	local newHitBox = Instance.new("Part")
	newHitBox.Size = Vector3.new(4,5,5.5)
	newHitBox.Massless = true
    newHitBox.Transparency = 1
	newHitBox.CanCollide = false
	newHitBox.Parent = workspace.ServerHitboxes[initPlayer.UserId]
	newHitBox.Name = "Barrage"
	newHitBox.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-4))
	
	-- weld it
	local hitboxWeld = utils.EasyWeld(newHitBox,initPlayer.Character.HumanoidRootPart,newHitBox)

	-- run it
	spawn(function()
		repeat 
			local connection = newHitBox.Touched:Connect(function() end)
			local results = newHitBox:GetTouchingParts()
			connection:Disconnect()

			local charactersHit = {}
			for _,part in pairs (results) do
				if part.Parent:FindFirstChild("Humanoid") then
					if part.Parent ~= initPlayer.Character then -- dont hit the initPlayer
						charactersHit[part.Parent] = true -- insert into table with no duplicates
					end
				end
			end

			if charactersHit ~= nil then
				for characterHit,boolean in pairs (charactersHit) do -- we stored the character hit in the InputId above-- setup DamageEffect params
					Knit.Services.PowersService:RegisterHit(initPlayer,characterHit,params.Barrage.HitEffects)
				end
			end	

			-- check if hitbox still exists
			local canRun = false
			local checkHitbox = workspace.ServerHitboxes[initPlayer.UserId]:FindFirstChild(newHitBox.Name) -- this checks of the hitbox part still exists
			if checkHitbox then
				canRun = true
			end

			-- clear hit tabel and wait
			charactersHit = nil
			wait(damageLoopTime)
			
		until canRun == false
	end)

end

--// Server Destroy Hitbox
function Barrage.DestroyHitbox(initPlayer, params)
	local destroyHitbox = workspace.ServerHitboxes[initPlayer.UserId]:ClearAllChildren()
end

--// Shoot Arm 
function Barrage.ShootArm(initPlayer, params)

	-- clone a single arm and parent it, add it to the Debris
	local newArm = ReplicatedStorage.EffectParts.Abilities.Barrage[params.PowerID .. "_" .. params.PowerRarity]:Clone()
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
function Barrage.RunEffect(initPlayer,params)

	-- setup the stand, if its not there then dont run return
	local targetStand = workspace.PlayerStands[initPlayer.UserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		return
	end

	-- move stand and play Barrage animation
	ManageStand.PlayAnimation(initPlayer,params,"Barrage")
	ManageStand.MoveStand(initPlayer,{AnchorName = "Front"})

	-- setup coroutine and run it while the toggle is on
	local thisToggle = AbilityToggle.GetToggleObject(initPlayer,params.InputId) -- we need the toggle to know when to shut off the spawner

	-- spawn the arms shooter
	spawn(function()
		while thisToggle.Value == true  do
			Barrage.ShootArm(initPlayer, params)
			wait(armSpawnRate)
		end
	end)
end

--// End Effect
function Barrage.EndEffect(initPlayer,params)

	-- stop animation and move stand to Idle
	ManageStand.StopAnimation(initPlayer,{AnimationName = "Barrage"})
	ManageStand.MoveStand(initPlayer,{AnchorName = "Idle"})
end


return Barrage
