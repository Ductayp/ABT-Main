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
Knit.HitEffects = ReplicatedStorage.GameFiles.Shared.PowerModules.HitEffects
Knit.Abilities = ReplicatedStorage.GameFiles.Shared.PowerModules.Abilities
Knit.AbilityMods = ReplicatedStorage.GameFiles.Shared.PowerModules.AbilityMods
Knit.PowerUtils = ReplicatedStorage.GameFiles.Shared.PowerModules.PowerUtils 

Knit.ServerModules = ServerScriptService.GameFiles.Modules

Knit.DialogueModules = ReplicatedStorage.GameFiles.Shared.DialogueModules
Knit.StateModules = ReplicatedStorage.GameFiles.Shared.StateModules
Knit.Defs = ReplicatedStorage.GameFiles.Shared.Defs
Knit.CutScenes = ReplicatedStorage.GameFiles.Shared.CutScenes

-- Load all services:
for _,v in ipairs(script.Parent.Services:GetDescendants()) do
    if (v:IsA("ModuleScript")) then
        require(v)
    end
end

Knit.Start()
print("Knit SERVER - Runtime Started")
