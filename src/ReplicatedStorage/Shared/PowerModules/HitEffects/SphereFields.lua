-- Sphere Cage Effect
-- PDab
-- 12-4-2020

--[[    
        applies a simple bubble around the character

        required params:
        params.Duration 
        params.Size

        optional params:
        params.sphereProperties
        accepts modifications to the deault sphere Properties by setting key,value pairs for each in params.sphereProperties
]]--


--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local colors = {
    [1] = Color3.new(255/255, 0/255, 191/255), -- hot pink
    [2] = Color3.new(9/255, 137/255, 207/255), -- electric blue
    [3] = Color3.new(0/255, 255/255, 0/255), -- lime green
    [4] = Color3.new(255/255, 0/255, 0/255), -- really red
    [5] = Color3.new(255/255, 255/255, 0/255), -- new yeller
    [6] = Color3.new(0/255, 0/255, 255/255) -- really blue
}


local SphereFields = {}

function SphereFields.Server_ApplyEffect(initPlayer,hitCharacter, params)

    params.HitCharacter = hitCharacter
    Knit.Services.PowersService:RenderHitEffect_AllPlayers("SphereFields",params)

end

function SphereFields.Client_RenderEffect(params)

    local sphereCount = 1
    if params.Repeat then
            sphereCount = params.Repeat
    end

    for count = 1, sphereCount do
        spawn(function()

            -- make the sphere
            local thisSphere = Instance.new("Part")
            thisSphere.Shape = "Ball"

            -- default settings
            thisSphere.Size = Vector3.new(1,1,1)
            thisSphere.Parent = params.HitCharacter --workspace.RenderedEffects
            thisSphere.CanCollide = false
            thisSphere.Anchored = false
            thisSphere.Material = Enum.Material.ForceField
            thisSphere.Transparency = -.5
            thisSphere.Color = Color3.new(1, 1, 1)
            thisSphere.CFrame = params.HitCharacter.UpperTorso.CFrame

            -- set color random if param is true
            if params.RandomColor then
                --local colorNumber = math.random(1,6)
                local pickedColor = colors[math.random(1,6)]
                thisSphere.Color = pickedColor
            end

            -- set any custom properties
            if params.sphereProperties then
                for key,value in pairs(params.sphereProperties) do 
                    thisSphere[key] = value
                end
            end

            -- weld it to the character
            utils.EasyWeld(thisSphere,params.HitCharacter.HumanoidRootPart,thisSphere)

            -- setup tweens
            local tweenSpeed = .25 -- default tween speed, can be set in params too
            if params.TweenSpeed then
                tweenSpeed = params.TweenSpeed
            end
            local tweenInfo = TweenInfo.new(tweenSpeed) -- grow and shrink speed
            local sphereGrow = TweenService:Create(thisSphere,tweenInfo,{Size = Vector3.new(params.Size,params.Size,params.Size)})
            local sphereShrink = TweenService:Create(thisSphere,tweenInfo,{Size = Vector3.new(.1,.1,.1)})

            sphereShrink.Completed:Connect(function(playbackState)
                if playbackState == Enum.PlaybackState.Completed then
                    thisSphere:Destroy()
                end
            end)

            sphereGrow:Play()
            wait(params.Duration + 0.5)
            sphereShrink:Play()
        
        end)

        wait(0.1) -- delay between spheres
    end
end


return SphereFields