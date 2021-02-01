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
function Cooldown.SetCooldown(userId, cooldownName, cooldownValue)

    if cooldownName == "Mouse1" then
        return
    end

    -- get cooldown folder make it if it doesnt exist
    local cooldownFolder =  ReplicatedStorage.PowerStatus[userId]:FindFirstChild("Cooldowns")
    if not cooldownFolder then
        cooldownFolder = utils.EasyInstance("Folder", {Name = "Cooldowns", Parent = ReplicatedStorage.PowerStatus[userId]})
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

    local player = utils.GetPlayerByUserId(userId)
    Knit.Services.GuiService:Update_Cooldown(player, cooldownParams)

    return thisCooldown
end

--// GetCooldownValue - receives the power params and returns params.CanRun as true or false
function Cooldown.GetCooldownValue(params)

    local cooldownFolder =  ReplicatedStorage.PowerStatus[params.InitUserId]:FindFirstChild("Cooldowns")
    if not cooldownFolder then
        cooldownFolder = utils.EasyInstance("Folder", {Name = "Cooldowns", Parent = ReplicatedStorage.PowerStatus[params.InitUserId]})
    end

    local thisCooldown = cooldownFolder:FindFirstChild(params.InputId)
    if not thisCooldown then
        thisCooldown = utils.EasyInstance("NumberValue", {Name = params.InputId, Value = os.time() - 1, Parent = cooldownFolder})
    end

    return thisCooldown.Value
end

--// Server_IsCooled: will create a new cooldown if one does not exist
function Cooldown.Server_IsCooled(params)

    local isCooled = false
    local cooldown = Cooldown.GetCooldownValue(params)
    --print(os.time(), cooldown)
    if os.time() >= cooldown then
        isCooled = true
    end

    return isCooled
end


--// Client_IsCooled: will return true if the cooldown does not exist
function Cooldown.Client_IsCooled(params)

    local isCooled = true
    local cooldownFolder =  ReplicatedStorage.PowerStatus[params.InitUserId]:FindFirstChild("Cooldowns")
    if not cooldownFolder then
        return isCooled
    else
        local thisCooldown = cooldownFolder:FindFirstChild(params.InputId)
        if not thisCooldown then
            return isCooled
        else
            if os.time() <= thisCooldown.Value then
                isCooled = false
            end
        end
    end

    return isCooled
end

return Cooldown


