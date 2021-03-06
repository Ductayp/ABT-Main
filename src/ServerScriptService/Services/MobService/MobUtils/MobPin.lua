-- PinMob

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local MobAnimations = require(Knit.MobUtils.MobAnimations)

local module = {}

function module.Pin_Duration(mobId, duration)

    local thisMob = Knit.Services.MobService.SpawnedMobs[mobId]
    if not thisMob then return end
    if not thisMob.Model then return end

    if thisMob.Model.Humanoid then

        thisMob.Model.Humanoid:MoveTo(thisMob.Model.HumanoidRootPart.Position)

        thisMob.Model.HumanoidRootPart.Anchored = true
        thisMob.BrainState = "Wait"

        thisMob.IsPinned = true
        spawn(function()
            wait(duration)

            if not thisMob then return end
            if not thisMob.Model then return end
            if not thisMob.Model:FindFirstChild("HumanoidRootPart") then return end

            thisMob.IsPinned = false
            thisMob.Model.HumanoidRootPart.Anchored = false
            thisMob.Model.HumanoidRootPart:SetNetworkOwner(nil)
        end)

        MobAnimations.PauseAll(mobId, duration)

    end

end

return module