-- MobAnimations

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

local module = {}

function module.PauseAll(mobId, duration)

    local thisMob = Knit.Services.MobService.SpawnedMobs[mobId]
    if not thisMob then return end
    if not thisMob.Model then return end

    spawn(function()

        for _, animation in pairs(thisMob.Animations) do
            if animation.IsPlaying then
                --animation:Stop()
                animation:AdjustSpeed(0)
            end
        end

        thisMob.DisableAnimations = true
        wait(duration)
        thisMob.DisableAnimations = false

    end)


end

return module