-- HideHealth

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

local module = {}

function module.Hide_Duration(mobId, duration)

    local thisMob = Knit.Services.MobService.SpawnedMobs[mobId]
    if not thisMob then return end
    if not thisMob.Model then return end

    if thisMob.Model.Humanoid then
        spawn(function()
            thisMob.Model.Humanoid.HealthDisplayDistance = 0
            wait(duration)
            thisMob.Model.Humanoid.HealthDisplayDistance = 50
        end)
    end

end

return module