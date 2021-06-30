-- Blast Effect
-- PDab
-- 1-22-2020

-- applies both pracitcal effects such as actual damage in numbers as well as the visual effects

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

local Blast = {}

function Blast.Server_ApplyEffect(initPlayer, hitCharacter, effectParams, hitParams)

    if not initPlayer then return end

    -- just a final check to be sure were hitting a humanoid
    if hitCharacter:FindFirstChild("Humanoid") then

        local actualHeal = effectParams.Quantity * hitParams.DamageMultiplier

        initPlayer.Character.Humanoid.Health += actualHeal

        -- send the visual effects to all clients
        effectParams.HitCharacter = hitCharacter
        Knit.Services.PowersService:RenderHitEffect_AllPlayers("LifeSteal", effectParams)
        
    end

end

function Blast.Client_RenderEffect(params)

    local thisPart = ReplicatedStorage.EffectParts.Effects.LifeSteal.LifeSteal_Particles:Clone()
    thisPart.CFrame = params.HitCharacter.HumanoidRootPart.CFrame
    thisPart.Parent = Workspace.RenderedEffects
    thisPart.Anchored = false
    utils.EasyWeld(params.HitCharacter.UpperTorso, thisPart, thisPart)
    Debris:AddItem(thisPart, 7)

    thisPart.Blood_Particle:Emit(20)
    thisPart.Mist_Particle:Emit(30)


end


return Blast