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

-- events
-- events
MobService.Client.RenderAttack = RemoteEvent.new()

-- modules
local utils = require(Knit.Shared.Utils)
local config = require(Knit.MobModules.Config)


local mobStorage = ReplicatedStorage.Mobs

-- variables
local serialNumber = 1 -- this starts at one and goes up for every mob spawned, used as a unique ID for each mob
local allSpawners = {}
MobService.SpawnedMobs = {} -- table of all spawned mobs

--// MobBrain
function MobService:MobBrain()

    while true do
       
        -- iterate through all spawned mobs on each loop
        for index, mobData in pairs(MobService.SpawnedMobs) do

            -- only run the mobs brain if it is active
            if mobData.Active then

                -- only run the brain if the mobs last update is more than .25 seconds ago
                if mobData.LastUpdate < os.clock() + 0.25 then
                    mobData.LastUpdate = os.clock()
                    
                    -- test print
                    --if mobData.BrainState ~= "Wait" then
                        --print(mobData.BrainState)
                        --print(mobData.Model.Name)
                        --print(MobService.SpawnedMobs)
                    --end

                    -- NOT DEAD: if this mob is NOT dead, do the brain!
                    if mobData.IsDead == false then

                        --// STATES ---------------------------------------------
                        
                        -- BRAIN STATE: Post_Attack
                        if mobData.BrainState == "Post_Attack" then

                            mobData.MoveTarget = nil

                            if mobData.StateTime < os.clock() - 1 then
                                mobData.BrainState = "Wait"
                                mobData.StateTime = os.clock()
                            end 
                        end

                        -- BRAIN STATE: Attack
                        if mobData.BrainState == "Attack" then
                            if mobData.LastAttack < os.clock() - mobData.Defs.AttackSpeed then

                                -- run attack function
                                mobData.Functions.Attack(mobData)
                         
                                -- brain settings
                                mobData.AttackTarget = nil
                                mobData.LastAttack = os.clock()
                                mobData.BrainState = "Post_Attack"
                                mobData.StateTime = os.clock()
                            else
                                mobData.BrainState = "Chase"
                            end
                        end

                        -- BRAIN STATE: Wait
                        if mobData.BrainState == "Wait" then

                            -- set move
                            mobData.MoveTarget = nil

                            -- set chase if we have a target
                            if mobData.AttackTarget ~= nil then
                                mobData.BrainState = "Chase"
                                mobData.StateTime = os.clock()
                            end

                            -- if we get too far away, return to the spawner (overrides the chase set above)
                            local spawnerMagnitude = (mobData.Model.HumanoidRootPart.Position - mobData.Spawner.Position).Magnitude
                            if spawnerMagnitude > mobData.Defs.ChaseRange then
                                mobData.BrainState = "Return"
                                mobData.AttackTarget = nil
                                mobData.StateTime = os.clock()
                            end

                        end

                        -- BRAIN STATE: Return
                        if mobData.BrainState == "Return" then

                            -- set move
                            mobData.MoveTarget = mobData.Spawner.Position

                            -- check if we are too far from Home
                            local rangeMagnitude = (mobData.Model.HumanoidRootPart.Position - mobData.Spawner.Position).Magnitude
                            if rangeMagnitude < 5 then 
                                mobData.BrainState = "Wait"
                                mobData.AttackTarget = nil
                                mobData.StateTime = os.clock()
                            end

                            -- if we get stuck in the return state too long, kill the mob
                            if os.clock() > mobData.StateTime + 10 then
                                mobData.PlayerDamage = nil
                                mobData.IsDead = true
                                mobData.DeadTime = os.clock()
                            end

                            -- if a player gets back in range, set it back to chase
                            if mobData.AttackTarget ~= nil then
                                if os.clock() > mobData.StateTime + 1 then
                                    mobData.BrainState = "Chase"
                                    mobData.StateTime = os.clock()
                                end

                            end
                        end

                        -- BRAIN STATE: Chase
                        if mobData.BrainState == "Chase" then

                            -- if chaseTarget is nil, then return to home
                            if mobData.AttackTarget == nil then
                                mobData.BrainState = "Return"
                            end

                            if mobData.BrainState == "Chase" then

                                if mobData.AttackTarget:DistanceFromCharacter(mobData.Model.HumanoidRootPart.Position) > mobData.Defs.AttackRange then

                                    mobData.MoveTarget = mobData.AttackTarget.Character.HumanoidRootPart.Position
                                
                                else
                                    --mobData.MoveTarget = nil
                                    mobData.BrainState = "Attack"
                                end

                                -- if we get too far away, return to the spawner
                                local spawnerMagnitude = (mobData.Model.HumanoidRootPart.Position - mobData.Spawner.Position).Magnitude
                                if spawnerMagnitude > mobData.Defs.ChaseRange then
                                    mobData.BrainState = "Return"
                                    mobData.AttackTarget = nil
                                    mobData.StateTime = os.clock()
                                end
                            end
                        end
                        
                        --// ACTIONS ---------------------------------------------

                        -- BRAIN ACTION: Do Move
                        if mobData.Defs.IsMobile then
                            if mobData.MoveTarget then

                                -- do the move
                                mobData.Model.Humanoid:MoveTo(mobData.MoveTarget)

                                -- handle animations
                                if not mobData.Animations.Walk.IsPlaying then mobData.Animations.Walk:Play() end
                                mobData.Animations.Idle:Stop()

                            else
                                -- stop movement
                                mobData.Model.Humanoid:MoveTo(mobData.Model.HumanoidRootPart.Position)

                                -- handle animations
                                mobData.Animations.Walk:Stop()
                                if not mobData.Animations.Idle.IsPlaying then mobData.Animations.Idle:Play() end

                            end
                        else
                            if not mobData.Animations.Idle.IsPlaying then mobData.Animations.Idle:Play() end
                        end

                        --// EVENTS ---------------------------------------------

                        -- BRAIN EVENT: Seek Target
                        for _,player in pairs(Players:GetPlayers()) do

                            -- get a table of player within range
                            local inRange = {}
                            if player:DistanceFromCharacter(mobData.Spawner.Position) <= mobData.Defs.SeekRange then
                                table.insert(inRange, player)
                            end

                            if #inRange > 0 then
                                if mobData.Defs.Aggressive == true then
                                    local rand = math.random(1, #inRange)
                                    mobData.AttackTarget = inRange[rand]
                                else
                                    if mobData.PlayerDamage ~= nil then

                                        -- gat a table of players who have done damage AND are in range
                                        local attackList = {} 
                                        for damagePlayer, damage in pairs(mobData.PlayerDamage) do
                                            for _,inRangePlayer in pairs(inRange) do
                                                if damagePlayer == inRangePlayer then
                                                    attackList[damagePlayer] = damage
                                                end
                                            end
                                        end

                                        -- attack the player with the highest damage
                                        local highestDamage = 0
                                        for player, damage in pairs(attackList) do
                                            if damage > highestDamage then
                                                highestDamage = damage
                                                mobData.AttackTarget = player
                                            end
                                        end

                                    end
                                end
                            end
                        end

                        -- BRAIN EVENT: Is Mob Dead? -- check if mob is dead, handle death
                        if mobData.Model.Humanoid.Health <= 0 then
                            mobData.BrainState = "Dead"
                            mobData.StateTime = os.clock()
                            mobData.IsDead = true
                            mobData.DeadTime = os.clock()
                            self:KillMob(mobData)
                        end

                        -- BRAIN EVENT: LifeSpan  - check the mobs LifeSpan and kill it if its old
                        if mobData.SpawnTime < os.clock() - mobData.Defs.LifeSpan then
                            mobData.BrainState = "Dead"
                            mobData.StateTime = os.clock()
                            mobData.IsDead = true
                            mobData.DeadTime = os.clock()
                            mobData.PlayerDamage = {} -- delete all player damage
                            self:KillMob(mobData)
                        end

                    end

                    -- DEAD: cleanup the dead mobs
                    if mobData.IsDead == true then 
                        if os.clock() > mobData.DeadTime + 5 then
                            mobData.Model:Destroy()
                            table.remove(MobService.SpawnedMobs, index)
                        end
                    end
                end

            end
        end
        wait()
    end
end

--// HitPlayer
function MobService:HitPlayer(player, hitEffects)
    Knit.Services.PowersService:NPC_RegisterHit(player, hitEffects)
end

--// DamageMob
function MobService:DamageMob(player, mobId, damage)

    -- get the mob form all MobService.SpawnedMobs using the MobId
    local thisMob 
    for _, mobData in pairs(MobService.SpawnedMobs) do
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

    -- break the joints, YEET
    mobData.Model:BreakJoints()

    -- run the models death function
    mobData.Functions.Death(mobData)

    -- cehck if a player did more than 1/3 of total damage
    for player, damage in pairs(mobData.PlayerDamage) do
        if damage > mobData.Defs.Health / 3 then

            -- give XP
            Knit.Services.PowersService:AwardXp(player, mobData.Defs.XpValue)

            -- give drops
            mobData.Functions.Drop(player, mobData)
        end
    end
end

--// PauseAnimations
function MobService:PauseAnimations(mobId, duration)

    local thisMob 
    for _, mobData in pairs(MobService.SpawnedMobs) do
        if mobData.MobId == mobId then
            thisMob = mobData
            break
        end
    end

    spawn(function()
        local originalSpeed = thisMob.Animations.Walk.Speed
        thisMob.Animations.Walk:AdjustSpeed(0)
        wait(duration)
        thisMob.Animations.Walk:AdjustSpeed(originalSpeed)
    end)
end


--// NewMob
function MobService:NewMob(mobDefs)

    -- this table gets returned
    local newMob = {}
    newMob.Defs = mobDefs.Defs -- just add the defs to the table for convenince in other functions

    -- clone a new mob
    newMob.Model = mobDefs.Model:Clone()

   -- un-anchor
    for _,object in pairs(newMob.Model:GetDescendants()) do
        if object:IsA("BasePart") then
            object.Anchored = false
        end
    end

    -- Property Updates
    newMob.Model.Humanoid.MaxHealth = mobDefs.Defs.Health;
	newMob.Model.Humanoid.Health = mobDefs.Defs.Health;
	newMob.Model.Humanoid.WalkSpeed = mobDefs.Defs.WalkSpeed;
    newMob.Model.Humanoid.JumpPower = mobDefs.Defs.JumpPower;

    -- add a default Walkspeed object, this is for outside scripts that might cause a slow effect
    local defaultWalkspeed = Instance.new("NumberValue")
    defaultWalkspeed.Name = "DefaultWalkSpeed"
    defaultWalkspeed.Value = mobDefs.Defs.WalkSpeed
    defaultWalkspeed.Parent = newMob.Model

    -- set collision
    if config.MobCollide == false then
		self:SetCollisionGroup(newMob.Model, "Mob_NoCollide")
    end

    if mobDefs.CanCollide == false then
		self:SetCollisionGroup(newMob.Model, "Mob_NoCollide")
    end
    
    -- Set States For Optimization
	for state, value in pairs(config.HumanoidStates) do
		newMob.Model.Humanoid:SetStateEnabled(state, value)
    end
    
    -- setup assorted mobData values
    newMob.Active = true -- defaults to true, but we can set this before spawn with the provided functions
    newMob.PlayerDamage = {} -- this table hold player objects and the damage they have dealt this mob, used for aggro
    newMob.BrainState = "Wait" -- initial brain state
    newMob.StateTime = os.clock() -- used as a timestop whenever we change the state
    newMob.SpawnTime = os.clock() -- the time this mob was spawned, used to track its lifetime and despawn when it expires
    newMob.MoveTarget = nil
    newMob.IsDead = false
    newMob.LastUpdate = os.clock()
    newMob.LastAttack = os.clock()

    -- add functions
    newMob.Functions = {}
    newMob.Functions.Death = mobDefs.Death
    newMob.Functions.Attack = mobDefs.Attack
    newMob.Functions.Drop = mobDefs.Drop

    return newMob
end

--// SpawnLoop
function MobService:SpawnLoop()

    wait(5) -- initial wait

    while wait(1) do -- basic spawn loop time

        for _, spawnGroup in pairs(allSpawners) do

            -- only spawn if the respawn cooldown is up
            if spawnGroup.RespawnClock < os.clock() - spawnGroup.Defs.RespawnTime then
                spawnGroup.RespawnClock = os.clock()

                -- count all mobs spawned in this group, across all spawners
                local spawnCount = 0
                for _,spawner in pairs(spawnGroup.Spawners) do
                    local thisCount = 0
                    for _,mob in pairs(spawner:GetChildren()) do
                        thisCount += 1
                    end
                    spawnCount += thisCount
                end

                -- if we are less than Max_Spawned across the whole spawner group
                if spawnCount < spawnGroup.Defs.Max_Spawned then

                    -- build a table of open spawners
                    local openSpawners = {}
                    for _, spawner in pairs(spawnGroup.Spawners) do
                        if #spawner:GetChildren() == 0 then
                            table.insert(openSpawners, spawner)
                        end
                    end

                    -- pick a spawner randomly from the open spawners
                    local rand = math.random(1, #openSpawners)
                    local pickedSpawner = openSpawners[rand]

                    -- create a new mobData object and add soem values
                    local mobData = self:NewMob(spawnGroup.Defs)

                    -- set the spawner this mob is owned by
                    mobData.Spawner = pickedSpawner

                    -- assign serialNumber to mob model and also add the mobData table to MobService.SpawnedMobs table
                    utils.NewValueObject("MobId", serialNumber, mobData.Model)
                    mobData.MobId = serialNumber
                    serialNumber += 1
                    

                    -- spawn it out
                    local offsetX
                    local offsetZ
                    if spawnGroup.Defs.RandomPlacement then
                        offsetX = math.random(-pickedSpawner.Size.X / 2, pickedSpawner.Size.X / 2)
                        offsetX = math.random(-pickedSpawner.Size.Z / 2, pickedSpawner.Size.Z / 2)
                    else
                        offsetX = 0
                        offsetX = 0
                    end

                    -- insert the mob in the MobService.SpawnedMobs table, will be actively running from here unless Pre_Spawn_Setup as has its Active value to false
                    table.insert(MobService.SpawnedMobs, mobData)

                    -- set the mobs SpawnCFrame to the spawner part CFrame (we can change this in the Pre_Spawn function before spawn)
                    mobData.SpawnCFrame = pickedSpawner.CFrame * CFrame.new(offsetX, spawnGroup.Defs.Spawn_Z_Offset, offsetZ)

                    -- run the pre-spawn setup
                    spawnGroup.Defs.Pre_Spawn(mobData)

                    -- spawn the mob into the world
                    mobData.Model.PrimaryPart.CFrame = mobData.SpawnCFrame
                    mobData.Model.Parent = pickedSpawner

                    -- run the post-spawn setup
                    spawnGroup.Defs.Post_Spawn(mobData)

                    -- setup functions
                    spawnGroup.Defs.Setup_Animations(mobData)
                    spawnGroup.Defs.Setup_Attack(mobData)
                    spawnGroup.Defs.Setup_Death(mobData)
                    spawnGroup.Defs.Setup_Drop(mobData)
                    
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

                -- make a spawn group table
                thisGroup = {}
                thisGroup.Name = folder.Name
                thisGroup.Defs = require(Knit.MobModules.MobDefs[folder.Name])
                thisGroup.RespawnClock = os.clock()
                thisGroup.Spawners = folder:GetChildren()

                -- make spawner part transparent
                for _,spawnerPart in pairs(thisGroup.Spawners) do
                    spawnerPart.Transparency = 1
               end

               -- insert the spawner group into the 
               table.insert(allSpawners, thisGroup)
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