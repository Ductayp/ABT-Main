-- Time Stop
-- PDab
-- 11/25/2020

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knits and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)

local TimeStop = {}

--// Server Functions ----------------------------------

function TimeStop.Server_RunTimeStop(initPlayer,params)

    for _, player in pairs(game.Players:GetPlayers()) do

        print(player:DistanceFromCharacter(initPlayer.Character.Head.Position))
        print("player: ",player)
        print("initPlayer: ",initPlayer)

        if player ~= initPlayer then
            if player:DistanceFromCharacter(initPlayer.Character.Head.Position) < params.Range then

                -- get the players current power and check if they have immunity to TimeStop
                local canTimeStop = false
                local playerData = Knit.Services.PlayerDataService:GetPlayerData(player)
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
    
                    print("player frozen: ",player)
                    spawn(function()
    
                        -- store walkspeed and jumpheight, then freeze!
                        local storedWalkSpeed = player.Character.Humanoid.WalkSpeed
                        player.Character.Humanoid.WalkSpeed = 0
                        local storedJumpHeight = player.character.Humanoid.JumpHeight
                        player.character.Humanoid.JumpHeight = 0
    
                        -- Stop all playing animations and store them
                        local storedAnimTracks = {}
                        local AnimationTracks = player.Character.Humanoid:GetPlayingAnimationTracks()
                        for i, track in pairs (AnimationTracks) do
                            table.insert(storedAnimTracks, track)
                            track:Stop()
                        end
    
    
                        -- block input
                        local inputBlockedBool = powerUtils.SetInputBlock(player,{Name = "TimeStop"})
                        
    
                        -- spawn the wait and then restore the player
                        spawn(function()
    
                            wait(params.Duration)
    
                            -- restore walkspeed and jumpheight
                            player.Character.Humanoid.WalkSpeed = storedWalkSpeed
                            player.character.Humanoid.JumpHeight = storedJumpHeight
    
                            -- restore animations
                            for _,track in pairs(storedAnimTracks) do
                                track:Play()
                            end
    
                            -- un-block input
                            inputBlockedBool:Destroy()
                        end)
                    end)
                end
            end
        end
    end
end


return TimeStop