-- BasicSeeker
-- this module requires a refernce to an AbilityMod script, it does not work alone

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local AbilityToggle = require(Knit.PowerUtils.AbilityToggle)
local ManageStand = require(Knit.Abilities.ManageStand)
local Cooldown = require(Knit.PowerUtils.Cooldown)
local RayHitbox = require(Knit.PowerUtils.RayHitbox)
--local WeldedSound = require(Knit.PowerUtils.WeldedSound)

local BasicSeeker = {}

--// --------------------------------------------------------------------
--// Handler Functions
--// --------------------------------------------------------------------

--// Initialize
function BasicSeeker.Initialize(params, abilityDefs)

	-- check KeyState
	if params.KeyState == "InputBegan" then
		params.CanRun = true
	else
		params.CanRun = false
		return
    end
    
    -- check cooldown
	if not Cooldown.Client_IsCooled(params) then
		params.CanRun = false
		return
    end

    if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
        params.CanRun = false
        return params
    end
    
end

--// Activate
function BasicSeeker.Activate(params, abilityDefs)

	-- check KeyState
	if params.KeyState == "InputBegan" then
		params.CanRun = true
	else
		params.CanRun = false
		return
    end
    
    -- check cooldown
	if not Cooldown.Client_IsCooled(params) then
		params.CanRun = false
		return
    end
    

    if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
        params.CanRun = false
        return params
    end

	-- set cooldown
    Cooldown.SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)

    -- block input
    require(Knit.PowerUtils.BlockInput).AddBlock(params.InitUserId, "BasicSeeker", 1.5)

    -- tween hitbox
    spawn(function()
        BasicSeeker.Run_Server(params, abilityDefs)
    end)
    

end

--// Execute
function BasicSeeker.Execute(params, abilityDefs)

    -- tween effects
	BasicSeeker.Run_Effects(params, abilityDefs)

end


--// --------------------------------------------------------------------
--// Ability Functions
--// --------------------------------------------------------------------

function BasicSeeker.Run_Server(params, abilityDefs)

    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

    -- get the abilitymod
    local abilityMod = require(abilityDefs.AbilityMod)

    -- make a new grenade
    local newSeeker = abilityMod.new(initPlayer)

    -- setup the hitbox
    local newHitbox = RayHitbox.New(initPlayer, abilityDefs, newSeeker.HitBox, false)
    newHitbox.OnHit:Connect(function(hit, humanoid)
        if humanoid.Parent ~= initPlayer.Character then
            abilityMod.Server_Hit()
        end
    end)
    newHitbox:HitStart()
    newHitbox:DebugMode(true)

    -- get target
    abilityMod.AquireTarget(initPlayer, newSeeker)

    -- launch it
    abilityMod.Server_Launch(initPlayer, newSeeker)

    -- play the animation
    abilityMod.PlayAnimation(initPlayer)

end 

function BasicSeeker.Run_Effects(params, abilityDefs)

 
end

return BasicSeeker


