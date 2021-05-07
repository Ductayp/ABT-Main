-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local CutSceneService = Knit.CreateService { Name = "CutSceneService", Client = {}}
local RemoteEvent = require(Knit.Util.Remote.RemoteEvent)

-- modules
local utils = require(Knit.Shared.Utils)

-- events
CutSceneService.Client.Event_LoadScene = RemoteEvent.new()

--// LoadScene_SinglePlayer
function CutSceneService:LoadScene_SinglePlayer(player, params)

    --print("CUTSCENE SERVICE", player, params)

    local findModule = Knit.CutScenes:FindFirstChild(params.SceneName)
    if not findModule then return end

    params.TargetPlayer = player
    params.CanRun = false
    local functionName = "Server_" .. params.Stage
    local params = require(findModule)[functionName](params)

    if params.CanRun == true then
        self.Client.Event_LoadScene:Fire(player, params)
    end

end

--// LoadScene_AllPlayers
function CutSceneService:LoadScene_AllPlayers(params)

    local findModule = Knit.CutScenes:FindFirstChild(params.SceneName)
    if not findModule then return end

    params.CanRun = false
    local functionName = "Server_" .. params.Stage
    local params = require(findModule)[functionName](params)

    if params.CanRun == true then
        self.Client.Event_LoadScene:FireAll(params)
    end

end

---------------------------------------------------------------------------------------------
--// CLIENT METHODS
---------------------------------------------------------------------------------------------

--// Client:LoadScene_SinglePlayer
function CutSceneService.Client:LoadScene_SinglePlayer(player, params)
    self.Server:LoadScene_SinglePlayer(player, params)
end

--// Client:LoadScene_AllPlayers
function CutSceneService.Client:LoadScene_AllPlayers(player, params)
    self.Server:LoadScene_AllPlayers(player)
end

---------------------------------------------------------------------------------------------
--// PLAYER/CHARACTER EVENTS
---------------------------------------------------------------------------------------------


--// PlayerAdded
function CutSceneService:PlayerAdded(player)

    -- wait for the character
    repeat wait() until player.Character
    self:CharacterAdded(player)

end

--// PlayerRemoved
function CutSceneService:PlayerRemoved(player)

end

--// CharacterAdded
function CutSceneService:CharacterAdded(player)

    -- wait for the character
    repeat wait() until player.Character
    
end

--// CharacterDied
function CutSceneService:CharacterDied(player)
    --print("PLAYER DIED:", player)
end

---------------------------------------------------------------------------------------------
--// KNIT
---------------------------------------------------------------------------------------------


--// KnitStart
function CutSceneService:KnitStart()

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
function CutSceneService:KnitInit()

end


return CutSceneService