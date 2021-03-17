local rayModule = {}

local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")

local function ConvertToVector(CF)
    return typeof(CF) == "CFrame" and CF.Position or CF
end

function rayModule:Cast(Orgin, Goal, Data, FilterType, IgnoreWater, CollisionGroup)

    local StartPosition = ConvertToVector(Orgin)
    local EndPosition = ConvertToVector(Goal)
    local Difference = Goal - Orgin
    local Direction = Difference.Unit
    local Distance = Difference.Magnitude
    local RayData = RaycastParams.new()
    RayData.FilterDescendantsInstances = Data or {}
    RayData.FilterType = FilterType
    RayData.IgnoreWater = IgnoreWater or true
    RayData.CollisionGroup = CollisionGroup or "Default"

    return workspace:Raycast(StartPosition, Direction * Distance, RayData)
end

function rayModule:Visualize(Orgin, Goal, Color)

    local StartPosition = ConvertToVector(Orgin)
    local EndPosition = ConvertToVector(Goal)
    local Distance = (EndPosition - StartPosition).Magnitude
    local Beam = Instance.new("Part")

    Beam.Anchored = true
    Beam.Color = Color or Color3.fromRGB(255, 255, 255)
    Beam.Locked = true
    Beam.CanCollide = false
    Beam.Size = Vector3.new(0.1, 0.1, Distance)
    Beam.CFrame = CFrame.new(StartPosition, EndPosition) * CFrame.new(0, 0, -Distance / 2)
    Beam.Parent = game.Workspace:FindFirstChild("Debris") or game.Workspace
end

return rayModule