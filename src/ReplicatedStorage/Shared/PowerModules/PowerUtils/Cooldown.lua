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

--------------------------------------------------------------------------------------------------------------------------
--// SERVER FUNCTIONS ----------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------

-- // Server_SetCooldown - just sets it
function Cooldown.Server_SetCooldown(userId, cooldownName, cooldownValue)

    if cooldownName == "Mouse1" then
        return
    end

    -- get cooldown folder make it if it doesnt exist
    local cooldownFolder =  ReplicatedStorage.PowerStatus[userId]:FindFirstChild("Server_Cooldowns")
    if not cooldownFolder then
        cooldownFolder = utils.EasyInstance("Folder", {Name = "Server_Cooldowns", Parent = ReplicatedStorage.PowerStatus[userId]})
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

--// Server_IsCooled: will create a new cooldown if one does not exist
function Cooldown.Server_IsCooled(params)

    local isCooled = false

    local cooldownFolder =  ReplicatedStorage.PowerStatus[params.InitUserId]:FindFirstChild("Server_Cooldowns")
    if not cooldownFolder then
        cooldownFolder = utils.EasyInstance("Folder", {Name = "Server_Cooldowns", Parent = ReplicatedStorage.PowerStatus[params.InitUserId]})
    end

    local thisCooldown = cooldownFolder:FindFirstChild(params.InputId)
    if not thisCooldown then
        thisCooldown = utils.EasyInstance("NumberValue", {Name = params.InputId, Value = os.time() - 1, Parent = cooldownFolder})
    end

    if os.time() >= thisCooldown.Value then
        isCooled = true
    end

    return isCooled
end

--------------------------------------------------------------------------------------------------------------------------
--// CLIENT FUNCTIONS ----------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------

function Cooldown.Client_SetCooldown(userId, cooldownName, cooldownValue)

    if cooldownName == "Mouse1" then
        return
    end

    -- get cooldown folder make it if it doesnt exist
    local cooldownFolder =  ReplicatedStorage.PowerStatus[userId]:FindFirstChild("Client_Cooldowns")
    if not cooldownFolder then
        cooldownFolder = utils.EasyInstance("Folder", {Name = "Client_Cooldowns", Parent = ReplicatedStorage.PowerStatus[userId]})
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

    return thisCooldown

end

--// Client_IsCooled: will return true if the cooldown does not exist
function Cooldown.Client_IsCooled(params)

    local isCooled = false

    local cooldownFolder =  ReplicatedStorage.PowerStatus[params.InitUserId]:FindFirstChild("Client_Cooldowns")
    if not cooldownFolder then
        cooldownFolder = utils.EasyInstance("Folder", {Name = "Client_Cooldowns", Parent = ReplicatedStorage.PowerStatus[params.InitUserId]})
    end

    local thisCooldown = cooldownFolder:FindFirstChild(params.InputId)
    if not thisCooldown then
        thisCooldown = utils.EasyInstance("NumberValue", {Name = params.InputId, Value = os.time() - 1, Parent = cooldownFolder})
    end

    local cooldown = thisCooldown.Value
    if os.time() >= cooldown then
        isCooled = true
    end

    return isCooled
end

return Cooldown


