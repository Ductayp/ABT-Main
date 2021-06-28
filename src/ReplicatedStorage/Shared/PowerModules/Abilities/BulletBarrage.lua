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
local MobilityLock = require(Knit.PowerUtils.MobilityLock)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)
local hitboxMod = require(Knit.Shared.RaycastProjectileHitbox)

local Velocity = 300
local Lifetime = 2
local PlayerAnchorTime = 1
local bulletSerial = 1 -- incremented ever time e fire a bullet
local shotCount = 10
local shotDelay = .08

local BulletLaunch = {}

--// --------------------------------------------------------------------
--// Handler Functions
--// --------------------------------------------------------------------

--// Initialize
function BulletLaunch.Initialize(params, abilityDefs)

	-- checks
	if params.KeyState == "InputBegan" then params.CanRun = true end
    if params.KeyState == "InputEnded" then params.CanRun = false return end
    if not Cooldown.Client_IsCooled(params) then params.CanRun = false return end
    if not Cooldown.Server_IsCooled(params) then params.CanRun = false return end
    if abilityDefs.RequireToggle_On then
        if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then params.CanRun = false return end
    end

    Cooldown.Client_SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)
    
    BulletLaunch.Setup(params, abilityDefs)

end

--// Activate
function BulletLaunch.Activate(params, abilityDefs)

	-- checks
	if params.KeyState == "InputBegan" then params.CanRun = true end
    if params.KeyState == "InputEnded" then params.CanRun = false return end
    if not Cooldown.Server_IsCooled(params) then params.CanRun = false return end
    if abilityDefs.RequireToggle_On then
        if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then params.CanRun = false return end
    end

    Cooldown.Server_SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)

    -- block input
    require(Knit.PowerUtils.BlockInput).AddBlock(params.InitUserId, "BulletLaunch", 1.25)

    -- tween hitbox
    BulletLaunch.Run_Server(params, abilityDefs)

end

--// Execute
function BulletLaunch.Execute(params, abilityDefs)

    -- tween effects
	BulletLaunch.Run_Client(params, abilityDefs)

end


--// --------------------------------------------------------------------
--// Ability Functions
--// --------------------------------------------------------------------

function BulletLaunch.Setup(params, abilityDefs)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

    local lockParams = {}
    lockParams.Duration = PlayerAnchorTime
    lockParams.ShiftLock_NoSpin = true
    lockParams.AnchorCharacter = true
    MobilityLock.Client_AddLock(lockParams)

    params.HRPOrigin = initPlayer.Character.HumanoidRootPart.CFrame

end

function BulletLaunch.Run_Server(params, abilityDefs)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    local rootPart = initPlayer.Character.HumanoidRootPart

    local ignoreList = {initPlayer.Character}
    local masterList = require(Knit.Shared.RaycastProjectileHitbox.IgnoreList)
    for _, v in pairs(masterList) do
        table.insert(ignoreList, v)
    end

    spawn(function()
        Knit.Services.PlayerUtilityService.PlayerAnimations[initPlayer.UserId].Point:Play()
        wait(PlayerAnchorTime)
        Knit.Services.PlayerUtilityService.PlayerAnimations[initPlayer.UserId].Point:Stop()
    end)

    params.BulletsFired = {}
    for count = 1, shotCount do
        local randX = math.random(-250,250) / 100
        local randY = math.random(-200,200) / 100
        local bulletOrigin = params.HRPOrigin:ToWorldSpace(CFrame.new(randX, randY, -2))
        local bulletID = params.InitUserId .. "_BulletBarrage_" .. bulletSerial
        bulletSerial = bulletSerial + 1
        params.BulletsFired[count] = {}
        params.BulletsFired[count].Origin = bulletOrigin
        params.BulletsFired[count].ID = bulletID

        local dataPoints = hitboxMod:GetSquarePoints(bulletOrigin, 1, 1)

        local projectileData = {}
        projectileData["Points"] = dataPoints
        projectileData["Direction"] = bulletOrigin.LookVector
        projectileData["Velocity"] = Velocity
        projectileData["Lifetime"] = Lifetime
        projectileData["Iterations"] = 2000
        projectileData["Visualize"] = false
        projectileData["Ignore"] = ignoreList

        projectileData["Function"] = function(result)
            if result.Instance.Parent then

                local resultParams = {}
                resultParams.Position = result.Position
                resultParams.BulletID = bulletID
                Knit.Services.PowersService:RenderAbilityEffect_AllPlayers(script, "BulletImpact", resultParams)
                if result.Instance.Parent:FindFirstChild("Humanoid") then
                    Knit.Services.PowersService:RegisterHit(initPlayer, result.Instance.Parent, abilityDefs)
                end
            end
        end

        spawn(function()
            local waitTime = (shotDelay * count) - shotDelay
            wait(waitTime)
            hitboxMod:CastProjectileHitbox(projectileData)
        end)

    end

end

function BulletLaunch.Run_Client(params, abilityDefs)

    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    local rootPart = initPlayer.Character.HumanoidRootPart

    -- setup the stand, if its not there then dont run return
	local targetStand = Workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		targetStand = ManageStand.QuickRender(params)
    end

    -- run animations, stand position
    spawn(function()
        ManageStand.MoveStand(params, "Front")
        ManageStand.PlayAnimation(params, "Barrage")
        ManageStand.Aura_On(params)
        wait(PlayerAnchorTime)
        ManageStand.MoveStand(params, "Idle")
        ManageStand.StopAnimation(params, "Barrage")
        ManageStand.Aura_Off(params)
    end)
 
    -- play the sound when it is fired
	WeldedSound.NewSound(targetStand.HumanoidRootPart, ReplicatedStorage.Audio.General.GenericWhoosh_Fast)

    for count = 1, shotCount do

        local thisBulletDef = params.BulletsFired[count]

        local bullet = ReplicatedStorage.EffectParts.Abilities.BulletBarrage.MeshBullet:Clone()
        bullet.BodyVelocity.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
        bullet.BodyVelocity.P = Velocity

        bullet.BodyVelocity.Velocity = thisBulletDef.Origin.LookVector * Velocity
        bullet.CFrame = thisBulletDef.Origin
        bullet.Name = thisBulletDef.ID

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

    end

end

function BulletLaunch.BulletImpact(params)

    local bulletPart = Workspace.RenderedEffects:FindFirstChild(params.BulletID)
    if bulletPart then
        bulletPart:Destroy()
    end

    local newBurst = ReplicatedStorage.EffectParts.Abilities.BulletBarrage.Burst:Clone()
    newBurst.Position = params.Position
    newBurst.Parent = Workspace.RenderedEffects
    Debris:AddItem(newBurst, 2)

    local sizeTween = TweenService:Create(newBurst, TweenInfo.new(.5),{Size = Vector3.new(3,3,3)})
    local transparencyTween = TweenService:Create(newBurst, TweenInfo.new(.5),{Transparency = 1})

    sizeTween:Play()
    transparencyTween:Play()

end

return BulletLaunch