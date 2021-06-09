-- Teleport

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local Teleport = {}

function Teleport.Server_ApplyEffect(initPlayer, hitCharacter, effectParams, hitParams)

    if not hitCharacter then return end
    if not hitCharacter:FindFirstChild("HumanoidRootPart") then return end

    local antiTeleport = hitCharacter:FindFirstChild("DisableTeleport", true)
    if antiTeleport then return end

    hitCharacter.HumanoidRootPart.CFrame = CFrame.new(effectParams.TargetPosition)


    --[[
    local hitPlayer = utils.GetPlayerFromCharacter(hitCharacter)
    if hitParams.IsMob then

        local orginalParent = hitCharacter.Parent
        if orginalParent == ReplicatedStorage then return end

        --hitCharacter.Parent = ReplicatedStorage
        --hitCharacter.HumanoidRootPart.Position = effectParams.TargetPosition
        hitCharacter.HumanoidRootPart.CFrame = CFrame.new(effectParams.TargetPosition)
        --hitCharacter.Parent = orginalParent

    else
        --hitCharacter.HumanoidRootPart.Position = effectParams.TargetPosition
        hitCharacter.HumanoidRootPart.CFrame = CFrame.new(effectParams.TargetPosition)
    end
    ]]--


end

function Teleport.Client_RenderEffect(params)


end


return Teleport