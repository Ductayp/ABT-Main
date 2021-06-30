-- SanityChecks

local MAX_RANGE = 10

local module = {}

--// TestPosition - maxRaneg is optional
function module.TestPosition(initPlayer, targetPosition, maxRange)

    if not initPlayer then return end

    local finalPosition = targetPosition

    local sanityCheck = (targetPosition - initPlayer.Character.HumanoidRootPart.Position).magnitude
    if maxRange then
        if sanityCheck > maxRange then
            finalPosition = initPlayer.Character.HumanoidRootPart.Position
        end
    else
        if sanityCheck > MAX_RANGE then
            finalPosition = initPlayer.Character.HumanoidRootPart.Position
        end
    end

    return finalPosition

end

return module