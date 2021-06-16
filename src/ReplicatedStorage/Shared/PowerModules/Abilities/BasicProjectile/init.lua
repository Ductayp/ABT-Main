-- Basic Projectile
-- PDab
-- 11-27-2020

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

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

------------------------------------------------------------------------------------------------------------------------------
--// Initialize --------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
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

    local abilityMod = require(abilityDefs.AbilityMod)

    MobilityLock.Client_AddLock(abilityMod.MobilityLockParams)

    local playerPing = Knit.Controllers.PlayerUtilityController:GetPing()
    local delayOffset = playerPing / 2
    abilityMod.CharacterAnimations(params, abilityDefs, delayOffset)

    params.HRPOrigin = Players.LocalPlayer.Character.HumanoidRootPart.CFrame

end

------------------------------------------------------------------------------------------------------------------------------
--// Activate ----------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
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
    if abilityMod.InputBlockTime > 0 then
        require(Knit.PowerUtils.BlockInput).AddBlock(params.InitUserId, "BasicProjectile", abilityMod.InputBlockTime)
    end
    
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
    projectileData["Ignore"] = ignoreList

    projectileData["BreakOnHit"] = abilityMod.BreakOnHit
    projectileData["BreakifHuman"] = abilityMod.BreakifHuman
    projectileData["BreakOnBlockAbility"] = abilityMod.BreakOnBlockAbility

    --projectileData["Visualize"] = true

    -- insert hitEffects into abilityDefs
    --abilityDefs.HitEffects = abilityMod.HitEffects
    
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

    spawn(function()

        wait(abilityMod.InitialDelay)
        hitboxMod:CastProjectileHitbox(projectileData)
    end)


end

------------------------------------------------------------------------------------------------------------------------------
--// Execute -----------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
function BasicProjectile.Execute(params, abilityDefs)

    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    local abilityMod = require(abilityDefs.AbilityMod)

    local playerPing = Knit.Controllers.PlayerUtilityController:GetPing()

    local playerPing = Knit.Controllers.PlayerUtilityController:GetPing()
    --local delayOffset = playerPing / 2
    local delayOffset = playerPing
    --local delayOffset = playerPing * 2

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    if initPlayer and initPlayer ~= Players.LocalPlayer then

        print("I SHOULDNT SEE THIS")
        abilityMod.CharacterAnimations(params, abilityDefs, -delayOffset)
    end

    -- setup cosmetic projectile
    local projectile = abilityMod.SetupCosmetic(initPlayer, params, abilityDefs)

    --[[
    local delay = abilityMod.InitialDelay - delayOffset
    if delay > 0 then
        --wait(delay)
        print("DID A WAIT")
    end

    print("PLAYER PING", playerPing)
    print("DELAY OFFSET", delayOffset)
    print("INITIAL DELAY", abilityMod.InitialDelay)
    print("DELAY @@@", delay)
    ]]--

    wait(abilityMod.InitialDelay)
  
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

    wait(abilityMod.Lifetime)
    if projectile then
        abilityMod.EndCosmetic(projectile)
    end
    


end

return BasicProjectile