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
local spawnGroupFolders = {} -- table of all spawn group folders in workspace. EACH NAME MUST BE UNIQUE!
local spawnedMobs = {} -- table of all spawned mobs

--// MobAction
function MobService:MobBrain()

    -- spawn a function that loops for the lifetime of the server
    spawn(function()
        while true do
       
            -- iterate through all spawned mobs on each loop
            for mobIndex, mobData in pairs(spawnedMobs) do

                -- BRAIN EVENT: Is Mob Dead? -- check if mob is dead, handle death
                if mobData.Model.Humanoid.Health <= 0 then
                    print("dead", mobData.Model.Humanoid.Health)
                    self:KillMob(mobData)
                    spawnedMobs[mobIndex] = nil
                end

                -- BRAIN EVENT: Chase Target? -- will chase the player with the highest damage against it, as logn as that player is in range of spawner
                local damageObjects = mobData.Model.PlayerDamage:GetChildren()
                if #damageObjects > 0 then

                    local playerTable = {}
                    for _, object in pairs(damageObjects) do
                        local player = utils.GetPlayerByUserId(tonumber(object.Name))
                        playerTable[player] = object.Value
                    end

                    -- get the target character
                    local player = utils.GetPlayerByUserId(tonumber(largestObject.Name))
                    print("Chasing player:", player)



                end
                




            end
            wait()
        end
    end)
end

function MobService:KillMob(mobData)

    -- award xp if a player did more than 1/3 of total damage
    for _, object in pairs(mobData.Model.PlayerDamage:GetChildren()) do
        if object.Value > mobData.Defs.Health / 3 then

            -- get player formt he objects name
            local player = utils.GetPlayerByUserId(tonumber(object.Name))

            --award the XP thorugh PowersService
            Knit.Services.PowersService:AwardXpForKill(player, mobData.Defs.XpValue)
        end
    end

    -- set the respawn timer
    mobData.Timer.Value = os.time() + mobData.Defs.RespawnTime

    -- destroy the model
    mobData.Model:Destroy()

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
    
    -- make a bool value so this model can receive damage from PowerService
    --utils.NewValueObject("IsMob", true, mobData.Model)

    -- setup table for player damage
    mobData.PlayerDamage = {}

    -- make a folder to hold player damage value objects
    --utils.EasyInstance("Folder", {Name = "PlayerDamage", Parent = mobData.Model})

    return mobData
end

--// SpawnLoop
function MobService:SpawnLoop()

    -- initial wait
    wait(5)

    spawn(function()
        
        while wait(1) do -- basic spawn loop time
             
            -- iterate through all groups and spawn stuff
            for groupName, groupFolder in pairs(spawnGroupFolders) do

                local mobDefs = require(Knit.MobModules[groupName])

                -- iterate through all the spawner part in this folder, check if we have enough mobs spawned
                for _,spawner in pairs(groupFolder:GetChildren()) do

                    for count = 1, mobDefs.MaxSpawned do

                        -- find respawn cooldown objects for each possible spawned mob
                        local thisTimerObject = spawner:FindFirstChild("Timer_" .. count)
                        if not thisTimerObject then
                            thisTimerObject = utils.NewValueObject("Timer_" .. count, os.time() - 1, spawner)
                        end

                        local mobModel = spawner:FindFirstChild("Mob_" .. count)

                        -- check if the timer is less than current time, and no mob is spawned
                        if thisTimerObject.Value < os.time() and mobModel == nil then

                            -- create a new mobData and then spawn the model
                            local mobData = self:NewMob(mobDefs)
                            local offsetX = math.random(-spawner.Size.X / 2, spawner.Size.X / 2)
                            local offsetZ = math.random(-spawner.Size.Z / 2, spawner.Size.Z / 2)
                            mobData.Model.PrimaryPart.CFrame = spawner.CFrame * CFrame.new(offsetX, 30, offsetZ)
                            mobData.Model.Parent = spawner
                            mobData.Model.Name = "Mob_" .. count

                            -- add a reference to the timer object to the mobData table, this is used when the mob is killed
                            mobData.Timer = thisTimerObject

                            -- assign serialNUmber to MobId object and also add the mobData table to spawnedMobs table
                            utils.NewValueObject("MobId", serialNumber, mobData.Model)
                            spawnedMobs[serialNumber] = mobData
                            serialNumber += 1

                        end
                    end
                end
            end
        end 
    
    end)
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

    self:SpawnLoop() -- this loops and respawns mobs
    self:MobBrain() -- this loops and performs actions on each spawned mob

end

--// KnitInit
function MobService:KnitInit()

    -- create no-collision group and set it
    PhysicsService:CreateCollisionGroup("Mob_NoCollide")
    PhysicsService:CollisionGroupSetCollidable("Mob_NoCollide", "Mob_NoCollide", false)

    -- find all spawn group folders and put them in their table, also make the spawners invis
    for _,instance in pairs(Workspace:GetDescendants()) do
        if instance.Name == "MobService" then
            for _,folder in pairs(instance:GetChildren()) do
                spawnGroupFolders[folder.Name] = folder
                for _,spawner in pairs(folder:GetChildren()) do
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