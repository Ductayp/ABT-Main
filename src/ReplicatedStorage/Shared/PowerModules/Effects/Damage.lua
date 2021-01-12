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
local powerUtils = require(Knit.Shared.PowerUtils)


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
            Knit.Services.MobService:DamageMob(initPlayer, hitParams.MobId, actualDamage)
        end

        -- send the visual effects to all clients
        local renderParams = {}
        renderParams.Damage = actualDamage
        renderParams.HitCharacter = hitCharacter
        Knit.Services.PowersService:RenderEffect_AllPlayers("Damage", renderParams)
    end

end

function Damage.Client_RenderEffect(params)

    local billboardGui = ReplicatedStorage.EffectParts.Effects.Damage.DamageNumber:Clone()
    billboardGui.Parent = params.HitCharacter
    billboardGui.TextLabel.Text = params.Damage

    local newRand = math.random(-100,100) / 100
    billboardGui.StudsOffset = billboardGui.StudsOffset + Vector3.new(newRand,0,0)

    --local numberTween = TweenService:Create(textLabel,TweenInfo.new(1),{Position = (textLabel.Position + UDim2.new(0, 0, -4, 0))})
    local numberMove = TweenService:Create(billboardGui,TweenInfo.new(.5),{StudsOffset = (billboardGui.StudsOffset + Vector3.new(0,3,0))})
    numberMove:Play()

    numberMove.Completed:Connect(function(playbackState)
        if playbackState == Enum.PlaybackState.Completed then
            billboardGui:Destroy()
        end
    end)


end


return Damage