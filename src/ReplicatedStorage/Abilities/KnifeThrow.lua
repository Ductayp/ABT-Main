-- Knife Throw Ability
-- PDab
-- 11-27-2020

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)
--local FastCast = require(Knit.Shared.FastCastRedux)
local FastCast = require(ReplicatedStorage.FastCastRedux)

-- Events
--Players.PlayerRemoving:Connect(function(player)
    --KnifeThrow.playerCasters[player.UserId] = nil
    --print("KnifeThrow player removed: ",player)
--end)

local KnifeThrow = {}

--KnifeThrow.playerCasters = {}

function KnifeThrow.ThrowKnife(initPlayer,params,knifThrowParams)
    print("hi lets throw a knife!")
    --[[
    -- setup the stand, if its not there then dont run return
	local playerStand = workspace.PlayerStands[initPlayer.UserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		return
	end

    local thisCaster
    if KnifeThrow.playerCasters[player.UserId] ~= nil then
        thisCaster = KnifeThrow.playerCasters[player.UserId]
    else
        KnifeThrow.playerCasters[player.UserId] = FastCast.new()
    end
]]--
end

return KnifeThrow


