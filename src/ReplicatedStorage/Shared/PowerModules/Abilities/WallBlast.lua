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

    if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
        params.CanRun = false
        return params
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

    if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
        params.CanRun = false
        return params
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

        local charactersHit = {} -- table to hld characters already hit so we dont hit them twice

        projectileData["Function"] = function(result)
            if result.Instance.Parent then

                if result.Instance.Parent:FindFirstChild("Humanoid") then
                    --print("HIT A HUMANOID", result.Instance.Parent)
                    local canHit = true
                    for _, v in pairs(charactersHit) do
                        if v == result.Instance.Parent then
                            canHit = false
                        end
                    end

                    if canHit then
                        table.insert(charactersHit, result.Instance.Parent)
                        Knit.Services.PowersService:RegisterHit(initPlayer, result.Instance.Parent, abilityDefs)
                    end
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
	WeldedSound.NewSound(baseParticle, ReplicatedStorage.Audio.General.CrashRocks)
    spawn(function()
        wait(1.1)
        WeldedSound.StopSound(baseParticle, "CrashRocks", .5)
    end)

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
            local maxForce = math.huge
            brick.BodyVelocity.MaxForce = Vector3.new(maxForce,maxForce,maxForce)
            brick.BodyVelocity.P = 2000
            local randVelocity = math.random(200,300)
            brick.BodyVelocity.Velocity = newWall.CFrame.LookVector * randVelocity

            -- angularVelocity settings
            local randX = math.random(-10,10)
            local randY = math.random(-10,10)
            local randZ = math.random(-10,10)
            brick.BodyAngularVelocity.AngularVelocity = Vector3.new(randX, randY, randZ)


            local whiteBlock = brick:Clone()
            whiteBlock.Name = "white"
            whiteBlock.Size = Vector3.new(.5,.5,.5)
            whiteBlock.Color= Color3.fromRGB(255, 255, 255)

            local randX = math.random(-100, 100) / 100
            local randZ = math.random(-100, 100) / 100
            whiteBlock.CFrame = v.CFrame * CFrame.new(randX, randY, 0)

            table.insert(blastBricks, whiteBlock)
            table.insert(blastBricks, brick)
        end
    end

    -- semi-accurate wait
    while os.clock() < blastTime do
        wait()
    end

    for _, brick in pairs(blastBricks) do
        brick.Parent = Workspace.RenderedEffects
        --local transparencyTween = TweenService:Create(brick, TweenInfo.new(.4),{Transparency = 1})
        --transparencyTween:Play()
        spawn(function()
            wait(.15)
            brick:Destroy()
        end)
    end
    
    local blastMesh_1 = ReplicatedStorage.EffectParts.Abilities.WallBlast.BlastMesh_1:Clone()
    blastMesh_1.CFrame = params.WallCFrame
    blastMesh_1.Parent = Workspace.RenderedEffects

    local blastMesh_2 = ReplicatedStorage.EffectParts.Abilities.WallBlast.BlastMesh_2:Clone()
    blastMesh_2.CFrame = params.WallCFrame
    blastMesh_2.Parent = Workspace.RenderedEffects

    local blastMesh_3 = ReplicatedStorage.EffectParts.Abilities.WallBlast.BlastMesh_3:Clone()
    blastMesh_3.CFrame = params.WallCFrame
    blastMesh_3.Parent = Workspace.RenderedEffects

    --[[
    local tween_1 = TweenService:Create(blastMesh_1, weenInfo.new(.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Transparency = 1})
    local tween_2 = TweenService:Create(blastMesh_1, weenInfo.new(.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Transparency = 1})
    ]]--

    local allTweens = {}
    allTweens.BlastMesh_1 = {
        Part = blastMesh_1.shock_1,
        DebrisTime = 5,
        Tweens = {
            --[[
            SizeTween = {
                Tween_Info = TweenInfo.new(.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                Tween_Params = {Size = Vector3.new(2,2,2)},
                Delay = 0
            },
            ]]--
            TransparencyTween = {
                Tween_Info = TweenInfo.new(1),
                Tween_Params = {Transparency = 1},
                Delay = 0
            },
        }
    }

    allTweens.BlastMesh_2 = {
        Part = blastMesh_2.shock_2,
        DebrisTime = 5,
        Tweens = {
            --[[
            SizeTween = {
                Tween_Info = TweenInfo.new(.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                Tween_Params = {Size = Vector3.new(2,2,2)},
                Delay = 0
            },
            ]]--
            TransparencyTween = {
                Tween_Info = TweenInfo.new(1),
                Tween_Params = {Transparency = 1},
                Delay = 0
            },
        }
    }

    allTweens.BlastMesh_3 = {
        Part = blastMesh_3.Smoke,
        DebrisTime = 5,
        Tweens = {
            SizeTween = {
                Tween_Info = TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                Tween_Params = {Size = Vector3.new(25,25,25)},
                Delay = 0
            },
            TransparencyTween = {
                Tween_Info = TweenInfo.new(4),
                Tween_Params = {Transparency = 1},
                Delay = 1
            },
        }
    }

    -- setup and tween
    for _, partTable in pairs(allTweens) do

        print("partTable", partTable)

        Debris:AddItem(partTable.Part, partTable.DebrisTime)

        for _,tween in pairs(partTable.Tweens) do

            spawn(function()
                wait(tween.Delay)
                local thisTween = TweenService:Create(partTable.Part, tween.Tween_Info, tween.Tween_Params)
                thisTween:Play()
                print("YEET")
                --thisTween = nil
            end)

        end
    end

    WeldedSound.NewSound(blastMesh_3, ReplicatedStorage.Audio.General.Explosion_1)
    newWall:Destroy()

end

return WallBlast


