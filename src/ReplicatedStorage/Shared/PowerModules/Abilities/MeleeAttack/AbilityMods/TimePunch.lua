-- TimePunch

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)
local ManageStand = require(Knit.Abilities.ManageStand)

local TimePunch = {}

-- timing
TimePunch.HitDelay = 0.4
TimePunch.InputBlockTime = 1
TimePunch.TickCount = 0 -- if 0 then there wont be any ticks, just a  regular attack

-- hitbox
TimePunch.HitboxSize = Vector3.new(5, 5, 12)
TimePunch.HitboxOffset = CFrame.new(0, 0, 6)
TimePunch.HitboxDestroyTime = .6

local punchSound = ReplicatedStorage.Audio.Abilities.HeavyPunch

--// HitCharacter
function TimePunch.HitCharacter(params, abilityDefs, initPlayer, hitCharacter)

    abilityDefs.HitEffects = {Damage = {Damage = 10}, PinCharacter = {Duration = 3}, SphereFields = {Size = 7, Duration = 3,RandomColor = true, Repeat = 1}}
    Knit.Services.PowersService:RegisterHit(initPlayer, hitCharacter, abilityDefs)

    return params
end

--// Client_Start
function TimePunch.Client_Start(params, abilityDefs, initPlayer)

    local initCharacter = initPlayer.Character
    if not initCharacter then return end

    local targetStand = Workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
    if not targetStand then
        targetStand = ManageStand.QuickRender(params)
    end

    --move the stand and do animations
    spawn(function()
        local moveTime = ManageStand.MoveStand(params, "Front")
        ManageStand.PlayAnimation(params, "HeavyPunch")
        ManageStand.Aura_On(params)
        wait(1.5)
        ManageStand.MoveStand(params, "Idle")
        wait(.5)
        ManageStand.Aura_Off(params)
    end)

    wait(TimePunch.HitDelay)

    WeldedSound.NewSound(targetStand.HumanoidRootPart, punchSound)

    local fastBall = ReplicatedStorage.EffectParts.Abilities.MeleeAttack.BasicHeavyPunch.FastBall:Clone()
    local shockRing = ReplicatedStorage.EffectParts.Abilities.MeleeAttack.BasicHeavyPunch.Shock:Clone()
    Debris:AddItem(fastBall, 3)
    Debris:AddItem(shockRing, 3)

    fastBall.CFrame = initCharacter.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-8))
    fastBall.Parent = Workspace.RenderedEffects

    shockRing.CFrame = initCharacter.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-8))
    shockRing.Parent = Workspace.RenderedEffects

    local ballTransparency = TweenService:Create(fastBall.Fireball, TweenInfo.new(.5), {Transparency = 1})
    local ballPosition = TweenService:Create(fastBall, TweenInfo.new(.5), {CFrame = fastBall.CFrame:ToWorldSpace(CFrame.new( 0, 0, -5))})

    local shockTransparency = TweenService:Create(shockRing.Shock, TweenInfo.new(1), {Transparency = 1})
    local shockPosition = TweenService:Create(shockRing.Shock, TweenInfo.new(1), {Size = Vector3.new(5, 1.5, 5)})

    ballTransparency:Play()
    ballPosition:Play()
    shockTransparency:Play()
    shockPosition:Play()

end






return TimePunch