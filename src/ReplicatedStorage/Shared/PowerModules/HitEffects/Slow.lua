-- Slow

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local MobWalkSpeed = require(Knit.MobUtils.MobWalkSpeed)

local Slow = {}

--// Server_ApplyEffect
function Slow.Server_ApplyEffect(initPlayer, hitCharacter, effectParams, hitParams)

    if not hitCharacter.Humanoid then return end

    --[[
    local slowTag = hitCharacter:FindFirstChild("HitEffect_Slow", true)
    if slowTag then 
        return 
    else
        spawn(function()
            slowTag = Instance.new("NumberValue")
            slowTag.Name = "HitEffect_Slow"
            slowTag.Value = effectParams.WalkSpeedModifier
            slowTag.Parent = hitCharacter
            wait(effectParams.Duration)
            slowTag:Destroy()
        end)
    end

    ]]--

    if hitParams.IsMob then
        local thisMob = Knit.Services.MobService:GetMobById(hitParams.MobId)
        if thisMob and thisMob.Defs.IsMobile then
            spawn(function()

                MobWalkSpeed.AddModifier(thisMob, "HitEffects_WalkSpeed", effectParams.WalkSpeedModifier)
                wait(effectParams.Duration)
                MobWalkSpeed.RemoveModifier(thisMob, "HitEffects_WalkSpeed")

            end)
        end
        return
    end

    local hitPlayer = utils.GetPlayerFromCharacter(hitCharacter)
    if hitPlayer then
        spawn(function()
            Knit.Services.StateService:AddEntryToState(hitPlayer, "WalkSpeed", "HitEffects_Slow", effectParams.WalkSpeedModifier, nil)
            wait(effectParams.Duration)
            Knit.Services.StateService:RemoveEntryFromState(hitPlayer, "WalkSpeed", "HitEffects_Slow")
        end)
        return
    end


end

--// Client_RenderEffect
function Slow.Client_RenderEffect(params)


end

return Slow