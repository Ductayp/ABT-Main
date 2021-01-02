-- Knit Runtime - CLIENT
-- PDab
-- 11/10/2020
-- starts up Knit and prepares the client

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayerScripts")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

-- Expose Modules to Knit
Knit.Shared = ReplicatedStorage.GameFiles.Shared
Knit.Powers = ReplicatedStorage.GameFiles.Powers
Knit.Abilities = ReplicatedStorage.GameFiles.Abilities
Knit.Effects = ReplicatedStorage.GameFiles.Effects
Knit.GuiModules = StarterPlayerScripts.GameFiles.Modules.GuiModules

-- Load all controllers:
for _,v in ipairs(script.Parent.Controllers:GetDescendants()) do
    if (v:IsA("ModuleScript")) then
        require(v)
    end
end

Knit.Start()
print("Knit CLIENT - Runtime Started")
