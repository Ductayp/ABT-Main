-- PowersController
-- PDab
-- 11/12/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local PowersController = Knit.CreateController { Name = "PowersController" }

-- instance references

--// InitializePower
function PowersController:InitializePower(params)
    for i,v in pairs(params) do
        print("IntializePower")
        print(i,v)
    end
end

--// ExecutePower
function PowersController:ExecutePower(targetPlayer,params)
    for i,v in pairs(params) do
        print("ExecutePower")
        print(i,v)
    end
end

--// KnitStart
function PowersController:KnitStart()

end

--// KnitInit
function PowersController:KnitInit()

end

return PowersController
