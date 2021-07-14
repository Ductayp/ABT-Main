--[[
local dataPoints = hitboxMod:GetSquarePoints(rootPart.CFrame,8,8)
    
local projectileData = {}
projectileData["Points"] = dataPoints
projectileData["Direction"] = CFrame.new(rootPart.Position, mouseCFrame.Position).LookVector
projectileData["Velocity"] = 2000
projectileData["Lifetime"] = 0.1
projectileData["Iterations"] = 300
projectileData["Visualize"] = false
projectileData["Ignore"] = {workspace.Debris, workspace.Spawns, character}

projectileData["Function"] = function(result)
    if result.Instance.Parent then
        localSkillEvent:FireAllClients("FlameLocalMod", "FirePunchBeamStop", player)
        partHitPos = result.Position
    end
end

hitboxMod:CastProjectileHitbox(projectileData)
]]--