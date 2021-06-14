-- ProjectileBarrage

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
local BlockInput = require(Knit.PowerUtils.BlockInput)
local MobilityLock = require(Knit.PowerUtils.MobilityLock)
local hitboxMod = require(Knit.Shared.RaycastProjectileHitbox)

local bulletSerial = 1

local ProjectileBarrage = {}

--// --------------------------------------------------------------------
--// Handler Functions
--// --------------------------------------------------------------------

--// Initialize
function ProjectileBarrage.Initialize(params, abilityDefs)

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

    if not Players.LocalPlayer.Character then return end

    local abilityMod = require(abilityDefs.AbilityMod)

    local playerPing = Knit.Controllers.PlayerUtilityController:GetPing()
    abilityMod.CharacterAnimations(params, abilityDefs, playerPing)

    MobilityLock.Client_AddLock(abilityMod.MobilityLockParams)

    params.HRPOrigin = Players.LocalPlayer.Character.HumanoidRootPart.CFrame
    
end

--// Activate
function ProjectileBarrage.Activate(params, abilityDefs)

	if params.KeyState == "InputBegan" then
		params.CanRun = true
	else
		params.CanRun = false
		return params
    end
    
    if not Cooldown.Server_IsCooled(params) then
        params.CanRun = false
        return params
    end
    
    if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
        params.CanRun = false
        return params
    end

    local abilityMod = require(abilityDefs.AbilityMod)

    Cooldown.SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)
    BlockInput.AddBlock(params.InitUserId, "ProjectileBarrage", abilityMod.InputBlockTime)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    local rootPart = initPlayer.Character.HumanoidRootPart

    local ignoreList = {initPlayer.Character}
    local masterList = require(Knit.Shared.RaycastProjectileHitbox.IgnoreList)
    for _, v in pairs(masterList) do
        table.insert(ignoreList, v)
    end

    params.ProjectilesFired = {}
    for count = 1, abilityMod.ShotCount do

        local offsetX = math.random(-abilityMod.Offset_X * 100, abilityMod.Offset_X * 100) / 100
        local offsetY = math.random(-abilityMod.Offset_Y * 100, abilityMod.Offset_Y * 100) / 100
        local offsetZ = abilityMod.Offset_Z

        local bulletOrigin = params.HRPOrigin:ToWorldSpace(CFrame.new(offsetX, offsetY, offsetZ))

        local bulletID = params.InitUserId .. "_ProjectileBarrage_" .. bulletSerial
        bulletSerial = bulletSerial + 1

        params.ProjectilesFired[count] = {}
        params.ProjectilesFired[count].Origin = bulletOrigin
        params.ProjectilesFired[count].ID = bulletID

        local dataPoints = hitboxMod:GetSquarePoints(bulletOrigin, abilityMod.Size_X, abilityMod.Size_Y)

        local projectileData = {}
        projectileData["Points"] = dataPoints
        projectileData["Direction"] = bulletOrigin.LookVector
        projectileData["Velocity"] = abilityMod.Velocity
        projectileData["Lifetime"] = abilityMod.Lifetime
        projectileData["Iterations"] = abilityMod.Iterations
        --projectileData["Visualize"] = true
        projectileData["Ignore"] = ignoreList

        projectileData["Function"] = function(result)
            if result.Instance.Parent then

                local resultParams = {}
                resultParams.Position = result.Position
                resultParams.BulletID = bulletID
                Knit.Services.PowersService:RenderAbilityEffect_AllPlayers(abilityDefs.AbilityMod, "ProjectileImpact", resultParams)

                if result.Instance.Parent:FindFirstChild("Humanoid") then
                    --print("HIT A HUMANOID", result.Instance.Parent)
                    Knit.Services.PowersService:RegisterHit(initPlayer, result.Instance.Parent, abilityMod.HitEffects)
                end
            end
        end

        spawn(function()

            local playerPing = Knit.Services.PlayerUtilityService:GetPing(initPlayer)
            local initialWait = abilityMod.InitialDelay - (playerPing / 2)
            if initialWait > 0 then
                wait(initialWait)
            end

            print("SERVER WAIT", initialWait)
            
            local shotWait = (abilityMod.ShotDelay * count) - abilityMod.ShotDelay
            wait(shotWait)

            hitboxMod:CastProjectileHitbox(projectileData)
        end)
    end
end

--// Execute
function ProjectileBarrage.Execute(params, abilityDefs)

    local abilityMod = require(abilityDefs.AbilityMod)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    if initPlayer and initPlayer ~= Players.LocalPlayer then
        abilityMod.CharacterAnimations(params, abilityDefs)
    end

    local playerPing = Knit.Controllers.PlayerUtilityController:GetPing()
    local initialWait = abilityMod.InitialDelay - (playerPing / 2)
    if initialWait > 0 then
        wait(initialWait)
    end

    --local shotCount = 1
    for projectileCount, projectileDef in pairs(params.ProjectilesFired) do

        local projectileModel = abilityMod.GetProjectile()

        projectileModel.BodyVelocity.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
        projectileModel.BodyVelocity.P = abilityMod.Velocity

        projectileModel.BodyVelocity.Velocity = projectileDef.Origin.LookVector * abilityMod.Velocity
        projectileModel.Name = projectileDef.ID

        projectileModel.Touched:Connect(function(hit)
            if hit.Parent.Name == "RenderedEffects_BlockAbility" then
                projectileModel:Destroy()
            end
        end)

        spawn(function()
            local waitTime = (abilityMod.ShotDelay * projectileCount) - abilityMod.ShotDelay
            print("WAiT 2", waitTime)
            wait(waitTime)
            projectileModel.Parent = Workspace.RenderedEffects
            projectileModel.CFrame = projectileDef.Origin
            abilityMod.ProjectileEffects(projectileModel, projectileDef)
        end)




        --[[
        local projectileDef = params.ProjectilesFired[count]

        local bullet = abilityMod.GetProjectile()

        bullet.BodyVelocity.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
        bullet.BodyVelocity.P = Velocity

        bullet.BodyVelocity.Velocity = projectileDef.Origin.LookVector * Velocity
        bullet.CFrame = projectileDef.Origin
        bullet.Name = projectileDef.ID

        bullet.Touched:Connect(function(hit)
            if hit.Parent.Name == "RenderedEffects_BlockAbility" then
                bullet:Destroy()
            end
        end)

        spawn(function()
            local waitTime = (shotDelay * count) - shotDelay
            wait(waitTime)
            WeldedSound.NewSound(targetStand.HumanoidRootPart, ReplicatedStorage.Audio.General.GunShot)
            bullet.Parent = Workspace.RenderedEffects
        end)

        spawn(function()
            wait(Lifetime)
            bullet:Destroy()
        end)
        ]]--

    end


end

return ProjectileBarrage