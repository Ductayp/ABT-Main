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

local SheerHeartAttack = {}

SheerHeartAttack.PartAssembly = ReplicatedStorage.EffectParts.AbilityMods.SheerHeartAttack.Tank
SheerHeartAttack.OriginOffset = CFrame.new(0,1,-2) -- this is the offset in front of the character
SheerHeartAttack.LifeSpan = 10 -- how long it will exist before it disappears

function SheerHeartAttack.new(initPlayer)

    local newSeekerPart = SheerHeartAttack.PartAssembly:Clone()
    newSeekerPart.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(SheerHeartAttack.OriginOffset)
    newSeekerPart.BodyPosition.D = 125
    newSeekerPart.BodyPosition.P = 1000
    newSeekerPart.BodyPosition.MaxForce = Vector3.new(1,1,1) * 2000
    newSeekerPart:SetNetworkOwner(nil)

    local newSeeker = {
        MainPart = newSeekerPart,
        HitBox = newSeekerPart.HitBox
    }

    return newSeeker
end

function SheerHeartAttack.GetHitEffects(initPlayer, hitCharacter, seeker)

    local newLookVector = (hitCharacter.HumanoidRootPart.Position - seeker.MainPart.Position).unit

    local newHitEffects = {Damage = {Damage = 35, HideEffects = true}, Blast = {}, KnockBack = {Force = 70, ForceY = 50, LookVector = newLookVector}}

    return newHitEffects
end

function SheerHeartAttack.PlayAnimation(initPlayer)
    Knit.Services.PlayerUtilityService.PlayerAnimations[initPlayer.UserId].CoinFlip:Play()
end

function SheerHeartAttack.AquireTarget(initPlayer, seeker)

end

function SheerHeartAttack.Server_Launch(initPlayer, seeker)
 
end

function SheerHeartAttack.Server_Hit(initPlayer, seeker)
    localSheerHeartAttack.GetHitEffects(initPlayer, hitCharacter, seeker)
    Knit.Services.PowersService:RegisterHit(initPlayer, humanoid.Parent, abilityDefs)
end

function SheerHeartAttack.Client_Launch(initPlayer, seeker)

end

function SheerHeartAttack.Client_Hit(initPlayer, seeker)

end


return SheerHeartAttack


