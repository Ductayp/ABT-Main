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

-- local variables
local pingUpdateTime = 1


function PlayerUtilityService:GetPing(player)
    return pingTime[player]
end


--// UpdatePingLoop
function PlayerUtilityService:UpdatePingLoop()

    spawn(function()
        while true do
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

end

--// PlayerRemoved
function PlayerUtilityService:PlayerRemoved(player)

    ReplicatedStorage.PlayerPings[player.UserId]:Destroy()
    PlayerUtilityService.PlayerAnimations[player.UserId] = nil
end

--// CharacterAdded
function PlayerUtilityService:CharacterAdded(player)

    print(" PlayerUtilityService:CharacterAdded")

    -- wait for the character
    repeat wait() until player.Character
    
    self:LoadAnimations(player)

end

function PlayerUtilityService:LoadAnimations(player)

    -- clear the players animation table so its fresh
    PlayerUtilityService.PlayerAnimations[player.UserId] = {}

    -- load the players animation table with tracks
    local animator = player.Character.Humanoid:WaitForChild("Animator")
    for _,animObject in pairs(ReplicatedStorage.PlayerAnimations:GetChildren()) do
        PlayerUtilityService.PlayerAnimations[player.UserId][animObject.Name] = animator:LoadAnimation(animObject)
    end

    print("ANIMATION TABLE!: ",PlayerUtilityService.PlayerAnimations)
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