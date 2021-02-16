-- Ping Service
-- PDab
-- 12/20/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local PlayerUtilityService = Knit.CreateService { Name = "PlayerUtilityService", Client = {}}
local RemoteEvent = require(Knit.Util.Remote.RemoteEvent)

-- modules
local pingTime = require(Knit.Shared.PingTime)
local utils = require(Knit.Shared.Utils)

-- public variables
PlayerUtilityService.PlayerAnimations = {}
PlayerUtilityService.PlayerSwimStates = {}

-- local variables
local pingUpdateTime = 1


function PlayerUtilityService:GetPing(player)
    return pingTime[player]
end


--// UpdatePingLoop
function PlayerUtilityService:UpdatePingLoop()

    spawn(function()
        while game:GetService("RunService").Heartbeat:Wait() do
            for _,player in pairs(Players:GetPlayers()) do
                if ReplicatedStorage.PlayerPings:FindFirstChild(player.UserId) then
                    ReplicatedStorage.PlayerPings[player.UserId].Value = pingTime[player]
                    --print("PING: ",player.Name, pingTime[player])
                end
            end
            wait(pingUpdateTime)
        end
    end) 
end

--// LoadAnimations
function PlayerUtilityService:LoadAnimations(player)

    -- clear the players animation table so its fresh
    PlayerUtilityService.PlayerAnimations[player.UserId] = {}

    -- load the players animation table with tracks
    local animator = player.Character.Humanoid:WaitForChild("Animator")
    for _,animObject in pairs(ReplicatedStorage.PlayerAnimations:GetChildren()) do
        PlayerUtilityService.PlayerAnimations[player.UserId][animObject.Name] = animator:LoadAnimation(animObject)
    end

end

--// HumanoidStateEvents
function PlayerUtilityService:HumanoidStateEvents(player)
--[[

    humanoid.Climbing:Connect(function(speed)
        --print("Climbing speed: ", speed)
    end)
     
    humanoid.FallingDown:Connect(function(isActive)
        --print("Falling down: ", isActive)
    end)
     
    humanoid.GettingUp:Connect(function(isActive)
        --print("Getting up: ", isActive)
    end)
     
    humanoid.Jumping:Connect(function(isActive)
        --print("Jumping: ", isActive)
    end)
     
    humanoid.PlatformStanding:Connect(function(isActive)
        --print("PlatformStanding: ", isActive)
    end)
     
    humanoid.Ragdoll:Connect(function(isActive)
        --print("Ragdoll: ", isActive)
    end)
     
    humanoid.Running:Connect(function(speed)
        --print("Running speed: ", speed)
        self:SwimToggle(player, false)
    end)
     
    humanoid.Strafing:Connect(function(isActive)
        --print("Strafing: ", isActive)
    end)
     
    humanoid.Swimming:Connect(function(speed)
        --print("Swimming speed: ", speed)
        self:SwimToggle(player, true)
    end)

    ]]--

end

--// swim check
function PlayerUtilityService:SwimToggle(player, boolean)

    PlayerUtilityService.PlayerSwimStates[player.userId] = boolean
    if boolean == true then
        Knit.Services.PowersService:ForceRemoveStand(player)
        spawn(function()
            while PlayerUtilityService.PlayerSwimStates[player.userId] == true do
                require(Knit.PowerUtils.BlockInput).AddBlock(player.UserId, "Swimming", 2)
                player.Character.Humanoid:TakeDamage(5)
                wait(1)
            end
        end)
    end
end

--// PlayerAdded
function PlayerUtilityService:PlayerAdded(player)

    -- wait for the character
    repeat wait() until player.Character
    
    -- setup the ping tracker
    local pingFolder = ReplicatedStorage:FindFirstChild("PlayerPings")
    if not pingFolder then
        pingFolder = Instance.new("Folder")
        pingFolder.Name = "PlayerPings"
        pingFolder.Parent = ReplicatedStorage
    end
    local playerValue = Instance.new("NumberValue")
    playerValue.Name = player.UserId
    playerValue.Parent = pingFolder
    playerValue.Value = 0

    -- load animations
    self:LoadAnimations(player)

    -- run humanoid state detectors
    self:HumanoidStateEvents(player)

    -- add player to PlayerSwimStates table
    PlayerUtilityService.PlayerSwimStates[player.userId] = false

end

--// PlayerRemoved
function PlayerUtilityService:PlayerRemoved(player)

    ReplicatedStorage.PlayerPings[player.UserId]:Destroy()
    PlayerUtilityService.PlayerAnimations[player.UserId] = nil
    PlayerUtilityService.PlayerSwimStates[player.userId] = nil
end

--// CharacterAdded
function PlayerUtilityService:CharacterAdded(player)

    -- wait for the character
    repeat wait() until player.Character
    
    self:LoadAnimations(player)

end


--// KnitStart
function PlayerUtilityService:KnitStart()

        -- start the loop
        self:UpdatePingLoop()

        -- Player Added event
        Players.PlayerAdded:Connect(function(player)
            self:PlayerAdded(player)

            player.CharacterAdded:Connect(function(character)
                self:CharacterAdded(player)
        
                character:WaitForChild("Humanoid").Died:Connect(function()
                    -- empty for now
                end)
            end)
        end)
    
        -- Player Added event for studio tesing, catches when a player has joined before the server fully starts
        for _, player in ipairs(Players:GetPlayers()) do
            self:PlayerAdded(player)

            player.CharacterAdded:Connect(function(character)
                self:CharacterAdded(player)
        
                character:WaitForChild("Humanoid").Died:Connect(function()
                    -- empty for now
                end)
            end)
        end
    
        -- Player Removing event
        Players.PlayerRemoving:Connect(function(player)
            self:PlayerRemoved(player)
        end)

end

--// KnitInit
function PlayerUtilityService:KnitInit()

    -- setup the pings folder
    local pingFolder = Instance.new("Folder")
    pingFolder.Name = "PlayerPings"
    pingFolder.Parent = ReplicatedStorage

end


return PlayerUtilityService