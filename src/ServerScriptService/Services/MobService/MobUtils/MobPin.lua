-- PinMob

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local MobAnimations = require(Knit.MobUtils.MobAnimations)

local module = {}

function module.Pin_Duration(mobId, duration)

    local thisMob = Knit.Services.MobService.SpawnedMobs[mobId]
    if not thisMob then return end
    if not thisMob.Model then return end

    local HRP = thisMob.Model:FindFirstChild("HumanoidRootPart")

    if HRP then

        thisMob.Model.Humanoid:MoveTo(thisMob.Model.HumanoidRootPart.Position)

        --thisMob.Model.HumanoidRootPart.Anchored = true
        local anchorPart = Instance.new("Part")
        anchorPart.Anchored = true
        anchorPart.Transparency = 1
        anchorPart.Parent = HRP
        utils.EasyWeld(HRP, anchorPart, anchorPart)

        thisMob.BrainState = "Wait"

        thisMob.IsPinned = true
        spawn(function()

            wait(duration)

            if not thisMob then return end
            if not thisMob.Model then return end
            if not thisMob.Model:FindFirstChild("HumanoidRootPart") then return end

            thisMob.IsPinned = false
            --thisMob.Model.HumanoidRootPart.Anchored = false
            anchorPart:Destroy()

            if thisMob and thisMob.Model and thisMob.Model.HumanoidRootPart then
                thisMob.Model.HumanoidRootPart:SetNetworkOwner(nil)
            end
            
        end)

        MobAnimations.PauseAll(mobId, duration)

    end

end

return module