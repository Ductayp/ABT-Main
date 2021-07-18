-- BlockAttacks

-- Block a player or mob from attacking

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local BlockAttacks = {}

function BlockAttacks.Server_ApplyEffect(initPlayer,hitCharacter, effectParams, hitParams)

    if not hitCharacter.HumanoidRootPart then return end

    -- if this is a mob, then stop its animation here
    if hitParams.IsMob then
        require(Knit.MobUtils.BlockAttacks).Block_Duration(hitParams.MobId, effectParams.Duration)
    end

    local hitPlayer = utils.GetPlayerFromCharacter(hitCharacter)
    if hitPlayer then
        require(Knit.PowerUtils.BlockInput).AddBlock(hitPlayer.UserId, "BlockAttacks_HitEffect", effectParams.Duration)
    end

end

function BlockAttacks.Client_RenderEffect(params)


end

return BlockAttacks