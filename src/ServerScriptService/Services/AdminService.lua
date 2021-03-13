-- Admin
-- PDab
-- 12/20/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local AdminService = Knit.CreateService { Name = "AdminService", Client = {}}
local RemoteEvent = require(Knit.Util.Remote.RemoteEvent)
local utils = require(Knit.Shared.Utils)
local Cmdr = require(Knit.ServerModules.Cmdr)

--// PlayerAdded
function AdminService:PlayerAdded(player)

end

--// PlayerRemoved
function AdminService:PlayerRemoved(player)

end

--// CharacterAdded
function AdminService:CharacterAdded(player)

end


--// KnitStart
function AdminService:KnitStart()

    Cmdr:RegisterDefaultCommands()
    Cmdr:RegisterCommandsIn(Knit.ServerModules.Cmdr_Modules.Commands)
    Cmdr:RegisterHooksIn(Knit.ServerModules.Cmdr_Modules.Hooks)
    Cmdr:RegisterTypesIn(Knit.ServerModules.Cmdr_Modules.Types)

end

--// KnitInit
function AdminService:KnitInit()


end


return AdminService