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
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)


local Cooldown = {}

-- // SetCooldown - just sets it
function Cooldown.SetCooldown(player,cooldownName,cooldownValue)

    local cooldownFolder =  ReplicatedStorage.PowerStatus[player.UserId]:FindFirstChild("Cooldowns")
    if not cooldownFolder then
        cooldownFolder = utils.EasyInstance("Folder", {Name = "Cooldowns", Parent = ReplicatedStorage.PowerStatus[player.userId]})
    end

    local thisCooldown = cooldownFolder:FindFirstChild(cooldownName)
    if not thisCooldown then
        thisCooldown = Instance.new("NumberValue")
        thisCooldown.Name = cooldownName
        thisCooldown.Value = os.time() - 1 -- set it to the past for now
        thisCooldown.Parent = cooldownFolder
    end

    thisCooldown.Value = os.time() + cooldownValue

    local cooldownParams = {}
    cooldownParams.cooldownName = cooldownName
    cooldownParams.cooldownValue = cooldownValue
    cooldownParams.cooldownTime = thisCooldown.Value
    Knit.Services.PowersService:RenderEffect_SinglePlayer(player,"Cooldown",cooldownParams)

    return thisCooldown
end

--// CheckCooldown - receives the power params and returns params.CanRun as true or false
function Cooldown.GetCooldownValue(player,cooldownName)

    local cooldownFolder =  ReplicatedStorage.PowerStatus[player.UserId]:FindFirstChild("Cooldowns")
    if not cooldownFolder then
        cooldownFolder = utils.EasyInstance("Folder", {Name = "Cooldowns", Parent = ReplicatedStorage.PowerStatus[player.userId]})
    end

    local thisCooldown = cooldownFolder:FindFirstChild(cooldownName)
    if not thisCooldown then
        thisCooldown = Instance.new("NumberValue")
        thisCooldown.Name = cooldownName
        thisCooldown.Value = os.time() - 1 -- set it to the past for now
        thisCooldown.Parent = cooldownFolder
    end

    return thisCooldown.Value
end

--// SetGUICooldown
function Cooldown.Client_RenderEffect(params)

		spawn(function()

			local mainGui = localPlayer.PlayerGui:WaitForChild("MainGui")
			local coolDownFrame = mainGui:FindFirstChild("CoolDown",true)
			local newButton = coolDownFrame:FindFirstChild(params.cooldownObject.Name):Clone()
			newButton.Name = "Cooldown"
			newButton.Parent = coolDownFrame
			newButton.Text = time
			utils.EasyDebris(newButton,value)
			for count = 1, value do
				wait(1)
				newButton.Text = value - count
			end
		end)
end 


return Cooldown