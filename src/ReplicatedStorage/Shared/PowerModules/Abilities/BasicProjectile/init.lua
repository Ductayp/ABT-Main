-- Basic Projectile
-- PDab
-- 11-27-2020

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
--local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local AbilityToggle = require(Knit.PowerUtils.AbilityToggle)
--local ManageStand = require(Knit.Abilities.ManageStand)
local Cooldown = require(Knit.PowerUtils.Cooldown)
local MobilityLock = require(Knit.PowerUtils.MobilityLock)
--local WeldedSound = require(Knit.PowerUtils.WeldedSound)
local hitboxMod = require(Knit.Shared.RaycastProjectileHitbox)

local projectileSerial = 1 -- incremented ever time e fire a projectile

local BasicProjectile = {}

--// --------------------------------------------------------------------
--// Handler Functions
--// --------------------------------------------------------------------

--// Initialize
function BasicProjectile.Initialize(params, abilityDefs)

    params.RenderRange = 700

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

    if abilityDefs.RequireToggle_On then
        if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
            params.CanRun = false
            return params
        end
    end

    BasicProjectile.Setup(params, abilityDefs)

end

--// Activate
function BasicProjectile.Activate(params, abilityDefs)

    local abilityMod = require(abilityDefs.AbilityMod)

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
    
    if abilityDefs.RequireToggle_On then
        if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
            params.CanRun = false
            return params
        end
    end

	-- set cooldown
    Cooldown.SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)

    -- block input
    if abilityMod.PlayerAnchorTime > 0 then
        require(Knit.PowerUtils.BlockInput).AddBlock(params.InitUserId, "BasicProjectile", abilityMod.PlayerAnchorTime)
    end
    
    -- run server
    BasicProjectile.Run_Server(params, abilityDefs)

end

--// Execute
function BasicProjectile.Execute(params, abilityDefs)

    -- run client
	BasicProjectile.Run_Client(params, abilityDefs)

end


--// --------------------------------------------------------------------
--// Ability Functions
--// --------------------------------------------------------------------

function BasicProjectile.Setup(params, abilityDefs)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

    local abilityMod = require(abilityDefs.AbilityMod)

    if abilityMod.PlayerAnchorTime > 0 then
        local lockParams = {}
        lockParams.Duration = abilityMod.PlayerAnchorTime
        lockParams.ShiftLock_NoSpin = true
        lockParams.AnchorCharacter = true
        MobilityLock.Client_AddLock(lockParams)
    end

    params.HRPOrigin = initPlayer.Character.HumanoidRootPart.CFrame

end

function BasicProjectile.Run_Server(params, abilityDefs)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    local abilityMod = require(abilityDefs.AbilityMod)

    -- setup ignore list
    local ignoreList = {initPlayer.Character}
    local masterList = require(Knit.Shared.RaycastProjectileHitbox.IgnoreList)
    for _, v in pairs(masterList) do
        table.insert(ignoreList, v)
    end
    local customIgnores = abilityMod.CustomIgnoreList
    for _, v in pairs(customIgnores) do
        table.insert(ignoreList, v)
    end

    -- player animations
    spawn(function()
        Knit.Services.PlayerUtilityService.PlayerAnimations[initPlayer.UserId].Point:Play()
        wait(abilityMod.PlayerAnchorTime)
        Knit.Services.PlayerUtilityService.PlayerAnimations[initPlayer.UserId].Point:Stop()
    end)

    -- get projectile origin
    local projectileOrigin = params.HRPOrigin:ToWorldSpace(abilityMod.CFrameOffest)
    local projectileID = params.InitUserId .. "_BasicProjectile_" .. projectileSerial
    projectileSerial = projectileSerial + 1
    params.projectileOrigin = projectileOrigin
    params.projectileID = projectileID

    -- setup raycast datapoints
    local sizeX = abilityMod.HitBox_Size_X
    local sizeY = abilityMod.HitBox_Size_Y
    local resolutionX = abilityMod.HitBox_Resolution_X
    local resolutionY = abilityMod.HitBox_Resolution_Y
    local dataPoints = hitboxMod:GetSquarePoints(projectileOrigin, sizeX, sizeY, resolutionX, resolutionY)

    -- raycast data
    local projectileData = {}
    projectileData["Points"] = dataPoints
    projectileData["Direction"] = projectileOrigin.LookVector
    projectileData["Velocity"] = abilityMod.Velocity
    projectileData["Lifetime"] = abilityMod.Lifetime
    projectileData["Iterations"] = abilityMod.Iterations
    --projectileData["Visualize"] = true
    projectileData["Ignore"] = ignoreList
    projectileData["BreakOnHit"] = abilityMod.BreakOnHit
    projectileData["BreakifNotHuman"] = abilityMod.BreakifNotHuman
    projectileData["BreakifHuman"] = abilityMod.BreakifHuman
    projectileData["BreakOnBlockAbility"] = abilityMod.BreakOnBlockAbility

    -- insert hitEffects into abilityDefs
    abilityDefs.HitEffects = abilityMod.HitEffects
    
    -- raycast result handling
    local hitCharacters = {}
    projectileData["Function"] = function(result)
        if result.Instance.Parent then

            if not hitCharacters[result.Instance.Parent] then

                if result.Instance.Parent:FindFirstChild("Humanoid") then
                    hitCharacters[result.Instance.Parent] = true
                end

                abilityMod.HitBoxResult(initPlayer, params, abilityDefs, result)

            end
        end
    end

    hitboxMod:CastProjectileHitbox(projectileData)

end

function BasicProjectile.Run_Client(params, abilityDefs)

    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    local abilityMod = require(abilityDefs.AbilityMod)

    -- setup cosmetic projectile
    local projectile = abilityMod.SetupCosmetic(initPlayer, params, abilityDefs)
  
    -- run effects
    if abilityMod.FireEffects then
        abilityMod.FireEffects(initPlayer, projectile, params, abilityDefs)
    end

    -- shoot it
    projectile.BodyVelocity.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
    projectile.BodyVelocity.P = abilityMod.Velocity
    projectile.BodyVelocity.Velocity = params.projectileOrigin.LookVector * abilityMod.Velocity
    projectile.CFrame = params.projectileOrigin
    projectile.Name = params.projectileID
    projectile.Parent = Workspace.RenderedEffects

end

return BasicProjectile