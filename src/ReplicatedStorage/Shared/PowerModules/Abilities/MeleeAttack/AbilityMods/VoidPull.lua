-- ScrapePunch

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")


local PhysicsService
if RunService:IsServer() then
    PhysicsService = game:GetService("PhysicsService")
    PhysicsService:CreateCollisionGroup("nocol")
    PhysicsService:CollisionGroupSetCollidable("nocol","nocol",false)
end


local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)
local ManageStand = require(Knit.Abilities.ManageStand)

local ScrapePunch = {}

-- timing
ScrapePunch.HitDelay = 0.4
ScrapePunch.InputBlockTime = 0.5

-- hitbox
ScrapePunch.HitboxSize = Vector3.new(6, 5, 50)
ScrapePunch.HitboxOffset = CFrame.new(0, 0, 25)
ScrapePunch.HitboxDestroyTime = .4

local punchSound = ReplicatedStorage.Audio.Abilities.HeavyPunch

-- variables
local damage = 1
local pinTime = 1

function ScrapePunch.Hitbox_Start(params, abilityDefs, initPlayer, hitbox)

    local targetPosition = hitbox.CFrame:ToWorldSpace(CFrame.new(0,0, 15)).Position

    local effectParams = {}
    effectParams.Hitbox = hitbox
    effectParams.HitboxCFrame = hitbox.CFrame
    effectParams.TargetPosition = targetPosition
    Knit.Services.PowersService:RenderAbilityEffect_AllPlayers(script, "RenderPull", effectParams)

    params.TargetPosition = targetPosition
end

--// HitCharacter
function ScrapePunch.HitCharacter(params, abilityDefs, initPlayer, hitCharacter, hitbox)

    spawn(function()

        abilityDefs.HitEffects = {Teleport = {TargetPosition = params.TargetPosition}}
        Knit.Services.PowersService:RegisterHit(initPlayer, hitCharacter, abilityDefs)

        abilityDefs.HitEffects = {Damage = {Damage = damage}, PinCharacter = {Duration = pinTime}}
        Knit.Services.PowersService:RegisterHit(initPlayer, hitCharacter, abilityDefs)

    end)

    return params
end

--// Client_Start
function ScrapePunch.Client_Start(params, abilityDefs, initPlayer)

    local initCharacter = initPlayer.Character
    if not initCharacter then return end

    local targetStand = Workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
    if not targetStand then
        targetStand = ManageStand.QuickRender(params)
    end

    --move the stand and do animations
    spawn(function()
        local moveTime = ManageStand.MoveStand(params, "Front")
        ManageStand.PlayAnimation(params, "HandSwipe")
        ManageStand.Aura_On(params)
        wait(.4)
        ManageStand.MoveStand(params, "Idle")
        wait(.5)
        ManageStand.Aura_Off(params)
    end)

end

function ScrapePunch.RenderPull(params)

    WeldedSound.NewSound(params.Hitbox, punchSound)

    local hitBoxSize_X = params.Hitbox.Size.X
    local hitBoxSize_Y = params.Hitbox.Size.Y
    local hitBoxSize_Z = params.Hitbox.Size.Z

    local colors = {
        [1] = Color3.fromRGB(0, 85, 255),
        [2] = Color3.fromRGB(255, 255, 255),
        [3] = Color3.fromRGB(0, 255, 127),
    }

    local rodCount = 20
    local rodThickness = 0.3
    local rodOffset = 5
    local rodLength = hitBoxSize_Z - rodOffset



    for count = 1, rodCount do

        local rand_X = math.random(  (-hitBoxSize_X * 100), (hitBoxSize_X * 100) ) / 100
        local rand_Y = math.random( (-hitBoxSize_Y * 100), (hitBoxSize_Y * 100) ) / 100
        local randColor = math.random(1,3)


        local newRod = Instance.new("Part")
        newRod.Anchored = true
        newRod.CanCollide = false
        newRod.CanTouch = false
        newRod.Transparency = .5
        newRod.Color = colors[randColor]
        newRod.Size = Vector3.new(rodThickness, rodThickness, rodLength)
        newRod.CFrame = params.Hitbox.CFrame:ToWorldSpace(CFrame.new(rand_X, rand_Y, -rodOffset))
        newRod.Parent = Workspace.RenderedEffects
        Debris:AddItem(newRod, 3)

        local tweenInfo = TweenInfo.new(.5)
        local tweenParams = {
            Transparency = 1,
            Size = Vector3.new(rodThickness, rodThickness, rodLength / 10),
            CFrame = params.Hitbox.CFrame:ToWorldSpace(CFrame.new(rand_X, rand_Y, rodLength / 3 ))
        }

        local tween = TweenService:Create(newRod, tweenInfo, tweenParams)
        tween:Play()
        tween:Destroy()

    end

    local burstParts = {}
    burstParts.burstBlue = ReplicatedStorage.EffectParts.Abilities.MeleeAttack.VoidPull.Burst_Blue:Clone()
    burstParts.ballBlack = ReplicatedStorage.EffectParts.Abilities.MeleeAttack.VoidPull.Ball_Black:Clone()

    for _, v in pairs(burstParts) do
        v.Position = params.TargetPosition
        v.Parent = Workspace.RenderedEffects
    end

    burstParts.ballBlack.Particle:Emit(20)

    local burstTween1 = TweenService:Create(burstParts.burstBlue, TweenInfo.new(.5), {Transparency = 1, Size = burstParts.burstBlue.Size + Vector3.new(3,3,3)})
    local ballTween2 = TweenService:Create(burstParts.ballBlack, TweenInfo.new(1), {Transparency = 1, Size = Vector3.new(1,1,1)})

    burstTween1:Play()
    ballTween2:Play()

    burstTween1:Destroy()
    ballTween2:Destroy()

    wait(3)
    burstParts.ballBlack.Particle.Enabled = false
    wait(7)
    burstParts.ballBlack:Destroy()


 

end




return ScrapePunch