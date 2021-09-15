-- GravitySlam

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)
local AnchoredSound = require(Knit.PowerUtils.AnchoredSound)
local ManageStand = require(Knit.Abilities.ManageStand)
local TargetByZone = require(Knit.PowerUtils.TargetByZone)
local CamShakeTools = require(Knit.PowerUtils.CamShakeTools)


local module = {}

module.InputBlockTime = 1

-- MobilityLock params
module.MobilityLockParams = {}
module.MobilityLockParams.Duration = 1
module.MobilityLockParams.ShiftLock_NoSpin = true
module.MobilityLockParams.AnchorCharacter = true

local EFFECT_DURATION = 3
local RANGE = 30
local HIT_DELAY = .4
local SLAM_OFFSET = CFrame.new(0, -3, -5)

--// Server_Setup
function module.Server_Setup(params, abilityDefs, initPlayer)
    params.GravitySlamCFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(SLAM_OFFSET)
end

--// Server_Run
function module.Server_Run(params, abilityDefs, initPlayer)

    wait(HIT_DELAY)

    if not initPlayer then return end

    local character = initPlayer.Character
    if not character then return end

    local HRP = character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end

    local endTime = os.clock() + EFFECT_DURATION

    spawn(function()
        Knit.Services.StateService:AddEntryToState(initPlayer, "WalkSpeed", "GravityShift", 6, nil)
        wait(EFFECT_DURATION)
        Knit.Services.StateService:RemoveEntryFromState(initPlayer, "WalkSpeed", "GravityShift")
    end)

    hitCharacters = TargetByZone.GetAllInRange(initPlayer, HRP.Position, RANGE, true)

    for _, character in pairs(hitCharacters) do

        if not character:FindFirstChild("Flag_GravitySlam", true) then

            spawn(function()
                local newFlag = Instance.new("BoolValue")
                newFlag.Name = "Flag_GravitySlam"
                newFlag.Parent = character
                wait(EFFECT_DURATION + 1)
                newFlag:Destroy()
            end)

            abilityDefs.HitEffects = {
                Damage = {Damage = 1},
                PinCharacter = {Duration = EFFECT_DURATION},
            }

            Knit.Services.PowersService:RegisterHit(initPlayer, character, abilityDefs)


            abilityDefs.HitEffects = {
                RunFunctions = {
                    {RunOn = "Server", Script = script, FunctionName = "Server_GravityEffect", Arguments = {SlamOriginCFrame = params.GravitySlamCFrame}},
                    {RunOn = "Client", Script = script, FunctionName = "Client_GravityEffect", Arguments = {SlamOriginCFrame = params.GravitySlamCFrame}},
                },
            }

            Knit.Services.PowersService:RegisterHit(initPlayer, character, abilityDefs)

        end
    end

    
end


function module.Server_GravityEffect(params)

    if not params.HitCharacter then return end
    local HRP = params.HitCharacter:FindFirstChild("HumanoidRootPart")
    if not HRP then return end

    HRP.Anchored = true

    params.HitCharacterOrigin = HRP.CFrame

    local floatTween_A = TweenService:Create(HRP, TweenInfo.new(.2), {CFrame = HRP.CFrame:ToWorldSpace(CFrame.new(0,10,0))})
    floatTween_A:Play()

    if params.HitParams.IsMob then

        local duration = (EFFECT_DURATION)
        require(Knit.MobUtils.MobAnimations).PlayAnimation(params.HitParams.MobId, "Float", duration)

    end

    wait(EFFECT_DURATION - 0.1)

    local floatTween_B = TweenService:Create(HRP, TweenInfo.new(.1), {CFrame = HRP.CFrame:ToWorldSpace(CFrame.new(0,-10,0))})
    floatTween_B.Completed:Connect(function()

        HRP.Anchored = false

        local newLookVector = (HRP.Position - params.SlamOriginCFrame.Position).unit

        abilityDefs = {}
        abilityDefs.HitEffects = {
            Damage = {Damage = 40},
            KnockBack = {Force = 40, ForceY = 30, LookVector = newLookVector}
        }

        Knit.Services.PowersService:RegisterHit(params.InitPlayer, params.HitCharacter, abilityDefs)

    end)
    floatTween_B:Play()

    Knit.Services.PowersService:RenderAbilityEffect_AllPlayers(script, "Client_SlamBlast", params)

end

function module.Client_SlamBlast(params)

    print("SLAMBLAST PARAMS", params)

    local newBurst = ReplicatedStorage.EffectParts.Abilities.BasicAbility.GravitySlam.Burst:Clone()
    newBurst.CFrame =  params.HitCharacterOrigin
    newBurst.Parent = Workspace.RenderedEffects
    newBurst.Pop:Emit(50)
    Debris:AddItem(newBurst, 10)

end

function module.Client_GravityEffect(params)

    if not params.HitCharacter then return end
    local HRP = params.HitCharacter:FindFirstChild("HumanoidRootPart")
    if not HRP then return end

    if Players.LocalPlayer.Character then 
        if params.HitCharacter == Players.LocalPlayer.Character then

            spawn(function()
                Knit.Controllers.PlayerUtilityController.PlayerAnimations.Float:Play()
                wait(EFFECT_DURATION)
                Knit.Controllers.PlayerUtilityController.PlayerAnimations.Float:Stop()
            end)
    
        end
    end

    local endTime = os.clock() + EFFECT_DURATION
    while os.clock() < endTime do

        local ball = ReplicatedStorage.EffectParts.Abilities.BasicAbility.GravityShift.Ball:Clone()
        ball.CFrame = HRP.CFrame
        ball.Parent = Workspace.RenderedEffects

        local moveTween = TweenService:Create(ball,TweenInfo.new(1), {Position = ball.Position + Vector3.new(0,5,0), Transparency = 1, Size = Vector3.new(1,1,1)})
        moveTween.Completed:Connect(function()
            ball:Destroy()
        end)
        moveTween:Play()

        wait(.25)
    end





end

function module.Client_Initialize(params, abilityDefs)

    local character = Players.LocalPlayer.Character
    if not character and character.HumanoidRootPart then return end

    spawn(function()

        Knit.Controllers.PlayerUtilityController.PlayerAnimations.Point:Play()
        wait(module.MobilityLockParams.Duration)
        Knit.Controllers.PlayerUtilityController.PlayerAnimations.Point:Stop()

    end)

    params.GravitySlamCFrame = character.HumanoidRootPart.CFrame:ToWorldSpace(SLAM_OFFSET)
end


--// Client_Stage_1
function module.Client_Stage_1(params, abilityDefs)

    local targetStand = Workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
    if not targetStand then
        targetStand = ManageStand.QuickRender(params)
    end

    ManageStand.Aura_On(params)
    ManageStand.MoveStand(params, "IdleHigh")
    ManageStand.PlayAnimation(params, "HandSwipe")

    wait(HIT_DELAY)

    WeldedSound.NewSound(targetStand.HumanoidRootPart, ReplicatedStorage.Audio.General.GenericWhoosh_Fast)

    -- black hole animations
    local swipeBall = ReplicatedStorage.EffectParts.Abilities.BasicAbility.GravitySlam.SwipeBall:Clone()
    swipeBall.CFrame = targetStand.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(3, 3, 1))
    swipeBall.Parent = Workspace.RenderedEffects
    Debris:AddItem(swipeBall, 1)

    local swipeTween = TweenService:Create(swipeBall,TweenInfo.new(.1), {CFrame = params.GravitySlamCFrame})
    swipeTween:Play()
    swipeTween:Destroy()

    wait(.1)

    local newBurst = ReplicatedStorage.EffectParts.Abilities.BasicAbility.GravitySlam.Burst:Clone()
    newBurst.CFrame = params.GravitySlamCFrame
    newBurst.Parent = Workspace.RenderedEffects
    newBurst.Pop:Emit(50)

    local newParticles = ReplicatedStorage.EffectParts.Abilities.BasicAbility.GravitySlam.Particles:Clone()
    newParticles.CFrame = params.GravitySlamCFrame
    newParticles.Parent = Workspace.RenderedEffects

    newParticles.ParticleEmitter_A:Emit(60)
    newParticles.ParticleEmitter_B:Emit(60)

    AnchoredSound.NewSound(params.GravitySlamCFrame.Position, ReplicatedStorage.Audio.General.MagicBoom)
    local droneSound = AnchoredSound.NewSound(params.GravitySlamCFrame.Position, ReplicatedStorage.Audio.General.EnergySource20sec)

    CamShakeTools.Client_PresetRadiusShake(params.GravitySlamCFrame.Position, RANGE, "SmallExplosion")

    spawn(function()

        wait(EFFECT_DURATION)
        droneSound:Destroy()
        AnchoredSound.NewSound(params.GravitySlamCFrame.Position, ReplicatedStorage.Audio.General.PowerUpStinger3)
        newBurst:Destroy()
        newParticles.ParticleEmitter_A.Enabled = false
        newParticles.ParticleEmitter_B.Enabled = false
        wait(10)
        newParticles:Destroy()

    end)

    ManageStand.MoveStand(params, "Idle")
    ManageStand.Aura_Off(params)

 
end

--// Client_Stage_2
function module.Client_Stage_2(params, abilityDefs)

    wait(HIT_DELAY)

    local endTime = os.clock() + EFFECT_DURATION
    while os.clock() < endTime do

        local shockRing = ReplicatedStorage.EffectParts.Abilities.BasicAbility.GravitySlam.RingAssembly:Clone()
        shockRing.Ring_Mesh.Size = Vector3.new(RANGE * 2, 0.6, RANGE * 2)
        shockRing.Parent = Workspace.RenderedEffects
        shockRing.CFrame = params.GravitySlamCFrame

        local destination = shockRing.CFrame:ToWorldSpace(CFrame.new(0, 10, 0))

        local moveTween = TweenService:Create(shockRing,TweenInfo.new(1),{CFrame = destination})
        moveTween.Completed:Connect(function()
            shockRing:Destroy()
        end)
        
        local transTween = TweenService:Create(shockRing.Ring_Mesh,TweenInfo.new(1),{Transparency = 1})

        moveTween:Play()
        transTween:Play()

        wait(.25)

    end


end


return module