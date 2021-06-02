-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local StarterPlayer = game:GetService("StarterPlayer")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local PlayerUtilityService = Knit.CreateService { Name = "PlayerUtilityService", Client = {}}
local RemoteEvent = require(Knit.Util.Remote.RemoteEvent)

-- events
PlayerUtilityService.Client.Event_PlayerUtility = RemoteEvent.new()

-- modules
local pingTime = require(Knit.Shared.PingTime)
local utils = require(Knit.Shared.Utils)

-- public variables
PlayerUtilityService.PlayerAnimations = {}
PlayerUtilityService.PlayerRegenStatus = {}
PlayerUtilityService.PlayerDamageStatus = {}
PlayerUtilityService.PlayerMapZone = {}


-- local variables
local updatePlayerTime = 1

local regenProfiles = {}
regenProfiles.Default = {Day = 1, Night = 1}
regenProfiles.Vampire = {Day = 0, Night = 1}

local damageProfiles = {}
damageProfiles.Default = {Day = 0, Night = 0}
damageProfiles.VampiricRage = {Day = -2, Night = -2}

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

                local healthFactor = 0

                local regenDef = PlayerUtilityService.PlayerRegenStatus[player.UserId]
                if regenDef then
                    --print("REGEN", regenDef)
                    local profile = regenProfiles[regenDef.Profile]
                    if regenDef.Enabled then
                        if Knit.Services.EnvironmentService.CurrentCycle == "Day" then
                            
                            healthFactor += profile.Day
                        else
                            healthFactor += profile.Night
                        end
                    end
                end


                local damageDef = PlayerUtilityService.PlayerDamageStatus[player.UserId]
                if damageDef then
                    --print("DAMAGE", damageDef)
                    local profile = damageProfiles[damageDef.Profile]
                    if damageDef.Enabled then
                        if Knit.Services.EnvironmentService.CurrentCycle == "Day" then
                            healthFactor += profile.Day
                        else
                            healthFactor += profile.Night
                        end
                    end
                end

                local character = player.Character
                if character and character.Humanoid then
                    character.Humanoid.Health += healthFactor
                end
            end

            wait(updatePlayerTime)
        end
    end) 
end

function PlayerUtilityService:SetRegenStatus(player, params)

    if not player or not params then return end

    repeat wait() until PlayerUtilityService.PlayerRegenStatus[player.UserId] ~= nil
    PlayerUtilityService.PlayerRegenStatus[player.UserId] = params

    --print("SetRegenStatus 1", params)
    --print("SetRegenStatus 2", PlayerUtilityService.PlayerRegenStatus[player.UserId])

end


function PlayerUtilityService:SetDamageStatus(player, params)

    if not player or not params then return end
    PlayerUtilityService.PlayerDamageStatus[player.UserId] = params

end

function PlayerUtilityService:SetPlayerMapZone(player, params)

    if not player or not params then return end
    print(player, params)
    PlayerUtilityService.PlayerMapZone[player.UserId] = params.MapZone

end

function PlayerUtilityService:GetPlayerMapZone(player)

    local playerMapZone = PlayerUtilityService.PlayerMapZone[player.UserId]
    return playerMapZone

end

function PlayerUtilityService:GetPlayersInMapZone(mapZone)

    local playersInZone = {}
    for userId, currentMapZone in pairs(PlayerUtilityService.PlayerMapZone) do
        if currentMapZone == mapZone then
            local player = utils.GetPlayerByUserId(userId)
            if not player then return end
            table.insert(playersInZone, player)
        end
    end

    return playersInZone

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

--------------------------------------------------------------------------------------------------------------------------
--// CLIENT METHODS ---------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------

function PlayerUtilityService.Client:GetPlayerMapZone(player)
    local playerMapZone = self.Server:GetPlayerMapZone(player)
    return playerMapZone
end

--------------------------------------------------------------------------------------------------------------------------
--// PLAYER EVENTS ---------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------

--// PlayerAdded
function PlayerUtilityService:PlayerAdded(player)

    PlayerUtilityService.PlayerRegenStatus[player.UserId] = {Enabled = true, Profile = "Default"}
    self:SetPlayerMapZone(player, {MapZone = "Morioh"})

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

end

--// PlayerRemoved
function PlayerUtilityService:PlayerRemoved(player)
    ReplicatedStorage.PlayerPings[player.UserId]:Destroy()
    PlayerUtilityService.PlayerAnimations[player.UserId] = nil
    PlayerUtilityService.PlayerRegenStatus[player.UserId] = nil
    PlayerUtilityService.PlayerDamageStatus[player.UserId] = nil
    PlayerUtilityService.PlayerMapZone[player.UserId] = nil
end

--// CharacterAdded
function PlayerUtilityService:CharacterAdded(player)

    -- wait for the character
    repeat wait() until player.Character
    PlayerUtilityService.PlayerDamageStatus[player.UserId] = {Enabled = true, Profile = "Default"}

    self:LoadAnimations(player)

end

--// CharacterDied
function PlayerUtilityService:CharacterDied(player)
    --print("PLAYER DIED:", player)
end

--------------------------------------------------------------------------------------------------------------------------
--// KNIT ---------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------

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