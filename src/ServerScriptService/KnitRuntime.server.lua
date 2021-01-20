-- Knit Runtime
-- PDab
-- 11/2/2020
-- starts up Knit and prepares the game to run

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

-- Expose Modules to Knit
Knit.Shared = ReplicatedStorage.GameFiles.Shared

Knit.Powers = ReplicatedStorage.GameFiles.Shared.PowerModules.Powers
Knit.Effects = ReplicatedStorage.GameFiles.Shared.PowerModules.Effects
Knit.Abilities = ReplicatedStorage.GameFiles.Shared.PowerModules.Abilities
Knit.PowerUtils = ReplicatedStorage.GameFiles.Shared.PowerModules.PowerUtils 

Knit.ItemSpawnTables = ServerScriptService.GameFiles.Modules.ItemSpawnModules
Knit.StateModules = ReplicatedStorage.GameFiles.Shared.StateModules
Knit.InventoryModules = ServerScriptService.GameFiles.Modules.InventoryModules
Knit.MobModules = ServerScriptService.GameFiles.Modules.MobModules

-- Load all services:
for _,v in ipairs(script.Parent.Services:GetDescendants()) do
    if (v:IsA("ModuleScript")) then
        require(v)
    end
end

Knit.Start()
print("Knit SERVER - Runtime Started")