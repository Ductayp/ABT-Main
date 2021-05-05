-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local StarterPlayer = game:GetService("StarterPlayer")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local PlayerUtilityService = Knit.CreateService { Name = "PlayerUtilityService", Client = {}}
local RemoteEvent = require(Knit.Util.Remote.RemoteEvent)

-- modules
local pingTime = require(Knit.Shared.PingTime)
local utils = require(Knit.Shared.Utils)

-- public variables
PlayerUtilityService.PlayerAnimations = {}
PlayerUtilityService.PlayerHealthStatus = {}

-- local variables
local updatePlayerTime = 1
local defautHealthValues = {Enabled = true, RegenDay = 2, RegenNight = 2}

function PlayerUtilityService:GetPing(player)
    return pingTime[player]
end

--// UpdatePlayerLoop
function PlayerUtilityService:UpdatePlayerLoop()

    spawn(function()
        while game:GetService("RunService").Heartbeat:Wait() do

            for _,player in pairs(Players:GetPlayers()) do

                if ReplicatedStorage.PlayerPings:FindFirstChild(player.UserId) then
                    ReplicatedStorage.PlayerPings[player.UserId].Value = pingTime[player]
                    --print("PING: ",player.Name, pingTime[player])
                end

                local playerHealthDef = PlayerUtilityService.PlayerHealthStatus[player.UserId]
                local healthDef
                if playerHealthDef then
                    healthDef = PlayerUtilityService.PlayerHealthStatus[player.UserId]
                else
                    healthDef = defautHealthValues
                end

                local character = player.Character
                if character and character.Humanoid then
                    if Knit.Services.EnvironmentService.CurrentCycle == "Day" then
                        character.Humanoid.Health += healthDef.RegenDay
                        --print("regen day: ", healthDef.RegenDay, Knit.Services.EnvironmentService.CurrentCycle)
                    else
                        character.Humanoid.Health += healthDef.RegenNight
                        --print("regen night: ", healthDef.RegenNight, Knit.Services.EnvironmentService.CurrentCycle)
                    end
                end
            end

            wait(updatePlayerTime)
        end
    end) 
end

function PlayerUtilityService:SetHealthStatus(player, params)

    if not player or not params then return end

    if params.DefaultValues then
        PlayerUtilityService.PlayerHealthStatus[player.UserId] = defautHealthValues
    else
        PlayerUtilityService.PlayerHealthStatus[player.UserId] = params
    end

end

function PlayerUtilityService:ToggleRegen(player, bool)

    if not player or not bool then return end

    if PlayerUtilityService.PlayerHealthStatus[player.UserId] == nil then
        PlayerUtilityService.PlayerHealthStatus[player.UserId] = defautHealthValues
    end

    PlayerUtilityService.PlayerHealthStatus[player.UserId].Enabled = bool

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

--// PlayerAdded
function PlayerUtilityService:PlayerAdded(player)

    -- wait for the character
    repeat wait() until player.Character
    self:CharacterAdded(player)
    
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

    -- health regen setup
    --print("DEFAULT REGEN")
    --PlayerUtilityService.PlayerHealthStatus[player.UserId] = {}

end

--// PlayerRemoved
function PlayerUtilityService:PlayerRemoved(player)
    ReplicatedStorage.PlayerPings[player.UserId]:Destroy()
    PlayerUtilityService.PlayerAnimations[player.UserId] = nil
    PlayerUtilityService.PlayerHealthStatus[player.UserId] = nil
end

--// CharacterAdded
function PlayerUtilityService:CharacterAdded(player)

    -- wait for the character
    repeat wait() until player.Character
    
    self:LoadAnimations(player)

end

--// CharacterDied
function PlayerUtilityService:CharacterDied(player)
    --print("PLAYER DIED:", player)
end


--// KnitStart
function PlayerUtilityService:KnitStart()

    -- start the loop
    self:UpdatePlayerLoop()

    -- Player Added event
    Players.PlayerAdded:Connect(function(player)
        self:PlayerAdded(player)

        player.CharacterAdded:Connect(function(character)
            self:CharacterAdded(player)
    
            character:WaitForChild("Humanoid").Died:Connect(function()
                --self:CharacterDied(player)
            end)
        end)
    end)

    -- Player Added event for studio tesing, catches when a player has joined before the server fully starts
    for _, player in ipairs(Players:GetPlayers()) do
        self:PlayerAdded(player)

        player.CharacterAdded:Connect(function(character)
            self:CharacterAdded(player)
    
            character:WaitForChild("Humanoid").Died:Connect(function()
                --self:CharacterDied(player)
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

    local healthScript = script:FindFirstChild("Health")
    if healthScript then
        healthScript.Parent = StarterPlayer.StarterCharacterScripts
    end

end

return PlayerUtilityService