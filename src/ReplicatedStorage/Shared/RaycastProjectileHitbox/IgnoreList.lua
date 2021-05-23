local folderNames = {
    "RenderedEffects",
    "Spawners_Morioh",
    "Spawners_PvPArena",
    "ProjectileIgnore",
    "ProjectilePassTrough",
    "ItemSpawnService",
    "ZoneServiceGroups",
    "SpawnedItems",
    --"MobSpawners_RedHot",
}

local ignoreFolders = {}
for _, name in pairs(folderNames) do
    local newIgnore = workspace:FindFirstChild(name, true)
    table.insert(ignoreFolders, newIgnore)
end

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

