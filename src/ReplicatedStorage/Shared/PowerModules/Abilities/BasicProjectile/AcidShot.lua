-- AcidShot Mod

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local ManageStand = require(Knit.Abilities.ManageStand)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)

local AcidShotMod = {}

-- projectile origin
AcidShotMod.CFrameOffest = CFrame.new(0, 0, -2) -- offset from the initPlayers HRP

-- hitbox data points
AcidShotMod.HitBox_Size_X = 3
AcidShotMod.HitBox_Size_Y = 2
AcidShotMod.HitBox_Resolution_X = 1
AcidShotMod.HitBox_Resolution_Y = 1 -- having this larger than the Y size will make it a flat plane

-- ray data
AcidShotMod.Velocity = 300
AcidShotMod.Lifetime = 3
AcidShotMod.Iterations = 500
AcidShotMod.BreakOnHit = true
--AcidShotMod.BreakifHuman = true
--AcidShotMod.BreakOnBlockAbility = true

-- ignore list
AcidShotMod.CustomIgnoreList = {}

-- animation stuff
AcidShotMod.PlayerAnchorTime = .5

-- pin/camera duration
AcidShotMod.PinDuration = 5

-- cosmetic projectile
AcidShotMod.CosmeticProjectile = ReplicatedStorage.EffectParts.Abilities.BasicProjectile.AcidShot.Projectile

-- hit effects
AcidShotMod.HitEffects = {Damage = {Damage = 20}}

function AcidShotMod.FireEffects(initPlayer, projectile, params, abilityDefs)

    local targetStand = Workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
    if not targetStand then
        targetStand = ManageStand.QuickRender(params)
    end

    WeldedSound.NewSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.General.GenericWhoosh_Fast)

    spawn(function()
        ManageStand.MoveStand(params, "Front")
        ManageStand.PlayAnimation(params, "Point")
        ManageStand.Aura_On(params)
        wait(AcidShotMod.PlayerAnchorTime)
        ManageStand.MoveStand(params, "Idle")
        ManageStand.StopAnimation(params, "Point")
        ManageStand.Aura_Off(params)
    end)
end

function AcidShotMod.HitBoxResult(initPlayer, params, abilityDefs, result)

    -- destroy the cosmetic
    local abilityScript = script.Parent
    local resultParams = {}
    resultParams.Position = result.Position
    resultParams.ProjectileID = params.projectileID
    resultParams.AbilityMod = abilityDefs.AbilityMod
    Knit.Services.PowersService:RenderAbilityEffect_AllPlayers(script, "DestroyCosmetic", resultParams)

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
        abilityDefs.HitEffects.PinCharacter = {Duration = AcidShotMod.PinDuration}
        abilityDefs.HitEffects.CameraMove = {Duration = AcidShotMod.PinDuration, TargetPart = cameraAnchor}

        Knit.Services.PowersService:RegisterHit(initPlayer, character, abilityDefs)
        local newParticle = ReplicatedStorage.EffectParts.Abilities.BasicProjectile.AcidShot.WhiteBubbleParticle:Clone()
        Debris:AddItem(newParticle, AcidShotMod.PinDuration + 5)
        newParticle.Parent = character.HumanoidRootPart
        wait(AcidShotMod.PinDuration)
        newParticle.Enabled = false
    end
end

function AcidShotMod.SetupCosmetic(initPlayer, params, abilityDefs)

    local newProjectile = AcidShotMod.CosmeticProjectile:Clone()
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
        wait(AcidShotMod.Lifetime)
        newProjectile:Destroy()
    end)

    return newProjectile
end

-- destroy cosmetic
function AcidShotMod.DestroyCosmetic(params)

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

    local sizeTween = TweenService:Create(newBurst, TweenInfo.new(.5),{Size = Vector3.new(9,9,9)})
    local transparencyTween = TweenService:Create(newBurst, TweenInfo.new(.5),{Transparency = 1})

    sizeTween:Play()
    transparencyTween:Play()

    newBurst.Part.ParticleEmitter:Emit(200)

end

return AcidShotMod