-- HideHealth

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

local module = {}

function module.Hide_Duration(mobId, duration)

    local thisMob = Knit.Services.MobService.SpawnedMobs[mobId]
    if not thisMob then return end
    if not thisMob.Model then return end

    local humanoid = thisMob.Model:FindFirstChild("Humanoid")

    if humanoid then
        spawn(function()
            
            humanoid.HealthDisplayDistance = 0

            wait(duration)

            if humanoid then
                humanoid.HealthDisplayDistance = 50
            end

        end)
    end

end

return module