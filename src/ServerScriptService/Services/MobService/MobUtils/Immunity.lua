-- Immunity

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

local module = {}

function module.Give_Duration(mobId, abilityName, duration)

    local thisMob = Knit.Services.MobService.SpawnedMobs[mobId]
    if not thisMob then return end

    if not thisMob.Immunity then
        thisMob.Immunity = {}
    end

    spawn(function()
        thisMob.Immunity[abilityName] = true
        wait(duration)
        thisMob.Immunity[abilityName] = nil
    end)

end

return module