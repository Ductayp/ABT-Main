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

    local newBool = Instance.new("Part")
    newBool.Name = "BlockAttacks"
    newBool.Parent = hitCharacter.HumanoidRootPart

    -- if this is a mob, then stop its animation here
    if hitParams.IsMob then
        if hitCharacter.Humanoid then
            Knit.Services.MobService:PauseAnimations(hitParams.MobId, effectParams.Duration)
        end
    end

    local hitPlayer = utils.GetPlayerFromCharacter(hitCharacter)
    if hitPlayer then
        hitCharacter.Humanoid.WalkSpeed = 0
        require(Knit.PowerUtils.BlockInput).AddBlock(hitPlayer.UserId, "PinCharacter", effectParams.Duration)
    end

    spawn(function()
        newBool:Destroy()
    end)

end

function PinCharacter.Client_RenderEffect(params)


end

return PinCharacter