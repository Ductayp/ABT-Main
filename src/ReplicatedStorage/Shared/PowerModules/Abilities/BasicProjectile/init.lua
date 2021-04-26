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
local ManageStand = require(Knit.Abilities.ManageStand)
local Cooldown = require(Knit.PowerUtils.Cooldown)
local MobilityLock = require(Knit.PowerUtils.MobilityLock)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)
local hitboxMod = require(Knit.Shared.RaycastProjectileHitbox)

local projectileSerial = 1 -- incremented ever time e fire a projectile

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
    
    if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
        params.CanRun = false
        return params
    end

	-- set cooldown
    Cooldown.SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)

    -- block input
    require(Knit.PowerUtils.BlockInput).AddBlock(params.InitUserId, "BasicProjectile", abilityMod.PlayerAnchorTime + 0.25)

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

    local lockParams = {}
    lockParams.Duration = abilityMod.PlayerAnchorTime
    lockParams.ShiftLock_NoSpin = true
    lockParams.AnchorCharacter = true
    MobilityLock.Client_AddLock(lockParams)

    params.HRPOrigin = initPlayer.Character.HumanoidRootPart.CFrame

end

function BasicProjectile.Run_Server(params, abilityDefs)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

    --print("params CFrame", params.HRPOrigin)
    --print("initPlayer CFrame", initPlayer.Character.HumanoidRootPart.CFrame)

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
    projectileData["Visualize"] = false
    projectileData["Ignore"] = ignoreList
    projectileData["BreakOnHit"] = abilityMod.BreakOnHit
    projectileData["BreakifNotHuman"] = abilityMod.BreakifNotHuman
    projectileData["BreakifHuman"] = abilityMod.BreakifHuman
    projectileData["BreakOnBlockAbility"] = abilityMod.BreakOnBlockAbility

    -- insert hitEffects into abilityDefs
    abilityDefs.HitEffects = abilityMod.HitEffects
    
    -- raycast result handling
    projectileData["Function"] = function(result)
        if result.Instance.Parent then

            local resultParams = {}
            resultParams.Position = result.Position
            resultParams.ProjectileID = projectileID
            resultParams.AbilityDefs = abilityDefs
            Knit.Services.PowersService:RenderAbilityEffect_AllPlayers(script, "ProjectileImpact", resultParams)

            --if abilityMod.ProjectileHit then
            abilityMod.HitBoxResult(initPlayer, abilityDefs, result, params)
            --end

        end
    end

    hitboxMod:CastProjectileHitbox(projectileData)

end

function BasicProjectile.Run_Client(params, abilityDefs)

    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

    -- setup the stand, if its not there then dont run return
	local targetStand = Workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		targetStand = ManageStand.QuickRender(params)
    end

    local abilityMod = require(abilityDefs.AbilityMod)

    -- run animations, stand position
    spawn(function()
        ManageStand.MoveStand(params, abilityMod.StandPostion)
        ManageStand.PlayAnimation(params, abilityMod.StandAnimation)
        ManageStand.Aura_On(params)
        wait(abilityMod.PlayerAnchorTime)
        ManageStand.MoveStand(params, "Idle")
        ManageStand.StopAnimation(params, abilityMod.StandAnimation)
        ManageStand.Aura_Off(params)
    end)
 
    -- play the sound when it is fired
	WeldedSound.NewSound(initPlayer.Character.HumanoidRootPart, abilityMod.FireSound)

    local projectile
    if abilityMod.SpawnProjectile then
        projectile = abilityMod.SpawnProjectile(params.projectileOrigin)
    else
        projectile = abilityMod.CosmeticProjectile:Clone()
    end

    --local projectile = abilityMod.CosmeticProjectile:Clone()
    projectile.BodyVelocity.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
    projectile.BodyVelocity.P = abilityMod.Velocity

    projectile.BodyVelocity.Velocity = params.projectileOrigin.LookVector * abilityMod.Velocity
    projectile.CFrame = params.projectileOrigin
    --print("CFRAME CHECK 1: ", projectile.CFrame, " 2: ", params.projectileOrigin)
    projectile.Name = params.projectileID

    projectile.Touched:Connect(function(hit)
        if hit.Parent.Name == "RenderedEffects_BlockAbility" then
            projectile:Destroy()
        end
    end)

    projectile.Parent = Workspace.RenderedEffects

    spawn(function()
        wait(abilityMod.Lifetime)
        --projectile:Destroy()
    end)

end

function BasicProjectile.ProjectileImpact(params)

    local abilityMod = require(params.AbilityDefs.AbilityMod)
    local projectilePart = Workspace.RenderedEffects:FindFirstChild(params.ProjectileID)

    if projectilePart then
        if abilityMod.DestroyCosmetic then
            abilityMod.DestroyCosmetic(projectilePart, params)
        else
            projectilePart:Destroy()
        end
    end

end


return BasicProjectile