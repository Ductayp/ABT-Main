-- PowersUtils
-- PDab
-- 11/17/2020

-- General set of utilities used by powers

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local PowerUtils = {}

function PowerUtils.CheckCooldown(player,params)

    local cooldownFolder =  ReplicatedStorage.PowerStatus[player.UserId]:FindFirstChild("Cooldowns")
    if not cooldownFolder then
        cooldownFolder = utils.EasyInstance("Folder", {Name = "Cooldowns", Parent = ReplicatedStorage.PowerStatus[player.userId]})
    end

    local thisCooldown = cooldownFolder:FindFirstChild(params.Key)
    if not thisCooldown then
        thisCooldown = utils.EasyInstance("NumberValue", {Name = params.Key, Value = os.time() - 1, Parent = cooldownFolder})
    end

    if os.time() > thisCooldown.Value then
        params.CanRun = true
    end

    return params
end

function PowerUtils.SetCooldown(player,params,value)

    local cooldownFolder =  ReplicatedStorage.PowerStatus[player.UserId]:FindFirstChild("Cooldowns")
    if not cooldownFolder then
        cooldownFolder = utils.EasyInstance("Folder", {Name = "Cooldowns", Parent = ReplicatedStorage.PowerStatus[player.userId]})
    end

    local thisCooldown = cooldownFolder:FindFirstChild(params.Key)
    if not thisCooldown then
        cooldownFolder = utils.EasyInstance("NumberValue", {Name = params.Key, Value = os.time() - 1, Parent = cooldownFolder})
    end

    thisCooldown.Value = value
end

function PowerUtils.ToggleStand(player,params,value)
    -- get stand toggle, setup if it doesnt exist
    local standToggle = ReplicatedStorage.PowerStatus[initPlayer.UserId]:FindFirstChild("StandActive")
    if not standToggle and RunService:IsServer() then
        standToggle = utils.EasyInstance("BoolValue",{Name = "StandActive",Value = value,Parent = ReplicatedStorage.PowerStatus[initPlayer.UserId]})
    end
end

return PowerUtils