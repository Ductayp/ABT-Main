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
ScrapePunch.HitboxSize = Vector3.new(8, 6, 40)
ScrapePunch.HitboxOffset = CFrame.new(0, 0, 20)
ScrapePunch.HitboxDestroyTime = 2

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

        local offset = CFrame.new(0, 0, 15)
        hitCharacter.HumanoidRootPart.Position = params.TargetPosition

        --wait()

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
        --local moveTime = ManageStand.MoveStand(params, "Front")
        ManageStand.PlayAnimation(params, "HandSwipe")
        ManageStand.Aura_On(params)
        wait(.4)
        --ManageStand.MoveStand(params, "Idle")
        wait(.5)
        ManageStand.Aura_Off(params)
    end)

    wait(ScrapePunch.HitDelay)


end

function ScrapePunch.RenderPull(params)

    WeldedSound.NewSound(params.Hitbox, punchSound)

    spawn(function()
        local rodParts = {}
        rodParts.greenRods = ReplicatedStorage.EffectParts.Abilities.MeleeAttack.VoidPull.Green:Clone()
        rodParts.blueRods = ReplicatedStorage.EffectParts.Abilities.MeleeAttack.VoidPull.Blue:Clone()
        rodParts.whiteRods = ReplicatedStorage.EffectParts.Abilities.MeleeAttack.VoidPull.White:Clone()
    
        for _, mainPart in pairs(rodParts) do
            mainPart.CFrame = params.HitboxCFrame
            mainPart.Parent = Workspace.RenderedEffects
            Debris:AddItem(mainPart, 3)
    
            for _, subPart in pairs(mainPart:GetChildren()) do
                if subPart:IsA("BasePart") then
                    local tween = TweenService:Create(subPart, TweenInfo.new(1), {Transparency = 1, Size = Vector3.new(.7,.7,.7)})
                    tween:Play()
                    tween:Destroy()
                end
            end
        end
    end)

    local burstParts = {}
    burstParts.burstBlue = ReplicatedStorage.EffectParts.Abilities.MeleeAttack.VoidPull.Burst_Blue:Clone()
    --burstParts.burstWhite = ReplicatedStorage.EffectParts.Abilities.MeleeAttack.VoidPull.Burst_White:Clone()
    --burstParts.ballGreen = ReplicatedStorage.EffectParts.Abilities.MeleeAttack.VoidPull.Ball_Green:Clone()
    burstParts.ballBlack = ReplicatedStorage.EffectParts.Abilities.MeleeAttack.VoidPull.Ball_Black:Clone()

    for _, v in pairs(burstParts) do
        v.Position = params.TargetPosition
        v.Parent = Workspace.RenderedEffects
        --Debris:AddItem(v, 10)

    end

    burstParts.ballBlack.Particle:Emit(20)

    local burstTween1 = TweenService:Create(burstParts.burstBlue, TweenInfo.new(.5), {Transparency = 1, Size = burstParts.burstBlue.Size + Vector3.new(3,3,3)})
    --local burstTween2 = TweenService:Create(burstParts.burstWhite, TweenInfo.new(1), {Transparency = 1, Size = burstParts.burstWhite.Size + Vector3.new(6,6,6)})

    --local ballTween1 = TweenService:Create(burstParts.ballGreen, TweenInfo.new(.5), {Transparency = 1, Size = burstParts.ballGreen.Size + Vector3.new(3,3,3)})
    local ballTween2 = TweenService:Create(burstParts.ballBlack, TweenInfo.new(1), {Transparency = 1, Size = Vector3.new(1,1,1)})

    burstTween1:Play()
    --burstTween2:Play()
    --ballTween1:Play()
    ballTween2:Play()

    burstTween1:Destroy()
    --burstTween2:Destroy()
    --ballTween1:Destroy()
    ballTween2:Destroy()

    wait(3)
    burstParts.ballBlack.Particle.Enabled = false
    wait(7)
    burstParts.ballBlack:Destroy()


    
    


end




return ScrapePunch