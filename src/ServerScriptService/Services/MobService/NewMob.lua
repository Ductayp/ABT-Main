-- MobService - NewMob

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local config = require(script.Parent.Config)

local NewMob = {}

function NewMob.Create(mobDefs)

    -- this table gets returned
    local newMob = {}
    newMob.Defs = mobDefs.Defs -- just add the defs to the table for convenince in other functions

    -- clone a new mob
    newMob.Model = mobDefs.Model:Clone()

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
		Knit.Services.MobService:SetCollisionGroup(newMob.Model, "Mob_NoCollide")
    end

    if mobDefs.CanCollide == false then
		Knit.Services.MobService:SetCollisionGroup(newMob.Model, "Mob_NoCollide")
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
    newMob.Functions.DeSpawn = mobDefs.DeSpawn
    newMob.Functions.Attack = mobDefs.Attack
    newMob.Functions.Drop = mobDefs.Drop

    return newMob

end


return NewMob