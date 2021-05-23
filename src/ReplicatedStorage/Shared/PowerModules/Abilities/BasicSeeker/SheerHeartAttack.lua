-- Basic Grenade Ability
-- PDab
-- 11-27-2020

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)
local TargetByZone = require(Knit.PowerUtils.TargetByZone)

local SheerHeartAttack = {}

SheerHeartAttack.PartAssembly = ReplicatedStorage.EffectParts.AbilityMods.SheerHeartAttack.Tank
SheerHeartAttack.OriginOffset = CFrame.new(0,1,-3) -- this is the offset in front of the character
SheerHeartAttack.LifeSpan = 10 -- how long it will exist before it disappears
SheerHeartAttack.BlastRadius = 10 -- distance it will do collateral damage on detonate

function SheerHeartAttack.new(initPlayer)

    local newSeekerPart = SheerHeartAttack.PartAssembly:Clone()
    newSeekerPart.BodyForce.Force = Vector3.new(0, newSeekerPart:GetMass() * workspace.Gravity, 0)
    newSeekerPart.BodyPosition.D = 5
    newSeekerPart.BodyPosition.P = 50
    newSeekerPart.BodyPosition.MaxForce = Vector3.new(1,1,1) * 50
    
    local newSeeker = {
        MainPart = newSeekerPart,
        HitBox = newSeekerPart.HitBox,
        LifeSpan = SheerHeartAttack.LifeSpan,
        Destroyed = false
    }

    return newSeeker
end

function SheerHeartAttack.GetHitEffects(initPlayer, hitCharacter, seeker)

    local newLookVector = (hitCharacter.HumanoidRootPart.Position - seeker.MainPart.Position).unit

    local newHitEffects = {Damage = {Damage = 35, HideEffects = true}, Blast = {}, KnockBack = {Force = 70, ForceY = 50, LookVector = newLookVector}}

    return newHitEffects
end

function SheerHeartAttack.PlayAnimations(initPlayer, abilityDefs)
    Knit.Services.PlayerUtilityService.PlayerAnimations[initPlayer.UserId].CoinFlip:Play()
end

function SheerHeartAttack.AquireTarget(initPlayer, seeker, abilityDefs)

    if not initPlayer then
        SheerHeartAttack.DestroySeeker(initPlayer, seeker, abilityDefs)
    end

    --[[
    -- target table is an array where each entry is another array that contains the mob.Model or player.Character and its magnitude from initPlayer
    local targetTable = {}

    -- put all mobs in targetTable
    for _,mob in pairs(Knit.Services.MobService.SpawnedMobs) do
        if mob.Model:FindFirstChild("Humanoid") then
            if mob.Model.Humanoid.Health > 0 then
                targetTable[#targetTable + 1] = {mob.Model, (mob.Model.HumanoidRootPart.Position -  initPlayer.Character.HumanoidRootPart.Position).Magnitude}
            end
        end
    end

    -- put all players in targetTable
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= initPlayer then
            if not require(Knit.StateModules.Invulnerable).IsInvulnerable(player) then
                if player.Character and player.Character.HumanoidRootPart then
                    targetTable[#targetTable + 1] = {player.Character, (player.Character.HumanoidRootPart.Position -  initPlayer.Character.HumanoidRootPart.Position).Magnitude}
                end
            end
        end
    end
    ]]--

    local targetTable = {}

    local targets = TargetByZone.GetAll(initPlayer, true)

    for _, hitCharacter in pairs(targets) do
        local distance = (hitCharacter.HumanoidRootPart.Position -  initPlayer.Character.HumanoidRootPart.Position).Magnitude
        targetTable[#targetTable + 1] = {hitCharacter, distance}
    end

    -- sort table by magnitude value, smallest magnitude gets into position 1
    table.sort(targetTable, function(a, b)
        return a[2] < b[2]
    end)

    -- set the target
    -- the first [1] is the first position in the targetTable array. The seocnd [1] is the mob.Modle of player.Character inside that entry
    seeker.Target = targetTable[1][1] 

end

function SheerHeartAttack.Server_Launch(initPlayer, seeker, abilityDefs)

    local launchTarget = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0, -20))
    seeker.MainPart.BodyPosition.Position = launchTarget.Position
    
    seeker.MainPart.Parent = Workspace.RenderedEffects
    seeker.MainPart.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(SheerHeartAttack.OriginOffset)
    seeker.MainPart:SetNetworkOwner(nil)
    
    WeldedSound.NewSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.StandSpecific.KillerQueen.SheerHeartAttack)

    spawn(function()
        wait(.5)
        --seeker.MainPart.BodyPosition.Position = seeker.Target.HumanoidRootPart.Position
        while seeker.Destroyed == false do
            if not seeker.Target:FindFirstChild("Humanoid") then
                SheerHeartAttack.AquireTarget(initPlayer, seeker)
            else
                seeker.MainPart.BodyPosition.Position = seeker.Target.HumanoidRootPart.Position
            end
            wait(.1)
        end
    end)
   
 
end

function SheerHeartAttack.Server_Hit(initPlayer, seeker, hitCharacter, abilityDefs)
    abilityDefs.HitEffects = SheerHeartAttack.GetHitEffects(initPlayer, hitCharacter, seeker)
    Knit.Services.PowersService:RegisterHit(initPlayer, hitCharacter, abilityDefs)
end

function SheerHeartAttack.Client_Launch(initPlayer, seeker)

end

function SheerHeartAttack.Client_Hit(initPlayer, seeker)

end

function SheerHeartAttack.DestroySeeker(initPlayer, seeker, abilityDefs, hitCharacter)
    seeker.Destroyed = true
    seeker.MainPart.Anchored = true
    seeker.MainPart.Mesh.Transparency = 1

    seeker.MainPart.Flame_Particle.Enabled = true
    seeker.MainPart.Smoke_Particle.Enabled = true
    seeker.MainPart.Aura_Particle.Enabled = false
    seeker.MainPart.Trail_Particle.Enabled = false

    WeldedSound.NewSound(seeker.MainPart, ReplicatedStorage.Audio.General.Explosion_3, {PlaybackSpeed = 1.5})

    spawn(function()
        wait(.1)
        seeker.MainPart.Flame_Particle.Enabled = false
        wait(.5)
        seeker.MainPart.Smoke_Particle.Enabled = false
        wait(5)
        seeker.MainPart:Destroy()
        seeker = nil
    end)

    -- hit all mobs in range
    for _,mob in pairs(Knit.Services.MobService.SpawnedMobs) do
        if mob.Model ~= hitCharacter then
            if mob.Model:FindFirstChild("Humanoid") then
                if (mob.Model.HumanoidRootPart.Position - seeker.MainPart.Position).Magnitude < SheerHeartAttack.BlastRadius then
                    local abilityDefs = {}
                    SheerHeartAttack.Server_Hit(initPlayer, seeker, mob.Model, abilityDefs)
                end
            end
        end
    end

    -- hit all players in ange
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character ~= hitCharacter then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if (player.Character.HumanoidRootPart.Position - seeker.MainPart.Position).Magnitude < SheerHeartAttack.BlastRadius then
                    local abilityDefs = {}
                    SheerHeartAttack.Server_Hit(initPlayer, seeker, player.Character, abilityDefs)
                end
            end
        end
    end

end

return SheerHeartAttack


