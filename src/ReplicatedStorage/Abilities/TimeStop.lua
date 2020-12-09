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
local powerUtils = require(Knit.Shared.PowerUtils)

local TimeStop = {}

--// Server Functions ----------------------------------

function TimeStop.Server_RunTimeStop(initPlayer,params,timeStopParams)

    -- setup a table for all players affected by Time Stop
    params.StoppedPlayers = {}

    for _, targetPlayer in pairs(game.Players:GetPlayers()) do


        if targetPlayer ~= initPlayer then
            if targetPlayer:DistanceFromCharacter(initPlayer.Character.Head.Position) < timeStopParams.Range then

                print("distance is: ",targetPlayer:DistanceFromCharacter(initPlayer.Character.Head.Position))
                print("range is: ",timeStopParams.Range)

                -- get the targetPlayers current power and check if they have immunity to TimeStop
                local canTimeStop = false
                local playerData = Knit.Services.PlayerDataService:GetPlayerData(targetPlayer)

                local powerModule
                local findModule = Knit.Powers:FindFirstChild(playerData.Character.CurrentPower)
                if findModule then
                    powerModule = require(Knit.Powers[playerData.Character.CurrentPower])
                else
                    print("power doesnt exist")
                    return
                end

                if powerModule.Defs.Immunities then
                    if not powerModule.Defs.Immunities.TimeStop then
                        canTimeStop = true
                    end
                else
                    canTimeStop = true
                end
                
                print(canTimeStop)
                -- if they are not immune, run the rest
                if canTimeStop == true then

                    -- insert into table in params to list the targetPlayer who have been stopped
                    table.insert(params.StoppedPlayers,targetPlayer)
                    
                    spawn(function()
                        
                        if timeStopParams.Delay ~= nil then
                            wait(timeStopParams.Delay)
                        end

                        -- anchor the targetPlayer
                        for _,part in pairs(targetPlayer.Character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.Anchored = true
                            end
                        end
                        
                        -- block input
                        local inputBlockedBool = powerUtils.SetInputBlock(targetPlayer,{Name = "TimeStop"})

                        
                        -- wait and then restore the targetPlayer

                            wait(timeStopParams.Duration)

                            -- un-anchor the targetPlayer
                            for _,part in pairs(targetPlayer.Character:GetChildren()) do
                                if part:IsA("BasePart") then
                                    part.Anchored = false
                                end
                            end

                            -- un-block input
                            inputBlockedBool:Destroy()
                    end)
                end
            end
        end
    end
    table.insert(params.StoppedPlayers,initPlayer) -- add the initPlayer so they see the effects
    return params
end

function TimeStop.Client_RunTimeStop(initPlayer,params,timeStopParams)

    --[[
    -- Effects in here will play for everyone affected EXCEPT the initPlayer
    if params.StoppedPlayers then
        for _,userId in pairs(params.StoppedPlayers) do -- iterate through list of StoppedPlayers
            for _, player in pairs(Players:GetPlayers()) do -- interate through list of players in game
                if player.UserId == userId then -- see if the player.UserId matched a SuserId in the StoppedPlayers table
                    if player == Players.LocalPlayer then -- if we get a match, only run this effect if the script is being run by the matchign player
                        -- nothing here right now            
                    end
                end
            end
        end
    end
    ]]--

    -- Effects in here will play for EVERYONE on the hit player list. imnc;uding the initPlayer
    if params.StoppedPlayers then
        for _,stoppedPlayer in pairs(params.StoppedPlayers) do -- iterate through list of StoppedPlayers
            for _, player in pairs(Players:GetPlayers()) do -- interate through list of players in game
                if player == stoppedPlayer or player == Players.LocalPlayer then -- see if the player.UserId matched a SuserId in the StoppedPlayers table
                    --print
                    -- change the ColorCorrection
                    local originalColorCorrection = Lighting:FindFirstChild("ColorCorrection")
                    local newColorCorrection = originalColorCorrection:Clone()  
                    newColorCorrection.Parent = Lighting


                    local colorTween1 = TweenService:Create(newColorCorrection,TweenInfo.new(.5),{Contrast = -3})
                    colorTween1:Play()

                    originalColorCorrection.Enabled = false

                    spawn(function()
                        wait(timeStopParams.Duration)
                        local colorTween2 = TweenService:Create(newColorCorrection,TweenInfo.new(.5),{Contrast = originalColorCorrection.Contrast})
                        colorTween2:Play()
                        wait(3)
                        originalColorCorrection.Enabled = true
                        newColorCorrection:Destroy()
                    end)
                    
                end
            end
        end
    end

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
    
    Debris:AddItem(sphere1,timeStopParams.Duration)
    Debris:AddItem(sphere2,timeStopParams.Duration)
    Debris:AddItem(sphere3,timeStopParams.Duration)

    spawn(function()
        local size = timeStopParams.Range * 2

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