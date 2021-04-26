-- CameraMove

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local CameraMove = {}

--// Server_ApplyEffect
function CameraMove.Server_ApplyEffect(initPlayer, hitCharacter, effectParams, hitParams)

    local player = utils.GetPlayerFromCharacter(hitCharacter)
    if player then
        Knit.Services.PowersService:RenderHitEffect_SinglePlayer(player, "CameraMove", effectParams)
    end
end

--// Client_RenderEffect
function CameraMove.Client_RenderEffect(params)

    player = Players.LocalPlayer

    local camera = Workspace.CurrentCamera
    local originalSubject = camera.CameraSubject
    camera.CameraSubject = params.TargetPart
    wait(params.Duration)

    repeat wait() until player.Character
    camera.CameraSubject = player.Character.Humanoid

end

return CameraMove