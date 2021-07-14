-- BlockHits

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

local module = {}

function module.Block_Duration(mobId, duration)

    local thisMob = Knit.Services.MobService.SpawnedMobs[mobId]
    if not thisMob then return end

    spawn(function()
        thisMob.BlockHits = true
        wait(duration)
        thisMob.BlockHits = false
    end)

end

return module