local folderNames = {
    "RenderedEffects",
    "Spawners_Morioh",
    "Spawners_Morioh",
    "Spawners_PvPArena",
    "ProjectileIgnore",
    "ProjectilePassTrough",
    "ItemSpawnService",
    "ZoneServiceGroups",
    "SpawnedItems",
}

local ignoreFolders = {}
for _, name in pairs(folderNames) do
    local newIgnore = workspace:FindFirstChild(name, true)
    table.insert(ignoreFolders, newIgnore)
end


return {
    ignoreFolders
}

