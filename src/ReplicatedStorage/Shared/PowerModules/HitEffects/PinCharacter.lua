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

function PinCharacter.Server_ApplyEffect(initPlayer, hitCharacter, effectParams, hitParams)

    if not hitCharacter.HumanoidRootPart then return end

    -- if this is a mob, then stop its animation here
    if hitParams.IsMob then
        if hitCharacter.Humanoid then

            require(Knit.MobUtils.MobPin).Pin_Duration(hitParams.MobId, effectParams.Duration)

            local blockAttackBool = Instance.new("Part")
            blockAttackBool.Name = "BlockAttacks"
            blockAttackBool.Parent = hitCharacter.HumanoidRootPart

            spawn(function()
                wait(effectParams.Duration)
                blockAttackBool:Destroy()
            end)
        end
    end

    local hitPlayer = utils.GetPlayerFromCharacter(hitCharacter)
    if hitPlayer and hitPlayer.Character then

        local newAnchor = Instance.new("Part")
        newAnchor.Transparency = 1
        newAnchor.Parent = hitCharacter.HumanoidRootPart
        utils.EasyWeld(newAnchor, hitCharacter.HumanoidRootPart, newAnchor)
        newAnchor.Anchored = true
        newAnchor.Name = "PinCharacter"

        Knit.Services.PowersService:RenderHitEffect_SinglePlayer(hitPlayer, "PinCharacter", effectParams)
        require(Knit.PowerUtils.BlockInput).AddBlock(hitPlayer.UserId, "PinCharacter", effectParams.Duration)

        spawn(function()
            hitCharacter.Humanoid.WalkSpeed = 0
            wait(effectParams.Duration)
            newAnchor:Destroy()
            hitCharacter.Humanoid.WalkSpeed = require(Knit.StateModules.WalkSpeed).GetModifiedValue(initPlayer)
        end)
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