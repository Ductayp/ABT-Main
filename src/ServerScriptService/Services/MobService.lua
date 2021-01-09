-- Mob Service
-- PDab
-- 1/8/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local PhysicsService = game:GetService("PhysicsService")


-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local MobService = Knit.CreateService { Name = "MobService", Client = {}}
local RemoteEvent = require(Knit.Util.Remote.RemoteEvent)

-- modules
local utils = require(Knit.Shared.Utils)
--local Config = require(Knit.MobModules)

-- events
MobService.Client.Event_Update_ArrowPanel = RemoteEvent.new()



--// PlayerAdded
function MobService:PlayerAdded(player)
--[[
    -- set players collision group according to Config
    if Config.PlayerCollide == false then
        local Character = Player.Character or Player.CharacterAdded:Wait()
		SetCollisionGroup(Character, "Mob_NoCollide");
		Player.CharacterAdded:Connect(function(Character)
			SetCollisionGroup(Character, "Mob_NoCollide");
		end)
    end
    ]]--

end


--// KnitStart
function MobService:KnitStart()

    -- create no-collision group and set it
    PhysicsService:CreateCollisionGroup("Mob_NoCollide")
    PhysicsService:CollisionGroupSetCollidable("Mob_NoCollide", "Mob_NoCollide", false)

    -- start the main loop
    spawn(function()
        --self:MainLoop()
    end)
    
    
end

--// KnitInit
function MobService:KnitInit()

    -- Player Added event
    Players.PlayerAdded:Connect(function(player)
        self:PlayerAdded(player)
    end)

    -- Player Added event for studio tesing, catches when a player has joined before the server fully starts
    for _, player in ipairs(Players:GetPlayers()) do
        self:PlayerAdded(player)
    end

    -- Player Removing event
    Players.PlayerRemoving:Connect(function(player)
        --self:PlayerRemoved(player)
    end)

end


return MobService