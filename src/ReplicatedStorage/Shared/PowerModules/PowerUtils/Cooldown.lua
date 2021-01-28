-- Cooldown
-- PDab
-- 12-8-2020

-- applies both pracitcal effects and visual effects if needed

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
--local PowerService = Knit.GetService("PowerService")

--modules
local utils = require(Knit.Shared.Utils)

local Cooldown = {}

-- // SetCooldown - just sets it
function Cooldown.SetCooldown(player,cooldownName,cooldownValue)

    if cooldownName == "Mouse1" then
        return
    end

    -- get cooldown folder make it if it doesnt exist
    local cooldownFolder =  ReplicatedStorage.PowerStatus[player.UserId]:FindFirstChild("Cooldowns")
    if not cooldownFolder then
        cooldownFolder = utils.EasyInstance("Folder", {Name = "Cooldowns", Parent = ReplicatedStorage.PowerStatus[player.userId]})
    end

    --get  this cooldown, if its not theres make it
    local thisCooldown = cooldownFolder:FindFirstChild(cooldownName)
    if not thisCooldown then
        thisCooldown = Instance.new("NumberValue")
        thisCooldown.Name = cooldownName
        thisCooldown.Value = os.time() + cooldownValue
        thisCooldown.Parent = cooldownFolder
    end

    -- set the value
    thisCooldown.Value = os.time() + cooldownValue

    -- send off the visual effects to update the GUI
    local cooldownParams = {}
    cooldownParams.CooldownName = cooldownName
    cooldownParams.CooldownValue = cooldownValue
    cooldownParams.CooldownTime = thisCooldown.Value

    Knit.Services.GuiService:Update_Cooldown(player, cooldownParams)

    return thisCooldown
end

--// GetCooldownValue - receives the power params and returns params.CanRun as true or false
function Cooldown.GetCooldownValue(player, params)

    local cooldownFolder =  ReplicatedStorage.PowerStatus[player.UserId]:FindFirstChild("Cooldowns")
    if not cooldownFolder then
        cooldownFolder = utils.EasyInstance("Folder", {Name = "Cooldowns", Parent = ReplicatedStorage.PowerStatus[player.userId]})
    end

    local thisCooldown = cooldownFolder:FindFirstChild(params.InputId)
    if not thisCooldown then
        thisCooldown = utils.EasyInstance("NumberValue", {Name = params.InputId, Value = os.time() - 1, Parent = cooldownFolder})
    end

    return thisCooldown.Value
end

function Cooldown.IsCooled(player, params)

    local isCooled = false
    local cooldown = Cooldown.GetCooldownValue(player, params)
    --print(os.time(), cooldown)
    if os.time() >= cooldown then
        isCooled = true
    end

    return isCooled
end


return Cooldown