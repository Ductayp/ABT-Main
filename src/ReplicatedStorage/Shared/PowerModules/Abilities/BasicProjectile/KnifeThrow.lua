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

module.InputBlockTime = .5

module.MobilityLockParams = {}
module.MobilityLockParams.Duration = .5
module.MobilityLockParams.ShiftLock_NoSpin = true
module.MobilityLockParams.AnchorCharacter = true

module.InitialDelay = 0

-- projectile origin
module.CFrameOffest = CFrame.new(0, 0, -2) -- offset from the initPlayers HRP

-- hitbox data points
module.HitBox_Size_X = 4.5
module.HitBox_Size_Y = 1
module.HitBox_Resolution_X = 1
module.HitBox_Resolution_Y = 2 -- having this larger than the Y size will make it a flat plane

-- ray data
module.Velocity = 250
module.Lifetime = .5
module.Iterations = 500
module.BreakOnHit = true

-- ignore list
module.CustomIgnoreList = {}

-- hit effects
module.HitEffects = {Damage = {Damage = 15}}

-----------------------------------------------------------------------------------------------------------------------
-- SERVER FUNCTIONS ---------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

--// HitBoxResult
function module.HitBoxResult(initPlayer, params, abilityDefs, result)

    local abilityScript = script.Parent
    local resultParams = {}
    resultParams.Position = result.Position
    resultParams.ProjectileID = params.projectileID
    resultParams.AbilityMod = abilityDefs.AbilityMod
    Knit.Services.PowersService:RenderAbilityEffect_AllPlayers(script, "Projectile_Impact", resultParams)

    abilityDefs.HitEffects = module.HitEffects

    if result.Instance.Parent:FindFirstChild("Humanoid") then
        --print("HIT A HUMANOID", result.Instance.Parent)
        Knit.Services.PowersService:RegisterHit(initPlayer, result.Instance.Parent, abilityDefs)
    end
end

-----------------------------------------------------------------------------------------------------------------------
-- CLIENT FUNCTIONS ---------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

--// Client_Initialize
function module.Client_Initialize(params, abilityDefs, playerPing)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    if not initPlayer and initPlayer.Character then return end

    spawn(function()

        Knit.Controllers.PlayerUtilityController.PlayerAnimations.Point:Play()
        wait(module.MobilityLockParams.Duration)
        Knit.Controllers.PlayerUtilityController.PlayerAnimations.Point:Stop()

    end)

end

--// Client_Stage_1
function module.Client_Stage_1(params, abilityDefs, playerPing)

    spawn(function()

        local targetStand = Workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
        if not targetStand then
            targetStand = ManageStand.QuickRender(params)
        end
    
        WeldedSound.NewSound(targetStand.HumanoidRootPart, ReplicatedStorage.Audio.General.GenericWhoosh_Fast)

        ManageStand.MoveStand(params, "Front")
        ManageStand.PlayAnimation(params, "KnifeThrow")
        ManageStand.Aura_On(params)

        local delay = 0
        if playerPing then
            delay = module.MobilityLockParams.Duration + (playerPing / 2)
        else
            delay = module.MobilityLockParams.Duration
        end
        if delay > 0 then wait(delay) end

        ManageStand.MoveStand(params, "Idle")
        ManageStand.StopAnimation(params, "KnifeThrow")
        ManageStand.Aura_Off(params)
    end)

end

--// Projectile_Setup
function module.Projectile_Setup(initPlayer, params, abilityDefs)
    local projectile = ReplicatedStorage.EffectParts.Abilities.BasicProjectile.KnifeThrow.KnifeAssembly:Clone()
    spawn(function()
        wait(module.Lifetime)
        projectile:Destroy()
    end)
    return projectile
end

--// Projectile_FireEffects
function module.Projectile_FireEffects(initPlayer, projectile, params, abilityDefs)
    WeldedSound.NewSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.General.MagicWandCast6)
end


--// Projectile_Destroy
function module.Projectile_Impact(params)

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
function module.Projectile_Destroy(projectile)

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