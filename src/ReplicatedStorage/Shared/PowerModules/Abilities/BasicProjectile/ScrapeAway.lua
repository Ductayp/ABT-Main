-- Knife Throw Mod

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local ManageStand = require(Knit.Abilities.ManageStand)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)
local utils = require(Knit.Shared.Utils)

local module = {}

module.InputBlockTime = 1

module.MobilityLockParams = {}
module.MobilityLockParams.Duration = 1
module.MobilityLockParams.ShiftLock_NoSpin = true
module.MobilityLockParams.AnchorCharacter = true

-- projectile offset
module.CFrameOffest = CFrame.new(0, 0, -2) -- offset from the initPlayers HRP

module.InitialDelay = .3

-- hitbox data points
module.HitBox_Size_X = 4
module.HitBox_Size_Y = 4
module.HitBox_Resolution_X = 1
module.HitBox_Resolution_Y = 2 -- having this larger than the Y size will make it a flat plane

-- ray data
module.Velocity = 70
module.Lifetime = .5
module.Iterations = 500
module.BreakOnHit = false
module.BreakifHuman = false
module.BreakOnBlockAbility = false

-- ignore list
module.CustomIgnoreList = {}

-- hit effects
module.HitEffects = {Damage = {Damage = 40}}

function module.CharacterAnimations(params, abilityDefs, delayOffset)

    spawn(function()

        local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
        if not initPlayer and initPlayer.Character then return end

        if initPlayer == Players.LocalPlayer then
            spawn(function()

                Knit.Controllers.PlayerUtilityController.PlayerAnimations.Point:Play()
                wait(module.MobilityLockParams.Duration)
                Knit.Controllers.PlayerUtilityController.PlayerAnimations.Point:Stop()

            end)
        end

        local targetStand = Workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
        if not targetStand then
            targetStand = ManageStand.QuickRender(params)
        end

        ManageStand.Aura_On(params)
        ManageStand.PlayAnimation(params, "HandSwipe")
        ManageStand.MoveStand(params, "Front")

        local delay = module.MobilityLockParams.Duration + delayOffset
        if delay > 0 then wait(delay) end

        ManageStand.MoveStand(params, "Idle")
        ManageStand.Aura_Off(params)
    end)

end

function module.SetupCosmetic(initPlayer, params, abilityDefs)
    local projectile = ReplicatedStorage.EffectParts.Abilities.BasicProjectile.ScrapeAway.Scrape:Clone()
    return projectile
end

function module.FireEffects(initPlayer, projectile, params, abilityDefs)

    WeldedSound.NewSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.General.MagicDoubleWoosh)
end

function module.HitBoxResult(initPlayer, params, abilityDefs, result)

    abilityDefs.HitEffects = module.HitEffects

    if result.Instance.Parent:FindFirstChild("Humanoid") then
        Knit.Services.PowersService:RegisterHit(initPlayer, result.Instance.Parent, abilityDefs)
    end
end

-- destroy cosmetic
function module.DestroyCosmetic(params)

    local projectilePart = Workspace.RenderedEffects:FindFirstChild(params.ProjectileID)

    local newBurst = ReplicatedStorage.EffectParts.Abilities.BasicProjectile.KnifeThrow.Burst:Clone()
    newBurst.Position = params.Position
    newBurst.Parent = Workspace.RenderedEffects
    Debris:AddItem(newBurst, 5)

    local sizeTween = TweenService:Create(newBurst, TweenInfo.new(.5),{Size = Vector3.new(5,5,5)})
    local transparencyTween = TweenService:Create(newBurst, TweenInfo.new(.5),{Transparency = 1})

    sizeTween:Play()
    transparencyTween:Play()

    newBurst.Part.ParticleEmitter:Emit(100)
    if projectilePart then
        projectilePart:Destroy()
    end
    
end

-- end cosmetic
function module.EndCosmetic(projectile)

    projectile.Anchored = true
    for _, v in pairs(projectile:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") then
            v.Enabled = false
            v.Speed = NumberRange.new(2,2)
            v:Emit(50)
        end
    end

    wait(3)

    projectile:Destroy()

end

return module