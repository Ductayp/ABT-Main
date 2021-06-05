local ignoreFolders = {}

for i, v in pairs(workspace:GetDescendants()) do
    if v:IsA("Folder") then

        local ignore = v:GetAttribute("IgnoreProjectiles")
        if ignore then
            table.insert(ignoreFolders, v)
        end
    end
end

return {
    ignoreFolders
}

