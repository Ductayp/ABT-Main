local ReplicatedStorage = game:GetService("ReplicatedStorage")

local standModules = ReplicatedStorage.GameFiles.Shared.PowerModules.Powers
local standNames = {}
for _, module in pairs(standModules:GetChildren()) do
    table.insert(standNames, module.Name)
end

return function (registry)
    registry:RegisterType("standName", registry.Cmdr.Util.MakeEnumType("StandName", standNames))
end