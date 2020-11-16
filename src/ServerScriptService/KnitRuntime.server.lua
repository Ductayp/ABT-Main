-- Knit Runtime
-- PDab
-- 11/2/2020
-- starts up Knit and prepares the game to run

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

-- Expose Moudles to Knit
Knit.Shared = ReplicatedStorage:FindFirstChild("Shared",true))
Knit.Powers = ReplicatedStorage:FindFirstChild("Powers",true))

-- Load all services:
for _,v in ipairs(script.Parent.Services:GetDescendants()) do
    if (v:IsA("ModuleScript")) then
        require(v)
    end
end

Knit.Start()
print("Knit SERVER - Runtime Started")