-- Sounds controller
-- PDab
-- 12 / 15/ 2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local MarketPlaceService = game:GetService("MarketplaceService")
--local PlayerGui = Players.LocalPlayer.PlayerGui

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local SoundController = Knit.CreateController { Name = "SoundController" }
local utils = require(Knit.Shared.Utils)

local ambientMusicGroup = SoundService:WaitForChild("AmbientMusic")
local SFXGroup = SoundService:WaitForChild("SFX")

-- Music Tracks
SoundController.MusicTracks = {
    [1] = "6219531136",
    [2] = "6219532373",
    [3] = "6219533347",
    [4] = "6219534846",
    [5] = "6219536166",
    [6] = "6219537022",
    [7] = "6219538128",
    [8] = "6219538982",
    [9] = "6219539876",
    [10] = "6219540855",
    [11] = "6219541979",
    [12] = "6219542952",
}

-- track control variables
SoundController.MusicOn = true -- this variable determines if we shoould be playing music or not
SoundController.IsPlaying = false -- this gets set to true while a track is playing
SoundController.TrackCounter = math.random(1, #SoundController.MusicTracks)
SoundController.CurrentTrack = nil
SoundController.NextTrack = nil


function SoundController:NewSoundObject(soundId, parent, soundGroup)

    local newSound = Instance.new("Sound")
    newSound.SoundId = "rbxassetid://" .. soundId
    newSound.Parent = parent
    newSound.Name = MarketPlaceService:GetProductInfo(soundId).Name
    newSound.SoundGroup = soundGroup
    newSound.Volume = 0.5

    return newSound
end

function SoundController:PlayMusic()

    while game:GetService("RunService").Heartbeat:Wait() do
        
        if SoundController.MusicOn then
            -- load sound from NextTrack to CurrentTrack
            if SoundController.CurrentTrack == nil then
                if SoundController.NextTrack ~= nil then
                    SoundController.CurrentTrack = SoundController.NextTrack
                    SoundController.NextTrack = nil
                end
            end

            -- load the NextTrack if its nil
            if SoundController.NextTrack == nil then
                SoundController.NextTrack = self:NewSoundObject(SoundController.MusicTracks[SoundController.TrackCounter], ambientMusicGroup, ambientMusicGroup)
                SoundController.TrackCounter = SoundController.TrackCounter + 1
                if SoundController.TrackCounter >= #SoundController.MusicTracks then
                    SoundController.TrackCounter = 1
                end
            end

            if not SoundController.IsPlaying then
                if SoundController.CurrentTrack ~= nil then

                    SoundController.CurrentTrack:Play()
                    SoundController.IsPlaying = true

                    SoundController.CurrentTrack.Ended:Connect(function()
                        SoundController.IsPlaying = false
                        SoundController.CurrentTrack:Destroy()
                        SoundController.CurrentTrack = nil
                    end)
                end
            end
        end

        wait(1)
    end
end

--// SoundController:ToggleMusic
function SoundController:ToggleMusic(boolean)

    if boolean == true then
        SoundController.MusicOn = true
    else
        if SoundController.IsPlaying then
            SoundController.MusicOn = false
            SoundController.CurrentTrack:Stop()
            SoundController.IsPlaying = false
        end
    end
    
end

--// SoundController:ToggleSFX
function SoundController:ToggleSFX(boolean)

    if boolean == true then
        SoundService.SFX.Volume = .5
    else
        SoundService.SFX.Volume = 0
    end
    
end

--// SoundController:AdjustGroupVolume
function SoundController:IncrementGroupVolume(groupName, value)

    local thisGroup = SoundService:FindFirstChild(groupName)
    if thisGroup then


        local newVolume = thisGroup.Volume + value

        if newVolume <= 0.1 then
            newVolume = 0.1
        end

        if newVolume >= 1 then
            newVolume = 1
        end
        
        thisGroup.Volume = newVolume
        
        return newVolume
    end

end

--// KnitStart ------------------------------------------------------------
function SoundController:KnitStart()

    spawn(function()
        SoundController:PlayMusic()
    end)
    

end

--// KnitInit ------------------------------------------------------------
function SoundController:KnitInit()

end


return SoundController