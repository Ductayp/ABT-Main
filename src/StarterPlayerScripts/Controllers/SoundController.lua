-- Sounds controller
-- PDab
-- 12 / 15/ 2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer.PlayerGui


-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local SoundController = Knit.CreateController { Name = "SoundController" }

-- utility modules
local utils = require(Knit.Shared.Utils)

-- Constants
local playlistFolder = ReplicatedStorage.Audio.Music.ShufflePlaylist

-- Variables
SoundController.MusicOn = true
SoundController.PlayStack = nil
SoundController.TrackPlaying = false
SoundController.CurrentTrack = nil

--// PlayTrack
function SoundController:PlayTrack()

    -- if we are already playing a track, just return
    if SoundController.TrackPlaying then
        return
    end

    -- if the playstack table is empty, fill it with all tracks
    if SoundController.PlayStack == nil then
        SoundController.PlayStack = playlistFolder:GetChildren()
    end

    -- pick a soung from the PlayStack table, play it then remove it from the list
    local pick = math.random(1, #SoundController.PlayStack)
    SoundController.CurrentTrack = SoundController.PlayStack[pick]

    SoundController.CurrentTrack:Play()
    SoundController.TrackPlaying = true

    SoundController.CurrentTrack.Ended:Connect(function()
        SoundController.TrackPlaying = false
    end)

    SoundController.PlayStack[pick] = nil

end

--// StopAllMusic
function SoundController:StopAllMusic()

end


--// KnitStart ------------------------------------------------------------
function SoundController:KnitStart()

    -- main loop
    while true do
        if SoundController.MusicOn == true then
            SoundController:PlayTrack()
        else
            SoundController:StopAllMusic()
        end

        wait(1)
    end

end

--// KnitInit ------------------------------------------------------------
function SoundController:KnitInit()

end


return SoundController