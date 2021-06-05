-- Slow

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local serialNumber = 1

local Slow = {}

--// Server_ApplyEffect
function Slow.Server_ApplyEffect(initPlayer, hitCharacter, effectParams, hitParams)

    if not hitCharacter.Humanoid then return end

    -- slow a Player
    local hitPlayer = utils.GetPlayerFromCharacter(hitCharacter)
    if hitPlayer then

        local slowIndicator = Instance.new("NumberValue")
        slowIndicator.Parent = hitCharacter.Humanoid
        slowIndicator.Name = "HitEffect_Slow"
        slowIndicator.Value = serialNumber
        serialNumber += 1

        hitCharacter.Humanoid.WalkSpeed = effectParams.WalkSpeed

        spawn(function()
            wait(effectParams.Duration)
            slowIndicator:Destroy()
            local existingIndicator = hitCharacter.Humanoid:FindFirstChild("HitEffect_Slow")
            if not existingIndicator then
                hitCharacter.Humanoid.WalkSpeed = require(Knit.StateModules.WalkSpeed).GetModifiedValue(hitPlayer)
            end
        end)

    end

end

--// Client_RenderEffect
function Slow.Client_RenderEffect(params)


end

return Slow