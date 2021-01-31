-- Admin
-- PDab
-- 12/20/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local AdminController = Knit.CreateController { Name = "AdminController" }
local utils = require(Knit.Shared.Utils)
--local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))

--// PlayerAdded
function AdminController:PlayerAdded(player)

end

--// PlayerRemoved
function AdminController:PlayerRemoved(player)

end

--// KnitStart
function AdminController:KnitStart()

    --Cmdr:SetActivationKeys({ Enum.KeyCode.F2 })

end

--// KnitInit
function AdminController:KnitInit()

end

return AdminController