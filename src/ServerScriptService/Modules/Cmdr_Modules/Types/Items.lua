local ReplicatedStorage = game:GetService("ReplicatedStorage")

local itemDefs = require(ReplicatedStorage.GameFiles.Shared.Defs.ItemDefs)
local itemKeys = {}
for key, value in pairs(itemDefs) do
    table.insert(itemKeys, key)
end

return function (registry)
    registry:RegisterType("items", registry.Cmdr.Util.MakeEnumType("Items", itemKeys))
end