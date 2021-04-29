-- Damage Effect
-- PDab
-- 12-4-2020

-- applies both pracitcal effects such as actual damage in numbers as well as the visual effects

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)

local Damage = {}

function Damage.Server_ApplyEffect(initPlayer, hitCharacter, effectParams, hitParams)

    -- just a final check to be sure were hitting a humanoid
    if hitCharacter:FindFirstChild("Humanoid") then

        -- multiply damage based on passed params
        local actualDamage = effectParams.Damage * hitParams.DamageMultiplier

        -- do the damage
        hitCharacter.Humanoid:TakeDamage(actualDamage)

        -- if it is a mob
        if hitParams.IsMob then
            if hitCharacter.Humanoid then 

                Knit.Services.MobService:DamageMob(initPlayer, hitParams.MobId, actualDamage)

                --[[
                local defaultWalkspeed = hitCharacter:FindFirstChild("DefaultWalkSpeed")
                if not defaultWalkspeed then
                    defaultWalkspeed = Instance.new("NumberValue")
                    defaultWalkspeed.Name = "DefaultWalkSpeed"
                    defaultWalkspeed.Value = 16
                    defaultWalkspeed.Parent = hitCharacter
                end

                spawn(function()
                    hitCharacter.Humanoid.WalkSpeed = 8
                    wait(1.5)
                    if hitCharacter:FindFirstChild("Humanoid") then
                        hitCharacter.Humanoid.WalkSpeed = defaultWalkspeed.Value
                    end
                end)
                ]]--
            end
        end

        local hitPlayer = utils.GetPlayerFromCharacter(hitCharacter)
        if hitPlayer then
            if not Players:FindFirstChild(hitPlayer.Name) then return end

            if Knit.Services.PlayerUtilityService.PlayerAnimations[hitPlayer.UserId] then
                local rand = math.random(1,2)
                if rand == 1 then
                    Knit.Services.PlayerUtilityService.PlayerAnimations[hitPlayer.UserId].Damage_1:Play()
                else
                    Knit.Services.PlayerUtilityService.PlayerAnimations[hitPlayer.UserId].Damage_2:Play()
                end
            end

        end

        if effectParams.KnockBack then 
            spawn(function()
                local force = effectParams.KnockBack
                local lookVector = CFrame.new(initPlayer.Character.HumanoidRootPart.Position, hitCharacter.HumanoidRootPart.Position).LookVector
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.Name = "DamageKnockBack"
                bodyVelocity.MaxForce = Vector3.new(500000,500000,500000)
                bodyVelocity.P = 1000000
                bodyVelocity.Velocity =  Vector3.new(lookVector.X * force, lookVector.Y * force, lookVector.Z * force)
                bodyVelocity.Parent = hitCharacter.HumanoidRootPart
                wait(.1)
                bodyVelocity:Destroy()
            end)
        end

        -- send the visual effects to all clients
        local renderParams = {}
        renderParams.Damage = actualDamage
        renderParams.HitCharacter = hitCharacter
        renderParams.HideEffects = effectParams.HideEffects
        Knit.Services.PowersService:RenderHitEffect_AllPlayers("Damage", renderParams)
    end

end

function Damage.Client_RenderEffect(params)

    -- damage number
    if not params.HideNumbers then
        local billboardGui = ReplicatedStorage.EffectParts.Effects.Damage.DamageNumber:Clone()
        billboardGui.Parent = params.HitCharacter
        billboardGui.TextLabel.Text = params.Damage

        local newRand = math.random(-100,100) / 100
        billboardGui.StudsOffset = billboardGui.StudsOffset + Vector3.new(newRand,0,0)

        local numberMove = TweenService:Create(billboardGui,TweenInfo.new(.5),{StudsOffset = (billboardGui.StudsOffset + Vector3.new(0,3,0))})
        numberMove:Play()
        
        spawn(function()
            wait(.4)
            billboardGui:Destroy()
            numberMove = nil
        end)
    end

    -- particles
    if not params.HideEffects then
        local dots = params.HitCharacter.HumanoidRootPart:FindFirstChild("Particle_Dots_1")
        if not dots then
            dots = ReplicatedStorage.EffectParts.Effects.Damage.Particle_Dots_1:Clone()
            dots.Parent = params.HitCharacter.HumanoidRootPart
        end
    
        local lines = params.HitCharacter.HumanoidRootPart:FindFirstChild("Particle_Lines_1")
        if not lines then
            lines = ReplicatedStorage.EffectParts.Effects.Damage.Particle_Lines_1:Clone()
            lines.Parent = params.HitCharacter.HumanoidRootPart
        end
    
        dots:Emit(1)
        lines:Emit(1)
    end

    if not params.DisableSound then
        local rand = math.random(1,2)
        if rand == 1 then
            WeldedSound.NewSound(params.HitCharacter.HumanoidRootPart, ReplicatedStorage.Audio.HitEffects.Damage.Damage_1)
        else
            WeldedSound.NewSound(params.HitCharacter.HumanoidRootPart, ReplicatedStorage.Audio.HitEffects.Damage.Damage_2)
        end
    end
   
end


return Damage