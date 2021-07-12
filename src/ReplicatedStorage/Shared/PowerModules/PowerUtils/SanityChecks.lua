-- SanityChecks

local MAX_RANGE = 10

local module = {}

--// TestPosition - maxRaneg is optional
function module.TestPosition(initPlayer, targetPosition, maxRange)

    if not initPlayer then return end
    if not initPlayer.Character then return end
    local HRP = initPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end

    local finalPosition = targetPosition

    local sanityCheck = (targetPosition - HRP.Position).magnitude
    if maxRange then
        if sanityCheck > maxRange then
            warn(initPlayer, " Failed TestPosition Sanity Check")
            finalPosition = HRP.Position
        end
    else
        if sanityCheck > MAX_RANGE then
            warn(initPlayer, " Failed TestPosition Sanity Check")
            finalPosition = HRP.Position
        end
    end

    return finalPosition

end

--// TestCFame - checks if two Crames are within MAX_RANGE or optional maxRange
function module.TestCFrame(initPlayer, targetCFrame, maxRange)

    if not initPlayer then return end
    if not initPlayer.Character then return end
    local HRP = initPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end

    finalCFrame = targetCFrame

    local sanityCheck = (targetCFrame.Position - HRP.Position).magnitude
    if maxRange then
        if sanityCheck > maxRange then
            warn(initPlayer, " Failed TestCFrame Sanity Check")
            finalCFrame = HRP.CFrame
        end
    else
        if sanityCheck > MAX_RANGE then
            warn(initPlayer, " Failed TestCFrame Sanity Check")
            finalCFrame = HRP.CFrame
        end
    end

    return finalCFrame

end

return module