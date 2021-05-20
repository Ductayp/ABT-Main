-- Invulnerable

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local Invulnerable = {}

function Invulnerable.Server_ApplyEffect(initPlayer, hitCharacter, params)

    if not hitCharacter then return end
    if not hitCharacter:FindFirstChild("HumanoidRootPart") then return end

    local newBool = Instance.new("BoolValue")
    newBool.Value = true
    newBool.Name = "Invulnerable_HitEffect"
    newBool.Parent = hitCharacter.HumanoidRootPart

    spawn(function()
        wait(params.Duration)
        newBool:Destroy()
    end)


end

function Invulnerable.Client_RenderEffect(params)


end


return Invulnerable