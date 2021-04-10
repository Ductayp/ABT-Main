-- WallBlast Ability
-- PDab
-- 12-1-2020

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local AbilityToggle = require(Knit.PowerUtils.AbilityToggle)
local MobilityLock = require(Knit.PowerUtils.MobilityLock)
local ManageStand = require(Knit.Abilities.ManageStand)
local Cooldown = require(Knit.PowerUtils.Cooldown)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)
local hitboxMod = require(Knit.Shared.RaycastProjectileHitbox)

-- variables
local lastWallBlast = "WallBlast_2"

local WallBlast = {}


--// --------------------------------------------------------------------
--// Handler Functions
--// --------------------------------------------------------------------

--// Initialize
function WallBlast.Initialize(params, abilityDefs)

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

    WallBlast.Setup(params, abilityDefs)
    
end

--// Activate
function WallBlast.Activate(params, abilityDefs)

	-- check KeyState
	if params.KeyState == "InputBegan" then
		params.CanRun = true
	else
		params.CanRun = false
		return params
    end
    
    -- check cooldown
	if not Cooldown.Client_IsCooled(params) then
		params.CanRun = false
		return
    end

	-- set cooldown
    Cooldown.SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)

    -- block input
    require(Knit.PowerUtils.BlockInput).AddBlock(params.InitUserId, "WallBlast", 2)

    WallBlast.Run_Server(params, abilityDefs)
    
end

--// Execute
function WallBlast.Execute(params, abilityDefs)

	WallBlast.Run_Effects(params, abilityDefs)

end


--// --------------------------------------------------------------------
--// Ability Functions
--// --------------------------------------------------------------------

function WallBlast.Setup(params, abilityDefs)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

    local lockParams = {}
    lockParams.Duration = 1
    lockParams.ShiftLock_NoSpin = true
    lockParams.AnchorCharacter = true
    MobilityLock.Client_AddLock(lockParams)

    params.HRPOrigin = initPlayer.Character.HumanoidRootPart.CFrame

end

function WallBlast.Run_Server(params, abilityDefs)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

    spawn(function()
        Knit.Services.PlayerUtilityService.PlayerAnimations[initPlayer.UserId].Point:Play()
        wait(1)
        Knit.Services.PlayerUtilityService.PlayerAnimations[initPlayer.UserId].Point:Stop()
    end)

    local newCFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0, 1.5, -10))
    local serverWall = ReplicatedStorage.EffectParts.Abilities.WallBlast.ServerWall:Clone()
    serverWall.CFrame = newCFrame
    serverWall.Parent = Workspace.RenderedEffects_BlockAbility
    params.WallCFrame = newCFrame

    --[[
    abilityDefs.HitEffects = {}
    abilityDefs.HitEffects.Damage = {Damage = 30}
    abilityDefs.HitEffects.Blast = {}
    abilityDefs.HitEffects.KnockBack = {Force = 70, ForceY = 50, LoockVector = newCFrame.LookVector}
    ]]--

    abilityDefs.HitEffects.KnockBack.LookVector = newCFrame.LookVector

    spawn(function()
        wait(abilityDefs.Duration)
        serverWall:Destroy()

        local dataPoints = hitboxMod:GetSquarePoints(newCFrame, 15, 10)

        local projectileData = {}
        projectileData["Points"] = dataPoints
        projectileData["Direction"] = newCFrame.LookVector
        projectileData["Velocity"] = 700
        projectileData["Lifetime"] = .1
        projectileData["Iterations"] = 200
        projectileData["Visualize"] = false
        projectileData["BreakOnHit"] = false
        projectileData["Ignore"] = require(Knit.Shared.RaycastProjectileHitbox.IgnoreList)

        projectileData["Function"] = function(result)
            if result.Instance.Parent then

                --local resultParams = {}
                --resultParams.Position = result.Position
                --resultParams.BulletID = bulletID
                --Knit.Services.PowersService:RenderAbilityEffect_AllPlayers(script, "BulletImpact", resultParams)

                if result.Instance.Parent:FindFirstChild("Humanoid") then
                    --print("HIT A HUMANOID", result.Instance.Parent)
                    Knit.Services.PowersService:RegisterHit(initPlayer, result.Instance.Parent, abilityDefs)
                end
            end
        end

        hitboxMod:CastProjectileHitbox(projectileData)

    end)


end

function WallBlast.Run_Effects(params, abilityDefs)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    if not initPlayer then
        return
    end

    -- set blastTime now, use it later!
    local blastTime = os.clock() + abilityDefs.Duration

    -- setup the stand, if its not there then make it
	local targetStand = Workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		targetStand = ManageStand.QuickRender(params)
    end

    -- stand animations
    spawn(function()
        ManageStand.PlayAnimation(params, "Point")
        ManageStand.Aura_On(params)
        wait(1)
        ManageStand.StopAnimation(params, "Point")
        wait(3)
        ManageStand.Aura_Off(params)
    end)
    
    -- setup the newWall
    local verticalOffset = 10
    local newWall = ReplicatedStorage.EffectParts.Abilities.WallBlast.ClientWall:Clone()
    newWall.CFrame = params.WallCFrame
    newWall.CFrame = params.WallCFrame * CFrame.new(0, -verticalOffset, 0)
    newWall.Parent = Workspace.RenderedEffects

    -- baseParticles
    local baseParticle = ReplicatedStorage.EffectParts.Abilities.WallBlast.BaseParticles:Clone()
    baseParticle.CFrame = params.WallCFrame * CFrame.new(0, -4, 0)
    baseParticle.Parent = Workspace.RenderedEffects

    -- play the sound when it is fired
    WeldedSound.NewSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.General.ARFire)
	WeldedSound.NewSound(baseParticle, ReplicatedStorage.Audio.General.RocksFalling)

    -- shake wall into place
    local renderCount = 0
    local renderSteps = 20
    local renderLength = .2
    while renderCount < renderSteps do
        local verticalRise = verticalOffset / renderSteps
        local randX = math.random(-10,10) / 100
        local randZ = math.random(-10,10) / 100
        newWall.CFrame = newWall.CFrame * CFrame.new(randX, verticalRise, randZ)
        renderCount += 1
        wait(renderLength / renderSteps)
    end
    newWall.CFrame = params.WallCFrame
    baseParticle.ParticleEmitter_1.Enabled = false
    baseParticle.ParticleEmitter_2.Enabled = false
    baseParticle.ParticleEmitter_3.Enabled = false
    Debris:AddItem(baseParticle, 2)

    -- setup the blastBricks
    local blastBricks = {}
    for i, v in pairs(newWall:GetChildren()) do
        if v.Name == "Blast" then
            local brick = v:Clone()
            brick.CFrame = v.CFrame

            -- bodyVelocity settings
            local maxForce = 1000 --math.huge
            brick.BodyVelocity.MaxForce = Vector3.new(maxForce,maxForce,maxForce)
            brick.BodyVelocity.P = 1000
            local randVelocity = math.random(150,300)
            brick.BodyVelocity.Velocity = newWall.CFrame.LookVector * randVelocity

            -- angularVelocity settings
            local randX = math.random(-10,10)
            local randY = math.random(-10,10)
            local randZ = math.random(-10,10)
            brick.BodyAngularVelocity.AngularVelocity = Vector3.new(randX, randY, randZ)

            table.insert(blastBricks, brick)
        end
    end

    -- semi-accurate wait
    while os.clock() < blastTime do
        wait()
    end

    for _, brick in pairs(blastBricks) do
        brick.Parent = Workspace.RenderedEffects
        Debris:AddItem(brick, 5)

        local transparencyTween = TweenService:Create(brick, TweenInfo.new(1),{Transparency = 1})
        transparencyTween:Play()
    end
    
    newWall:Destroy()
    

end

return WallBlast


