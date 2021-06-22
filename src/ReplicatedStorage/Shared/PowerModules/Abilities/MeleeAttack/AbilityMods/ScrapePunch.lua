-- ScrapePunch

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)
local ManageStand = require(Knit.Abilities.ManageStand)
local AnchoredSound = require(Knit.PowerUtils.AnchoredSound)

local ScrapePunch = {}

-- timing
ScrapePunch.HitDelay = 0.4
ScrapePunch.InputBlockTime = 1
ScrapePunch.TickCount = 0 -- if 0 then there wont be any ticks, just a  regular attack

-- hitbox
ScrapePunch.HitboxSize = Vector3.new(5, 5, 12)
ScrapePunch.HitboxOffset = CFrame.new(0, 0, 6)
ScrapePunch.HitboxDestroyTime = .3

local punchSound = ReplicatedStorage.Audio.Abilities.HeavyPunch

--// HitCharacter
function ScrapePunch.HitCharacter(params, abilityDefs, initPlayer, hitCharacter)

    
    abilityDefs.HitEffects = {
        Damage = {Damage = 20},
        PinCharacter = {Duration = 5.2},
        Invulnerable = {Duration = 5},
        RemoveStand = {},
        HideCharacter = {Duration = 5},
        RunFunction = {
            RunOn = "Client",
            Script = script,
            FunctionName = "BlackHole",
            FunctionParams = {
                Position = hitCharacter.HumanoidRootPart.Position,
                HitCharacter = hitCharacter}
            }
    }
    Knit.Services.PowersService:RegisterHit(initPlayer, hitCharacter, abilityDefs)

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
        ManageStand.PlayAnimation(params, "HeavyPunch")
        ManageStand.Aura_On(params)
        wait(1.5)
        ManageStand.MoveStand(params, "Idle")
        wait(.5)
        ManageStand.Aura_Off(params)
    end)

    wait(ScrapePunch.HitDelay)

    WeldedSound.NewSound(targetStand.HumanoidRootPart, punchSound)

    local scrapeAssembly = ReplicatedStorage.EffectParts.Abilities.MeleeAttack.ScrapePunch.Scrape:Clone()
    local shockRing = ReplicatedStorage.EffectParts.Abilities.MeleeAttack.BasicHeavyPunch.Shock:Clone()
    Debris:AddItem(scrapeAssembly, 3)
    Debris:AddItem(shockRing, 3)

    scrapeAssembly.CFrame = initCharacter.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-8))
    scrapeAssembly.Parent = Workspace.RenderedEffects

    shockRing.CFrame = initCharacter.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-8))
    shockRing.Parent = Workspace.RenderedEffects

    local scrapePosition = TweenService:Create(scrapeAssembly, TweenInfo.new(.5), {CFrame = scrapeAssembly.CFrame:ToWorldSpace(CFrame.new( 0, 0, -5))})
    local scrapeTrans_1 = TweenService:Create(scrapeAssembly.Main, TweenInfo.new(.5), {Transparency = 1})
    local scrapeTrans_2 = TweenService:Create(scrapeAssembly.Left, TweenInfo.new(.5), {Transparency = 1})
    local scrapeTrans_3 = TweenService:Create(scrapeAssembly.Right, TweenInfo.new(.5), {Transparency = 1})

    local shockTransparency = TweenService:Create(shockRing.Shock, TweenInfo.new(1), {Transparency = 1})
    local shockPosition = TweenService:Create(shockRing.Shock, TweenInfo.new(1), {Size = Vector3.new(5, 1.5, 5)})

    scrapeTrans_1:Play()
    scrapeTrans_2:Play()
    scrapeTrans_3:Play()
    scrapePosition:Play()
    shockTransparency:Play()
    shockPosition:Play()

end

function ScrapePunch.BlackHole(params)

    --AnchoredSound.NewSound(params.TargetPosition, ReplicatedStorage.Audio.General.MagicBoom)
    local droneSound = AnchoredSound.NewSound(params.Position, ReplicatedStorage.Audio.General.EnergySource20sec)
    AnchoredSound.NewSound(params.Position, ReplicatedStorage.Audio.General.PowerUpStinger3)

    -- setup black hole parts
    local blackHoleParts = {
        newBlackBall = ReplicatedStorage.EffectParts.Abilities.MeleeAttack.ScrapePunch.BlackBall:Clone(),
        newWhisps = ReplicatedStorage.EffectParts.Abilities.MeleeAttack.ScrapePunch.Whisps:Clone(),
        newParticle = ReplicatedStorage.EffectParts.Abilities.MeleeAttack.ScrapePunch.Particle:Clone(),
    }
    blackHoleParts.newWhisps.BodyPosition.Position = params.Position

    -- render black hole parts
    for i,v in pairs (blackHoleParts) do
        v.CFrame = CFrame.new(params.Position)
        v.Parent = Workspace.RenderedEffects
    end

    local newBurst = ReplicatedStorage.EffectParts.Abilities.MeleeAttack.ScrapePunch.Burst:Clone()
    newBurst.CFrame = CFrame.new(params.Position)
    newBurst.Parent = Workspace.RenderedEffects
    newBurst.Pop:Emit(50)

    wait(5)

    droneSound:Destroy()
    AnchoredSound.NewSound(params.Position, ReplicatedStorage.Audio.General.MagicBoom, soundParams)

    newBurst.Pop:Emit(50)
    newBurst.Purple.Enabled = false
    Debris:AddItem(newBurst, 5)

    blackHoleParts.newBlackBall:Destroy()
    blackHoleParts.newWhisps:Destroy()
    blackHoleParts.newParticle.ParticleEmitter.Enabled = false
    Debris:AddItem(blackHoleParts.newParticle, 3)

end

return ScrapePunch