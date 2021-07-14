-- FlowerPotBarrage

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)
local ManageStand = require(Knit.Abilities.ManageStand)

local module = {}

-- MobilityLock params
module.MobilityLockParams = {}
module.MobilityLockParams.Duration = 1
module.MobilityLockParams.ShiftLock_NoSpin = true
module.MobilityLockParams.AnchorCharacter = true

-- shot pattern params
module.InitialDelay = 0
module.ShotDelay = 0.25
module.ShotCount = 4
module.Offset_X = 1.5
module.Offset_Y = 1
module.Offset_Z = -8

-- ray box params
module.Size_X = 1
module.Size_Y = 1
module.Velocity = 90
module.Lifetime = .8
module.Iterations = 700

module.BreakOnHit = true
module.BreakifNotHuman = true
module.BreakifHuman = true
module.BreakOnBlockAbility = true

module.HitEffects = {Damage = {Damage = 10}}

module.Projectiles = {
    [1] = ReplicatedStorage.EffectParts.Abilities.ProjectileBarrage.FlowerPotBarrage.Pot1,
    [2] = ReplicatedStorage.EffectParts.Abilities.ProjectileBarrage.FlowerPotBarrage.Pot2,
    [3] = ReplicatedStorage.EffectParts.Abilities.ProjectileBarrage.FlowerPotBarrage.Pot3,
    [4] = ReplicatedStorage.EffectParts.Abilities.ProjectileBarrage.FlowerPotBarrage.Pot4,
}


--// CharacterAnimations - client
function module.CharacterAnimations(params, abilityDefs, playerPing)

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

    spawn(function()

        ManageStand.MoveStand(params, "Front")
        ManageStand.Aura_On(params)

        local delay = 0
        if playerPing then
            delay = playerPing
            if delay > .2 then
                delay = .2
            end
        end

        if delay > 0 then
            wait(delay)
        end

        ManageStand.PlayAnimation(params, "Barrage", .25)
        
        wait(module.MobilityLockParams.Duration)

        ManageStand.MoveStand(params, "Idle")
        ManageStand.StopAnimation(params, "Barrage")
        ManageStand.Aura_Off(params)
    end)
 
	WeldedSound.NewSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.General.GenericWhoosh_Fast)

end

--// GetProjectile - server
function module.GetProjectile()
    return module.Projectiles[math.random(1,4)]:Clone()
end

--// ProjectileAnimations - client
function module.ProjectileEffects(projectileDef)

    WeldedSound.NewSound(projectileDef.Model, ReplicatedStorage.Audio.General.Thwump)

    local newBurst = ReplicatedStorage.EffectParts.Abilities.ProjectileBarrage.FlowerPotBarrage.FatBurst:Clone()
    newBurst.Parent = Workspace.RenderedEffects
    newBurst.CFrame = projectileDef.Origin
    Debris:AddItem(newBurst, 3)

    local burstTween = TweenService:Create(newBurst, TweenInfo.new(1),{Size = Vector3.new(4,4,4), Transparency = 1})
    burstTween:Play()
    burstTween:Destroy()

end

--// ProjectileImpact - client
function module.ProjectileImpact(params)

    local projectilePart = Workspace.RenderedEffects:FindFirstChild(params.ProjectileID)
    if projectilePart then

        projectilePart:Destroy()
 
        local destroyPart = ReplicatedStorage.EffectParts.Abilities.ProjectileBarrage.FlowerPotBarrage.DestroyPart:Clone()
        destroyPart.Parent = Workspace.RenderedEffects
        destroyPart.Position = params.Position
        Debris:AddItem(destroyPart, 6)

        local soundParams = {}
        soundParams.SoundProperties = {TimePosition = 0.2}
        WeldedSound.NewSound(destroyPart, ReplicatedStorage.Audio.General.CeramicBreak)

        destroyPart.Particle:Emit(100)

        local breakTween = TweenService:Create(destroyPart, TweenInfo.new(.8),{Size = Vector3.new(2,2,2), Transparency = 1})
        breakTween:Play()
        breakTween:Destroy()

    end

end



return module