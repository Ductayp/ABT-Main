-- Basic Projectile
-- PDab
-- 11-27-2020

--Roblox Services
local Workspace = game:GetService("Workspace")
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
local WeldedSound = require(Knit.PowerUtils.WeldedSound)
local hitboxMod = require(Knit.Shared.RaycastProjectileHitbox)

local BasicProjectile = {}

--// --------------------------------------------------------------------
--// Handler Functions
--// --------------------------------------------------------------------

--// Initialize
function BasicProjectile.Initialize(params, abilityDefs)

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
function BasicProjectile.Activate(params, abilityDefs)

	-- check KeyState
	if params.KeyState == "InputBegan" then
		params.CanRun = true
	else
		params.CanRun = false
		return params
    end
    
    -- check cooldown
    if not Cooldown.Server_IsCooled(params) then
        params.CanRun = false
        return params
    end
    
    if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
        params.CanRun = false
        return params
    end

	-- set cooldown
    Cooldown.SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)

    -- block input
    require(Knit.PowerUtils.BlockInput).AddBlock(params.InitUserId, "BasicProjectile", 1.5)

    -- tween hitbox
    BasicProjectile.Run_Server(params, abilityDefs)

end

--// Execute
function BasicProjectile.Execute(params, abilityDefs)

    -- tween effects
	BasicProjectile.Run_Client(params, abilityDefs)

end


--// --------------------------------------------------------------------
--// Ability Functions
--// --------------------------------------------------------------------

function BasicProjectile.Run_Server(params, abilityDefs)

    print("BasicProjectile - SERVER")

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    local rootPart = initPlayer.Character.HumanoidRootPart
    local abilityMod = require(abilityDefs.AbilityMod)

    -- setup the hitbox
    local dataPoints = hitboxMod:GetSquarePoints(rootPart.CFrame, abilityMod.SquarePoints.X, abilityMod.SquarePoints.X)


end

function BasicProjectile.Run_Client(params, abilityDefs)

    print("BasicProjectile - CLIENT")

    local abilityMod = require(abilityDefs.AbilityMod)

    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

    -- setup the stand, if its not there then dont run return
	local targetStand = Workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		targetStand = ManageStand.QuickRender(params)
    end

    -- run animation
    if abilityMod.StandAnimation then
        ManageStand.PlayAnimation(params, abilityMod.StandAnimation)
    end

    -- play the sound when it is fired
    if abilityMod.FireSound then
	    WeldedSound.NewSound(targetStand.HumanoidRootPart, abilityMod.FireSound)
    end
    
    if abilityMod.StandMove then
        ManageStand.MoveStand(params, abilityMod.StandMove.PositionName)
        spawn(function()
            wait(abilityMod.StandMove.ReturnDelay)
            ManageStand.MoveStand(params, "Idle")
        end)
    end

    -- clone in all parts
    local projectilePart = abilityMod.Projectile.Assembly:Clone()
    projectilePart.Parent = Workspace.RenderedEffects
    projectilePart.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(abilityMod.Projectile.OriginOffset)
    Debris:AddItem(projectilePart, 60) -- be sure we debris it just in case


end

return BasicProjectile