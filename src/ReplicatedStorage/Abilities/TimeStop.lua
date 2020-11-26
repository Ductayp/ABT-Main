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

    for _, targetPlayer in pairs(game.Players:GetPlayers()) do

        print(targetPlayer:DistanceFromCharacter(initPlayer.Character.Head.Position))
        print("targetPlayer: ",targetPlayer)
        print("initPlayer: ",initPlayer)

        if targetPlayer ~= initPlayer then
            if targetPlayer:DistanceFromCharacter(initPlayer.Character.Head.Position) < timeStopParams.Range then

                -- setup a table in params to list the targetPlayer who have been stopped
                params.StoppedPlayers = {}

                -- get the players current power and check if they have immunity to TimeStop
                local canTimeStop = false
                local playerData = Knit.Services.PlayerDataService:GetPlayerData(targetPlayer)
                local powerModule = require(Knit.Powers[playerData.Character.CurrentPower])
                if powerModule.Defs.Immunities then
                    if not powerModule.Defs.Immunities.TimeStop then
                        canTimeStop = true
                    end
                else
                    canTimeStop = true
                end
                

                -- if they are not immune, run the rest
                if canTimeStop == true then
    
                    table.insert(params.StoppedPlayers,targetPlayer.UserId)
                    
                    spawn(function()
    
                        -- anchor the targetPlayer
                        for _,part in pairs(targetPlayer.Character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.Anchored = true
                            end
                        end
                        
                        -- block input
                        local inputBlockedBool = powerUtils.SetInputBlock(targetPlayer,{Name = "TimeStop"})

                        
                        -- spawn the wait and then restore the targetPlayer
                        spawn(function()
    
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
                    end)
                end
            end
        end
    end
    return params
end

function TimeStop.Client_RunTimeStop(initPlayer,params,timeStopParams)
print("Client - TimeStopModule RUN")
    -- get the LocalPlayer and if it is in the list of stopped player, do special effects
    if params.StoppedPlayers then
        for _,userId in pairs(params.StoppedPlayers) do -- iterate through list of StoppedPlayers
            for _, player in pairs(Players:GetPlayers()) do -- interate through list of players in game
                if player.UserId == userId then -- see if the player.UserId matched a SuserId in the StoppedPlayers table
                    if player == Players.LocalPlayer then -- if we get a match, only run this effect if the script is being run by the matchign player

                        -- change the ColorCorrection
                        local originalColorCorrection = Lighting:FindFirstChild("ColorCorrection")
                        local newColorCorrection = originalColorCorrection:Clone()  
                        newColorCorrection.Parent = Lighting

                        --local tween1 = TweenService:Create(newColorCorrection,TweenInfo.new(1),{TintColor = Color3.new(248/255, 28/255, 255/255)})
                        local tween2 = TweenService:Create(newColorCorrection,TweenInfo.new(.5),{Contrast = -3})
                        --tween1:Play()
                        tween2:Play()

                        originalColorCorrection.Enabled = false

                        spawn(function()
                            wait(timeStopParams.Duration)
                            
                            local tween1 = TweenService:Create(newColorCorrection,TweenInfo.new(1),{TintColor = originalColorCorrection.TintColor})
                            local tween2 = TweenService:Create(newColorCorrection,TweenInfo.new(.5),{Contrast = originalColorCorrection.Contrast})
                            tween1:Play()
                            tween2:Play()

                            wait(3)
                            originalColorCorrection.Enabled = true
                            newColorCorrection:Destroy()
                            
                        end)
                    
                    end
                end
            end
        end
    end
    
    --local sphere1 = utils.EasyInstance("Sphere",{Size = Vector3.new(1,1,1), BrickColor = "Med. reddish violet"})

end


return TimeStop