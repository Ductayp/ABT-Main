-- Mob Service
-- PDab
-- 1/8/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local PhysicsService = game:GetService("PhysicsService")
local Debris = game:GetService("Debris")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local MobService = Knit.CreateService { Name = "MobService", Client = {}}
local RemoteEvent = require(Knit.Util.Remote.RemoteEvent)

-- modules
local utils = require(Knit.Shared.Utils)
local config = require(Knit.MobModules.Config)


local mobStorage = ReplicatedStorage.Mobs

-- variables
local serialNumber = 1 -- this starts at one and goes up for every mob spawned, used as a unique ID for each mob
--local spawnGroupFolders = {} -- table of all spawn group folders in workspace. EACH NAME MUST BE UNIQUE!
local allSpawners = {}
local spawnedMobs = {} -- table of all spawned mobs

--// MobBrain
function MobService:MobBrain()

    while true do
       
        -- iterate through all spawned mobs on each loop
        for index, mobData in pairs(spawnedMobs) do

            if mobData.LastUpdate < os.clock() + 0.25 then
                --print("update mob")
                mobData.LastUpdate = os.clock()
                
                -- test print
                if mobData.BrainState ~= "Wait" then
                    print(mobData.BrainState)
                end

                -- if this mob is NOT dead, do the brain!
                if mobData.IsDead == false then

                    -- BRAIN EVENT: Is Mob Dead? -- check if mob is dead, handle death
                    if mobData.Model.Humanoid.Health <= 0 then
                        mobData.BrainState = nil
                        mobData.IsDead = true
                        mobData.DeadTime = os.clock()
                        self:KillMob(mobData)
                    end

                    -- BRAIN: Do Move
                    --mobData.Model.Humanoid:MoveTo(mobData.MoveTo)


                    -- BRAIN STATE: Post_Attack
                    if mobData.BrainState == "Post_Attack" then

                        --mobData.Model.Humanoid:MoveTo(mobData.Model.HumanoidRootPart.Position)

                        mobData.Animations.Idle:Play()
                        if mobData.StateTime < os.clock() - 1 then
                            mobData.BrainState = "Wait"
                            mobData.StateTime = os.clock()
                        end 
                    end

                    -- BRAIN STATE: Attack
                    if mobData.BrainState == "Attack" then
                        if mobData.LastAttack < os.clock() - mobData.Defs.AttackSpeed then

                            --mobData.Model.Humanoid:MoveTo(mobData.Model.HumanoidRootPart.Position)

                            mobData.Animations.Walk:Stop()
                            mobData.Animations.Idle:Stop()
                            local rand = math.random(1, #mobData.Animations.Attack)
                            mobData.Animations.Attack[rand]:Play()
                            mobData.BrainState = "Post_Attack"
                            mobData.StateTime = os.clock()

                        end
                    end

                    -- BRAIN STATE: Wait
                    if mobData.BrainState == "Wait" then

                        -- set move
                        mobData.Model.Humanoid:MoveTo(mobData.Model.HumanoidRootPart.Position)
                        if not mobData.Animations.Idle.IsPlaying then mobData.Animations.Idle:Play() end
                        mobData.Animations.Walk:Stop()

                        -- set chase if we have a target
                        if mobData.ChaseTarget ~= nil then
                            mobData.BrainState = "Chase"
                            mobData.StateTime = os.clock()
                        end

                    end

                    -- BRAIN STATE: Chase
                    if mobData.BrainState == "Chase" then

                        -- if chaseTarget is nil, then return to home
                        if mobData.ChaseTarget == nil then
                            mobData.BrainState = "Return"
                        end

                        if mobData.BrainState == "Chase" then
                            -- set move
                            print("chase target: ", mobData.ChaseTarget.Character)

                            --local target = mobData.ChaseTarget.Character.HumanoidRootPart.Position
                            --mobData.Model.Humanoid:MoveTo(target - CFrame.new(mobData.Model.HumanoidRootPart.Position, target).LookVector * mobData.Defs.ApproachDistance) 
                            
                            if mobData.ChaseTarget:DistanceFromCharacter(mobData.Model.HumanoidRootPart.Position) > mobData.Defs.ApproachDistance then
                                mobData.Model.Humanoid:MoveTo(mobData.ChaseTarget.Character.HumanoidRootPart.Position, mobData.ChaseTarget.Character.HumanoidRootPart) 
                                if not mobData.Animations.Walk.IsPlaying then mobData.Animations.Walk:Play() end
                                mobData.Animations.Idle:Stop()
                            else
                                mobData.Model.Humanoid:MoveTo(mobData.Model.HumanoidRootPart.Position)
                                mobData.BrainState = "Attack"
                            end

                            -- if we get too far away, return to the spawner
                            local spawnerMagnitude = (mobData.Model.HumanoidRootPart.Position - mobData.Spawner.SpawnerPart.Position).Magnitude
                            if spawnerMagnitude > mobData.Defs.ChaseRange then
                                mobData.BrainState = "Return"
                                mobData.ChaseTarget = nil
                                mobData.StateTime = os.clock()
                            end

                        end
                    end
                    
                    -- BRAIN STATE: Return
                    if mobData.BrainState == "Return" then

                        -- set move
                        mobData.Model.Humanoid:MoveTo(mobData.Spawner.SpawnerPart.Position, mobData.Spawner.SpawnerPart)
                        if not mobData.Animations.Walk.IsPlaying then mobData.Animations.Walk:Play() end
                        mobData.Animations.Idle:Stop()

                        -- check if we are too far from Home
                        local rangeMagnitude = (mobData.Model.HumanoidRootPart.Position - mobData.Spawner.SpawnerPart.Position).Magnitude
                        if rangeMagnitude < 5 then 
                            mobData.BrainState = "Wait"
                            mobData.ChaseTarget = nil
                            mobData.StateTime = os.clock()
                        end

                        -- if we get stuck in the return state too long, kill the mob
                        if os.clock() > mobData.StateTime + 10 then
                            mobData.PlayerDamage = nil
                            mobData.IsDead = true
                            mobData.DeadTime = os.clock()
                        end

                        -- if a player gets back in range, set it back to chase
                        if mobData.ChaseTarget ~= nil then
                            if os.clock() > mobData.StateTime + 1 then
                                mobData.BrainState = "Chase"
                                mobData.StateTime = os.clock()
                            end

                        end

                    end

                    -- BRAIN EVENT: Seek Target
                    local playerTargets = {}
                    for player, damage in pairs (mobData.PlayerDamage) do

                        -- build table of players within range of the spawner part who have done damage
                        if player:DistanceFromCharacter(mobData.Spawner.SpawnerPart.Position) <= mobData.Defs.SeekRange then
                            playerTargets[player] = damage
                        end

                        -- set target to the player with the most damage
                        if playerTargets == nil then
                            mobData.ChaseTarget = nil
                        else
                            local highestDamage = 0
                            for player, damage in pairs(playerTargets) do
                                if damage > highestDamage then
                                    highestDamage = damage
                                    mobData.ChaseTarget = player
                                end
                            end
                        end
                    end

                    --[[
                    -- BRAIN EVENT: Attack Target
                    if mobData.ChaseTarget ~= nil then
                        if mobData.ChaseTarget:DistanceFromCharacter(mobData.Model.HumanoidRootPart.Position) <= mobData.Defs.AttackRange then
                            if mobData.LastAttack < os.clock() - mobData.Defs.AttackSpeed then
                                mobData.LastAttack = os.clock()
                                mobData.BrainState = "Attack"
                                mobData.StateTime = os.clock()
                            end
                        end
                    end
                    ]]--

                end

                -- cleanup the dead mobs
                if mobData.IsDead == true then 
                    if os.clock() > mobData.DeadTime + 5 then
                        mobData.Spawner.SpawnerCooldown = os.clock() + mobData.Spawner.SpawnerDefs.RespawnTime 
                        mobData.Model:Destroy()
                        table.remove(spawnedMobs, index)
                        --print(spawnedMobs)
                    end
                end
            end
        end
        wait()
    end
end

--// DamageMob
function MobService:DamageMob(player, mobId, damage)

    -- get the mob form all spawnedMobs using the MobId
    local thisMob 
    for _, mobData in pairs(spawnedMobs) do
        if mobData.MobId == mobId then
            thisMob = mobData
            break
        end
    end

    if thisMob == nil then
        return
    end

    -- apply player damage counts only if the mob is not dead
    if thisMob.BrainState ~= "Dead" then
        -- apply damage to the mobData table
        if thisMob.PlayerDamage[player] == nil then
            thisMob.PlayerDamage[player] = damage
        else
            thisMob.PlayerDamage[player] += damage
        end
    end
end

--// KillMob
function MobService:KillMob(mobData)

    -- award xp if a player did more than 1/3 of total damage
    for player, damage in pairs(mobData.PlayerDamage) do
        if damage > mobData.Defs.Health / 3 then
            Knit.Services.PowersService:AwardXp(player, mobData.Defs.XpValue)
        end
    end
end


--// NewMob
function MobService:NewMob(mobDefs)

    -- this table gets returned
    local mobData = {}
    mobData.Defs = mobDefs -- just add the defs to the table for convenince in other functions

    -- clone a new mob
    mobData.Model = mobDefs.Model:Clone()

   -- un-anchor
    for _,object in pairs(mobData.Model:GetDescendants()) do
        if object:IsA("BasePart") then
            object.Anchored = false
        end
    end

    -- Property Updates
    mobData.Model.Humanoid.MaxHealth = mobDefs.Health;
	mobData.Model.Humanoid.Health = mobData.Model.Humanoid.MaxHealth;
	mobData.Model.Humanoid.WalkSpeed = mobDefs.WalkSpeed;
    mobData.Model.Humanoid.JumpPower = mobDefs.JumpPower;

    -- add a default Walkspeed object
    local defaultWalkspeed = Instance.new("NumberValue")
    defaultWalkspeed.Name = "DefaultWalkSpeed"
    defaultWalkspeed.Value = mobDefs.WalkSpeed
    defaultWalkspeed.Parent = mobData.Model

    -- parent to workspace so we can load animations
    mobData.Model.Parent = Workspace

    -- add an animator
    mobData.Animations = {} -- setup a table
    mobData.Animations.Attack = {} -- we need another table for attack aniamtions
    local animator = Instance.new("Animator")
    animator.Parent = mobData.Model.Humanoid

    -- idle animation
    local idleAnimation = Instance.new("Animation")
    idleAnimation.AnimationId = mobDefs.Animations.Idle
    mobData.Animations.Idle = animator:LoadAnimation(idleAnimation)
    idleAnimation:Destroy()

    -- walk animation
    local walkAnimation = Instance.new("Animation")
    walkAnimation.AnimationId = mobDefs.Animations.Walk
    mobData.Animations.Walk = animator:LoadAnimation(walkAnimation)
    walkAnimation:Destroy()

    -- attack animations
    for index, animationId in pairs(mobDefs.Animations.Attack) do
        local newAnimation = Instance.new("Animation")
        newAnimation.AnimationId = animationId
        local newTrack = animator:LoadAnimation(newAnimation)
        table.insert(mobData.Animations.Attack, newTrack)
        newAnimation:Destroy()
    end
    
    -- add a body gyro
    local BodyGyro = Instance.new("BodyGyro");
	BodyGyro.MaxTorque = Vector3.new(0,0,0) * 50000;
	BodyGyro.D = 150;
	BodyGyro.P = 2500;
	BodyGyro.Name = "Rotater";
    BodyGyro.Parent = mobData.Model.PrimaryPart;
    
    -- set collision
    if config.MobCollide == false then
		self:SetCollisionGroup(mobData.Model, "Mob_NoCollide")
    end
    
    -- Set States For Optimization
	for state, value in pairs(config.HumanoidStates) do
		mobData.Model.Humanoid:SetStateEnabled(state, value)
    end
    
    -- setup assorted mobData values
    mobData.PlayerDamage = {}
    mobData.BrainState = "Wait"
    mobData.StateTime = os.clock()
    mobData.IsDead = false
    mobData.LastUpdate = os.clock()
    mobData.LastAttack = os.clock()

    return mobData
end

--// SpawnLoop
function MobService:SpawnLoop()

    wait(5) -- initial wait

    while wait(1) do -- basic spawn loop time
            
        -- iterate through all groups and spawn stuff
        for _, spawner in pairs(allSpawners) do

            -- spawn mobs if the spawner does not have max spawned
            local mobsSpawned = spawner.SpawnerPart:GetChildren()
            if #mobsSpawned < spawner.SpawnerDefs.MaxSpawned  then

                -- check spawner cooldown
                if spawner.SpawnerCooldown < os.clock() then

                    -- create a new mobData object and add soem values
                    local mobData = self:NewMob(spawner.SpawnerDefs)

                    -- set the spawner this mob is owned by
                    mobData.Spawner = spawner

                    -- assign serialNumber to mob model and also add the mobData table to spawnedMobs table
                    utils.NewValueObject("MobId", serialNumber, mobData.Model)
                    mobData.MobId = serialNumber
                    serialNumber += 1
                    table.insert(spawnedMobs, mobData)

                    -- spawn it out
                    local offsetX = math.random(-spawner.SpawnerPart.Size.X / 2, spawner.SpawnerPart.Size.X / 2)
                    local offsetZ = math.random(-spawner.SpawnerPart.Size.Z / 2, spawner.SpawnerPart.Size.Z / 2)
                    mobData.HomePosition = spawner.SpawnerPart.Position + Vector3.new(offsetX, 0, offsetZ)
                    mobData.SpawnCFrame = spawner.SpawnerPart.CFrame * CFrame.new(offsetX, 30, offsetZ)
                    mobData.Model.PrimaryPart.CFrame = mobData.SpawnCFrame
                    mobData.Model.Parent = spawner.SpawnerPart
                    
                end
            end
        end
    end 
end

--// SetCollisionGroup
function MobService:SetCollisionGroup(model, group)
	if model:IsA("BasePart") then
		PhysicsService:SetPartCollisionGroup(model, group);
	else
		local modelDescendants = model:GetDescendants()
		for i = 1, #modelDescendants do
			local model = modelDescendants[i];
			if model:IsA("BasePart") then
				PhysicsService:SetPartCollisionGroup(model, group);
			end
		end
	end
end

--// PlayerAdded
function MobService:PlayerAdded(player)

    -- set players collision group according to Config
    if config.PlayerCollide == false then
        local character = player.Character or player.CharacterAdded:Wait()
		self:SetCollisionGroup(character, "Mob_NoCollide");
		player.CharacterAdded:Connect(function(Character)
			self:SetCollisionGroup(character, "Mob_NoCollide");
		end)
    end

end


--// KnitStart
function MobService:KnitStart()

    spawn(function()
        self:SpawnLoop() -- this loops and respawns mobs
    end)

    spawn(function()
        self:MobBrain() -- this loops and performs actions on each spawned mob
    end)
    
end

--// KnitInit
function MobService:KnitInit()

    -- create no-collision group and set it
    PhysicsService:CreateCollisionGroup("Mob_NoCollide")
    PhysicsService:CollisionGroupSetCollidable("Mob_NoCollide", "Mob_NoCollide", false)

    -- find all spawner, build a data table for each, also make the spawners invis
    for _,instance in pairs(Workspace:GetDescendants()) do
        if instance.Name == "MobService" then
            for _,folder in pairs(instance:GetChildren()) do
                for _,spawner in pairs(folder:GetChildren()) do

                    -- build a data table for the spawenr and insert it inthe allSpawners table
                    local spawnerData = {
                        SpawnerPart = spawner,
                        SpawnerCooldown = os.clock() - 1,
                        SpawnerDefs = require(Knit.MobModules[spawner.Parent.Name])
                    }
                    table.insert(allSpawners, spawnerData)

                    -- make it transparent
                    spawner.Transparency = 1
                end
            end
        end
    end

    -- Player Added event
    Players.PlayerAdded:Connect(function(player)
        self:PlayerAdded(player)
    end)

    -- Player Added event for studio tesing, catches when a player has joined before the server fully starts
    for _, player in ipairs(Players:GetPlayers()) do
        self:PlayerAdded(player)
    end

    -- Player Removing event
    Players.PlayerRemoving:Connect(function(player)
        --self:PlayerRemoved(player)
    end)

end


return MobService