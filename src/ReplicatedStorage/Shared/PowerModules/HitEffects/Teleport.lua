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

    --hitCharacter.HumanoidRootPart.CFrame = CFrame.new(effectParams.TargetPosition)

    if hitParams.IsMob then

        local thisMob = Knit.Services.MobService:GetMobById(hitParams.MobId)
        print("IS MOB!", thisMob)

        if thisMob and thisMob.Defs.IsMobile then
            hitCharacter.HumanoidRootPart.CFrame = CFrame.new(effectParams.TargetPosition)
        end
        
    else

        hitCharacter.HumanoidRootPart.CFrame = CFrame.new(effectParams.TargetPosition)
    end



end

function Teleport.Client_RenderEffect(params)


end


return Teleport