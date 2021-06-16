-- PlayerUtilityController

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local PlayerUtilityController = Knit.CreateController { Name = "PlayerUtilityController" }
local PlayerUtilityService = Knit.GetService("PlayerUtilityService")
local pingTime = require(Knit.Shared.PingTime)
local utils = require(Knit.Shared.Utils)

PlayerUtilityController.PlayerAnimations = {} -- PLayerUtilityService populates a players entries everyt ime it loads animations

--// GetPing - gets the local players ping
function PlayerUtilityController:GetPing()

    local ping = 0 

    local playerValueObject = ReplicatedStorage.PlayerPings[Players.LocalPlayer.UserId]
    if playerValueObject then 
        ping = playerValueObject.Value
    end

    return ping

end

--// LoadAnimations
function PlayerUtilityController:LoadAnimations(character)

    if not character then return end

    -- clear the players animation table so its fresh
    PlayerUtilityController.PlayerAnimations = {}

    -- load the players animation table with tracks
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end

    local animator = character.Humanoid:WaitForChild("Animator", 5)
    if not animator then return end

    for _,animObject in pairs(ReplicatedStorage.PlayerAnimations:GetChildren()) do
        PlayerUtilityController.PlayerAnimations[animObject.Name] = animator:LoadAnimation(animObject)
    end

end

function PlayerUtilityController:CharacterAdded(character)

    self:LoadAnimations(character)
end


function PlayerUtilityController:KnitStart()
    Players.LocalPlayer.CameraMaxZoomDistance = 30

    local character = Players.LocalPlayer.Character
    if not character or not character.Parent then
        character = Players.LocalPlayer.CharacterAdded:wait()
    end

    self:CharacterAdded(character)

    Players.LocalPlayer.CharacterAdded:Connect(function(character)
        self:CharacterAdded(player)
    end)

    
end

function PlayerUtilityController:KnitInit()

    PlayerUtilityService.Event_PlayerUtility:Connect(function(animationsTable, two)
        -- empty remote event
    end)

end

return PlayerUtilityController