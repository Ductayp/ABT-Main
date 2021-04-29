local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

local groupKeys = {}
local spawnerGroups = require(Knit.Defs.SpawnGroups)
for key, value in pairs(spawnerGroups) do
    table.insert(groupKeys, key)
end

return function (registry)
    registry:RegisterType("spawnGroup", registry.Cmdr.Util.MakeEnumType("SpawnGroup", groupKeys))
end
