-- Knit Runtime
-- PDab
-- 11/2/2020
-- starts up Knit and prepares the game to run

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

-- Expose Moudles to Knit
Knit.Shared = ReplicatedStorage.GameFiles.Shared
Knit.Powers = ReplicatedStorage.GameFiles.Powers
Knit.Abilities = ReplicatedStorage.GameFiles.Abilities
Knit.Effects = ReplicatedStorage.GameFiles.Effects
Knit.ItemSpawnTables = ServerScriptService.GameFiles.ItemSpawnTables
Knit.ModifierService = ServerScriptService.GameFiles.Services.ModifierService

-- Load all services:
for _,v in ipairs(script.Parent.Services:GetDescendants()) do
    if (v:IsA("ModuleScript")) then
        require(v)
    end
end

Knit.Start()
print("Knit SERVER - Runtime Started")