-- AcidShot Mod

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

-- projectile origin
module.CFrameOffest = CFrame.new(0, 0, -2) -- offset from the initPlayers HRP

-- hitbox data points
module.HitBox_Size_X = 3
module.HitBox_Size_Y = 2
module.HitBox_Resolution_X = 1
module.HitBox_Resolution_Y = 1 -- having this larger than the Y size will make it a flat plane

-- ray data
module.Velocity = 300
module.Lifetime = 3
module.Iterations = 500
module.BreakOnHit = true

-- ignore list
module.CustomIgnoreList = {}


-- pin/camera duration
module.PinDuration = 5

-- cosmetic projectile
module.CosmeticProjectile = ReplicatedStorage.EffectParts.Abilities.BasicProjectile.AcidShot.Projectile

-- hit effects
module.HitEffects = {Damage = {Damage = 20}}

-----------------------------------------------------------------------------------------------------------------------
-- SERVER FUNCTIONS ---------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

--// HitBoxResult
function module.HitBoxResult(initPlayer, params, abilityDefs, result)

    --abilityDefs.HitEffects = module.HitEffects

    -- destroy the cosmetic
    local abilityScript = script.Parent
    local resultParams = {}
    resultParams.Position = result.Position
    resultParams.ProjectileID = params.projectileID
    resultParams.AbilityMod = abilityDefs.AbilityMod
    Knit.Services.PowersService:RenderAbilityEffect_AllPlayers(script, "Projectile_Impact", resultParams)

    local hitCharacters = {}
    -- hit all players in range, subject to immunity
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character and player ~= initPlayer then
            local magnitude = (result.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if magnitude <= 10 then
                table.insert(hitCharacters, player.Character)
            end
        end
    end

    -- hit all Mobs in range
    for _,mob in pairs(Knit.Services.MobService.SpawnedMobs) do
        local magnitude = (result.Position - mob.Model.HumanoidRootPart.Position).Magnitude
        if magnitude <= 10 then
            table.insert(hitCharacters, mob.Model)
        end
    end

    -- hit all dummies
    for _, dummy in pairs(Workspace.Dummies:GetChildren()) do
        local magnitude = (result.Position - dummy.HumanoidRootPart.Position).Magnitude
        if magnitude <= 10 then
            table.insert(hitCharacters, dummy)
        end
    end

    for _, character in pairs(hitCharacters) do

        local cameraAnchor = Workspace.GameMaps.SpecialMaps.WhiteRoom:FindFirstChild("CameraAnchor", true)

        abilityDefs.HitEffects = {}
        abilityDefs.HitEffects.Damage = {Damage = 10}
        abilityDefs.HitEffects.PinCharacter = {Duration = module.PinDuration}
        abilityDefs.HitEffects.CameraMove = {Duration = module.PinDuration, TargetPart = cameraAnchor}
        abilityDefs.HitEffects.RenderEffects = {
            {Script = script, Function = "HitParticles", Arguments = {HitCharacter = character}}
        }

        Knit.Services.PowersService:RegisterHit(initPlayer, character, abilityDefs)

    end
end

-----------------------------------------------------------------------------------------------------------------------
-- CLIENT FUNCTIONS ---------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

--// Client_Initialize
function module.Client_Initialize(params, abilityDefs, delayOffset)

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

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    if not initPlayer and initPlayer.Character then return end

    local targetStand = Workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
    if not targetStand then
        targetStand = ManageStand.QuickRender(params)
    end


    -- animate stand
    spawn(function()
    
        WeldedSound.NewSound(targetStand.HumanoidRootPart, ReplicatedStorage.Audio.General.GenericWhoosh_Fast)

        ManageStand.MoveStand(params, "Front")
        ManageStand.PlayAnimation(params, "Point")
        ManageStand.Aura_On(params)
        
        local delay = 0
        if playerPing then
            delay = module.MobilityLockParams.Duration + (playerPing / 2)
        else
            delay = module.MobilityLockParams.Duration
        end
        if delay > 0 then wait(delay) end

        ManageStand.MoveStand(params, "Idle")
        ManageStand.StopAnimation(params, "Point")
        ManageStand.Aura_Off(params)

    end)

    -- animate ball
    spawn(function()
        
        wait(.1)

        local newBall = ReplicatedStorage.EffectParts.Abilities.BasicProjectile.AcidShot.Ball:Clone()
        newBall.Parent = Workspace.RenderedEffects
        newBall.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0, 0, -7.5))
        Debris:AddItem(newBall, 4)

        WeldedSound.NewSound(targetStand.HumanoidRootPart, ReplicatedStorage.Audio.General.PowerUpStinger3)
        newBall.ParticleEmitter:Emit(50)

        local tween = TweenService:Create(newBall,TweenInfo.new(1), {Transparency = 1, Size = Vector3.new(3,3,3)})
        tween:Play()
        tween:Destroy()
        newBall.ParticleEmitter.Enabled = false

    end)
    
end

--// Projectile_FireEffects
function module.Projectile_FireEffects(initPlayer, projectile, params, abilityDefs)
    WeldedSound.NewSound(projectile, ReplicatedStorage.Audio.General.MagicWandCast7)
end

--// Projectile_Setup
function module.Projectile_Setup(initPlayer, params, abilityDefs)

    local newProjectile = module.CosmeticProjectile:Clone()
    newProjectile.CFrame = params.projectileOrigin
    for _, v in pairs(newProjectile:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CFrame = params.projectileOrigin
            local newWeld = Instance.new("Weld")
            newWeld.C1 =  CFrame.new(0,0,0)
            newWeld.Part0 = newProjectile
            newWeld.Part1 = v
            newWeld.Parent = v
        end
    end

    spawn(function()
        wait(module.Lifetime)
        newProjectile:Destroy()
    end)

    return newProjectile
end

--// Projectile_Impact
function module.Projectile_Impact(params)

    local projectilePart = Workspace.RenderedEffects:FindFirstChild(params.ProjectileID)

    if projectilePart then
        projectilePart.Anchored = true
        Debris:AddItem(projectilePart, 10)
        projectilePart.Transparency = 1
        for i,v in pairs(projectilePart:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Transparency = 1
            end
            if v:IsA("ParticleEmitter") then
                v.Enabled = false
            end
        end
    end

    local newBurst = ReplicatedStorage.EffectParts.Abilities.BasicProjectile.AcidShot.Burst:Clone()
    newBurst.Position = params.Position
    newBurst.Parent = Workspace.RenderedEffects
    Debris:AddItem(newBurst, 10)

    WeldedSound.NewSound(newBurst, ReplicatedStorage.Audio.General.GlassBoom)

    local sizeTween = TweenService:Create(newBurst, TweenInfo.new(.5),{Size = Vector3.new(9,9,9)})
    local transparencyTween = TweenService:Create(newBurst, TweenInfo.new(.5),{Transparency = 1})

    sizeTween:Play()
    transparencyTween:Play()

    newBurst.Part.ParticleEmitter:Emit(200)

end

-- end cosmetic
function module.Projectile_Destroy(projectile)
    projectile:Destroy()
end

function module.HitParticles(params)

    if not params.HitCharacter then return end
    if not params.HitCharacter.HumanoidRootPart then return end

    local newParticle = ReplicatedStorage.EffectParts.Abilities.BasicProjectile.AcidShot.WhiteBubbleParticle:Clone()
    Debris:AddItem(newParticle, module.PinDuration + 5)
    newParticle.Parent = params.HitCharacter.HumanoidRootPart
    wait(module.PinDuration)
    newParticle.Enabled = false

end

return module