-- Knit Runtime - CLIENT
-- PDab
-- 11/10/2020
-- starts up Knit and prepares the client

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

-- Expose Modules to Knit
Knit.Shared = ReplicatedStorage.GameFiles.Shared

Knit.Powers = ReplicatedStorage.GameFiles.Shared.PowerModules.Powers
Knit.Abilities = ReplicatedStorage.GameFiles.Shared.PowerModules.Abilities
Knit.Effects = ReplicatedStorage.GameFiles.Shared.PowerModules.Effects
Knit.PowerUtils = ReplicatedStorage.GameFiles.Shared.PowerModules.PowerUtils

Knit.GuiModules = StarterPlayer.StarterPlayerScripts.GameFiles.Modules.GuiModules
Knit.StateModules = ReplicatedStorage.GameFiles.Shared.StateModules

-- Load all controllers:
for _,v in ipairs(script.Parent.Controllers:GetDescendants()) do
    if (v:IsA("ModuleScript")) then
        require(v)
    end
end

Knit.Start()
print("Knit CLIENT - Runtime Started")
