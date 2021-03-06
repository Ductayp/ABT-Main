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

	-- checks
	if params.KeyState == "InputBegan" then params.CanRun = true end
    if params.KeyState == "InputEnded" then params.CanRun = false return end
    if not Cooldown.Client_IsCooled(params) then params.CanRun = false return end
    if not Cooldown.Server_IsCooled(params) then params.CanRun = false return end
    if abilityDefs.RequireToggle_On then
        if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then params.CanRun = false return end
    end

    Cooldown.Client_SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)
    
end

--// Activate
function BasicSeeker.Activate(params, abilityDefs)

	-- checks
	if params.KeyState == "InputBegan" then params.CanRun = true end
    if params.KeyState == "InputEnded" then params.CanRun = false return end
    if not Cooldown.Server_IsCooled(params) then params.CanRun = false return end
    if abilityDefs.RequireToggle_On then
        if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then params.CanRun = false return end
    end

	-- set cooldown
    Cooldown.Server_SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)

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
            abilityMod.Server_Hit(initPlayer, newSeeker, humanoid.Parent, abilityDefs)
            abilityMod.DestroySeeker(initPlayer, newSeeker, abilityDefs, humanoid.Parent)
        end
    end)
    newHitbox:HitStart()
    --newHitbox:DebugMode(true)

    -- get target
    abilityMod.AquireTarget(initPlayer, newSeeker, abilityDefs)

    -- launch it
    abilityMod.Server_Launch(initPlayer, newSeeker, abilityDefs)

    -- play the animation
    abilityMod.PlayAnimations(initPlayer, newSeeker, abilityDefs)

    -- handle lifetime of seeker
    spawn(function()
        wait(newSeeker.LifeSpan)
        if newSeeker.Destroyed == false then
            abilityMod.DestroySeeker(initPlayer, newSeeker, abilityDefs)
        end
    end)

end 

function BasicSeeker.Run_Effects(params, abilityDefs)

 
end

return BasicSeeker


