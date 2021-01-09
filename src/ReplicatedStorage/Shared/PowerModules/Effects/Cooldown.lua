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
    cooldownParams.cooldownName = cooldownName
    cooldownParams.cooldownValue = cooldownValue
    cooldownParams.cooldownTime = thisCooldown.Value
    Knit.Services.PowersService:RenderEffect_SinglePlayer(player,"Cooldown",cooldownParams)
    --PowerService:RenderEffect_SinglePlayer(player,"Cooldown",cooldownParams)

    return thisCooldown
end

--// CheckCooldown - receives the power params and returns params.CanRun as true or false
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

--// Client_RenderEffect
function Cooldown.Client_RenderEffect(params)

        spawn(function()
            
            -- get the wait time so that the countdown reaches zero when the cooldown is actually over
            local waitTime = (params.cooldownTime - os.time()) / params.cooldownValue

			local mainGui = Players.LocalPlayer.PlayerGui:WaitForChild("MainGui")
            local coolDownFrame = mainGui:FindFirstChild("PowerButtons",true)
            
            -- destroy the old counter
            local oldCounter =  coolDownFrame:FindFirstChild(params.cooldownName .. "_counter")
            if oldCounter then
                oldCounter:Destroy()
            end

            -- make a new counter
            local existingButton = coolDownFrame:FindFirstChild(params.cooldownName,true)
			local newButton = existingButton:Clone()
			newButton.Name = params.cooldownName .. "_counter"
			newButton.Parent = existingButton.Parent
			newButton.Text = params.cooldownValue

			for count = 1, params.cooldownValue + 1 do
				wait(waitTime)
                newButton.Text = params.cooldownValue - count
            end

            newButton:Destroy()

		end)
end 


return Cooldown