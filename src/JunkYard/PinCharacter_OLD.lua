-- Pin Character Effect
-- PDab
-- 12-4-2020

-- simply anchors the character in place and removes their key input for powers. Used in timestop or freeze attacks

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local PinCharacter = {}

function PinCharacter.Server_ApplyEffect(initPlayer,hitCharacter, effectParams, hitParams)

    if not hitCharacter.HumanoidRootPart then return end

    if hitCharacter.HumanoidRootPart.Anchored == true then
        return
    else
        spawn(function()
            --local storedAnchorState = hitCharacter.HumanoidRootPart.Anchored
            hitCharacter.HumanoidRootPart.Anchored = true
            wait(effectParams.Duration)
            hitCharacter.HumanoidRootPart.Anchored = false
            --hitCharacter.HumanoidRootPart.Anchored = storedAnchorState
        end) 
    end

    -- if this is a mob, then stop its animation here
    if hitParams.IsMob then
        if hitCharacter.Humanoid then
            Knit.Services.MobService:PauseAnimations(hitParams.MobId, effectParams.Duration)
        end
    end

    local hitPlayer = utils.GetPlayerFromCharacter(hitCharacter)
    if hitPlayer then
        print("hitPlayer", hitPlayer)
        Knit.Services.PowersService:RenderEffect_SinglePlayer(hitPlayer, "PinCharacter", effectParams)
        require(Knit.PowerUtils.BlockInput).AddBlock(hitPlayer.UserId, "PinCharacter", effectParams.Duration)
    end

end

function PinCharacter.Client_RenderEffect(params)

    -- Stop all playing animations
    for i, track in pairs (Players.LocalPlayer.Character.Humanoid.Animator:GetPlayingAnimationTracks()) do
        local originalSpeed = track.Speed
        track:AdjustSpeed(0)
        spawn(function()
            wait(params.Duration)
            track:AdjustSpeed(originalSpeed)
        end)
    end
end

return PinCharacter