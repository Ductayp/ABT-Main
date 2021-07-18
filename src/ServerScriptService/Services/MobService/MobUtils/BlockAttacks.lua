-- BlockHits

-- allows a mob to try and attack, but it wont allow it to hit (good for effects only, used in Gold Experience: Soul Punch)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

local module = {}

function module.Block_Duration(mobId, duration)

    local thisMob = Knit.Services.MobService.SpawnedMobs[mobId]
    if not thisMob then return end

    if not thisMob.Model then return end
    local HRP = thisMob.Model:FindFirstChild("HumanoidRootPart")
    if not HRP then return end

    local newBool = Instance.new("BoolValue")
    newBool.Value = true
    newBool.Name = "BlockAttacks"
    newBool.Parent = HRP

    spawn(function()

        wait(duration)

        newBool:Destroy()

    end)

end

return module