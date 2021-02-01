-- SomeController
-- PDab
-- 1/1/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local SomeController = Knit.CreateController { Name = "SomeController" }


function SomeController:SomeFunction()

end

function SomeController:KnitStart()

end

function SomeController:KnitInit()

end

return SomeController