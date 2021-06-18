-- Pull

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local Pull = {}

function Pull.Server_ApplyEffect(initPlayer, hitCharacter, effectParams, hitParams)

    -- just a final check to be sure were hitting a humanoid
    if  not hitCharacter:FindFirstChild("Humanoid") then return end

    local canPull = false
    if hitParams.IsMob then
        local thisMob = Knit.Services.MobService:GetMobById(hitParams.MobId)
        if thisMob and thisMob.Defs.IsMobile then
            canPull = true
        end
    else
        canPull = true
    end

    local notPulled = true
    local oldPosition = hitCharacter:FindFirstChild("PullEffect_BodyPosition", true)
    if oldPosition then
        notPulled = false
    end

    if canPull and notPulled then

        -- add the body mover
        local newBodyPosition = Instance.new("BodyPosition")
        newBodyPosition.MaxForce = Vector3.new(500000,500000,500000)
        newBodyPosition.P = effectParams.Force
        newBodyPosition.Position = effectParams.Position
        newBodyPosition.Parent = hitCharacter.HumanoidRootPart
        newBodyPosition.Name = "PullEffect_BodyPosition"

        if effectParams.Duration then
            spawn(function()
                wait(effectParams.Duration)
                newBodyPosition:Destroy()
            end)
        end
        
        -- send the visual effects to all clients
        effectParams.HitCharacter = hitCharacter
        Knit.Services.PowersService:RenderHitEffect_AllPlayers("Pull", effectParams)
    end

end

function Pull.Client_RenderEffect(effectParams)


end


return Pull