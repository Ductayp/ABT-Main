for i, v in pairs(workspace.Wall.ClientWall:GetChildren()) do
    if v.Name == "Part" then
        local weld = Instance.new("WeldConstraint")
        weld.Parent = workspace.Wall.ClientWall.Welds
        weld.Part0 = workspace.Wall.ClientWall
        weld.Part1 = v
    end
end