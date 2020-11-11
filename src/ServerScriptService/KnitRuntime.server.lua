-- Knit Runtime
-- PDab
-- 11/2/2020
-- starts up Knit and prepares the game to run

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

-- Load all services:
for _,v in ipairs(script.Parent.Services:GetDescendants()) do
    if (v:IsA("ModuleScript")) then
        require(v)
    end
end

-- Expose Moudles to Knit
Knit.Shared = game:GetService("ReplicatedStorage").GameFiles.Shared

Knit.Start()
print("Knit Runtime Started")