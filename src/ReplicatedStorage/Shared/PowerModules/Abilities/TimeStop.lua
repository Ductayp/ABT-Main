-- Time Stop
-- PDab
-- 11/25/2020

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService('Players')

-- Knits and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
--local powerUtils = require(Knit.Shared.PowerUtils)

-- Effect modules
--local PinCharacter = require(Knit.Effects.PinCharacter)
--local ColorShift = require(Knit.Effects.ColorShift)
--local BlockInput = require(Knit.Effects.BlockInput)

local TimeStop = {}

--// ACTIVATE ----------------------------------
function TimeStop.Activate(initPlayer,params)

    -- run delay, this makes room for the animation
    if params.TimeStop.Delay ~= nil then
        wait(params.TimeStop.Delay)
    end

    -- hit players
    -- put all player within range inside a table, including the initPlayer
    local affectedPlayers = {}
    for _, targetPlayer in pairs(game.Players:GetPlayers()) do
        if targetPlayer:DistanceFromCharacter(initPlayer.Character.Head.Position) < params.TimeStop.Range then
            affectedPlayers[targetPlayer] = true
        end
    end

    -- play effects for all player within range, this happens before immunities
    for player,_ in pairs(affectedPlayers) do
        require(Knit.Effects["ColorShift"]).Server_ApplyEffect(player.Character,params.TimeStop.HitEffects.ColorShift)
    end

    -- remove any player that is immune to timestop
    for player,_ in pairs(affectedPlayers) do

        local isImmune = require(Knit.StateModules.Immunity).Has_Immunity(player,"TimeStop")
        if isImmune then
            affectedPlayers[player] = nil -- commnet this out to run it immune players (for testing only)
        end
    end
    
--[[
    -- run effects on players still in the affectedPlayers table
    for player,_ in pairs(affectedPlayers) do

        for effect,thisParams in pairs(params.TimeStop.HitEffects) do
            if effect ~= "ColorShift" then -- we already did colorshift for everyone in range
                local characterHit = player.Character
                Knit.Services.PowersService:RegisterHit(initPlayer,characterHit,thisParams)
            end
        end
    end
]]--

end

--// EXECUTE ----------------------------------
function TimeStop.Execute(initPlayer,params)

    -- animate spehres
    local sphereParams = {}
    sphereParams.CFrame = initPlayer.Character.HumanoidRootPart.CFrame
    sphereParams.Size = Vector3.new(1,1,1)
    sphereParams.Shape = "Ball"
    sphereParams.Parent = workspace.RenderedEffects
    sphereParams.Anchored = true
    sphereParams.CanCollide = false
    sphereParams.Transparency = -.5
    sphereParams.Material = Enum.Material.ForceField
    sphereParams.CastShadow = false

    local sphere1 = utils.EasyInstance("Part",sphereParams)
    local sphere2 = utils.EasyInstance("Part",sphereParams)
    local sphere3 = utils.EasyInstance("Part",sphereParams)

    sphere1.Color = Color3.new(255, 7, 160)
    sphere2.Color = Color3.new(2, 243, 255)
    sphere3.Color = Color3.new(255, 255, 2)
    
    Debris:AddItem(sphere1,params.Duration)
    Debris:AddItem(sphere2,params.Duration)
    Debris:AddItem(sphere3,params.Duration)

    spawn(function()
        local size = params.Range * 2

        local tweenInfo = TweenInfo.new(
            1, -- Time
            Enum.EasingStyle.Linear, -- EasingStyle
            Enum.EasingDirection.In -- EasingDirection
        )

        local sphereTween1 = TweenService:Create(sphere1,tweenInfo,{Size = Vector3.new(size,size,size)})
        local sphereTween2 = TweenService:Create(sphere2,tweenInfo,{Size = Vector3.new(size,size,size)})
        local sphereTween3 = TweenService:Create(sphere3,tweenInfo,{Size = Vector3.new(size,size,size)})
        sphereTween1:Play()
        wait(.005)
        sphereTween2:Play()
        wait(.005)
        sphereTween3:Play()

        wait(2)

        local tweenInfo = TweenInfo.new(
            .25, -- Time
            Enum.EasingStyle.Linear, -- EasingStyle
            Enum.EasingDirection.Out -- EasingDirection
        )

        local sphereTween4 = TweenService:Create(sphere1,tweenInfo,{Size = Vector3.new(1,1,1)})
        local sphereTween5 = TweenService:Create(sphere2,tweenInfo,{Size = Vector3.new(1,1,1)})
        local sphereTween6 = TweenService:Create(sphere3,tweenInfo,{Size = Vector3.new(1,1,1)})

        sphereTween6.Completed:Connect(function(playbackState)
            if playbackState == Enum.PlaybackState.Completed then
                sphere1:Destroy()
                sphere2:Destroy()
                sphere3:Destroy()
            end
        end)


        sphereTween4:Play()
        wait(.005)
        sphereTween5:Play()
        wait(.005)
        sphereTween6:Play()
    end)
end


return TimeStop