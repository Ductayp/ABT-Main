-- BitesTheDust
-- PDab
-- 12-1-2020

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local AbilityToggle = require(Knit.PowerUtils.AbilityToggle)
local ManageStand = require(Knit.Abilities.ManageStand)
local Cooldown = require(Knit.PowerUtils.Cooldown)
local RayHitbox = require(Knit.PowerUtils.RayHitbox)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)

local abilityDuration = 5

local BitesTheDust = {}

--// --------------------------------------------------------------------
--// Handler Functions
--// --------------------------------------------------------------------

--// Initialize
function BitesTheDust.Initialize(params, abilityDefs)

	-- check KeyState
	if params.KeyState == "InputBegan" then
		params.CanRun = true
	else
		params.CanRun = false
		return
    end
    
    -- check cooldown
    if not Cooldown.Client_IsCooled(params) then
        print("not cooled down", params)
		params.CanRun = false
		return
    end

    if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
        print("stand wasnt on")
        params.CanRun = false
        return params
    end

    -- tween effects
    spawn(function()
        BitesTheDust.Run_Client(params, abilityDefs)
    end)
	
end

--// Activate
function BitesTheDust.Activate(params, abilityDefs)

	-- check KeyState
	if params.KeyState == "InputBegan" then
		params.CanRun = true
	else
		params.CanRun = false
		return
    end
    
    -- check cooldown
	if not Cooldown.Client_IsCooled(params) then
		params.CanRun = false
		return
    end
    

    if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
        params.CanRun = false
        return params
    end

	-- set cooldown
    Cooldown.SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)

    -- block input
    require(Knit.PowerUtils.BlockInput).AddBlock(params.InitUserId, "BitesTheDust", 2)

    -- tween hitbox
    BitesTheDust.Run_Server(params, abilityDefs)

end

--// Execute
function BitesTheDust.Execute(params, abilityDefs)

	if Players.LocalPlayer.UserId == params.InitUserId then
		print("Players.LocalPlayer == initPlayer: DO NOT RENDER")
		return
	end

    -- tween effects
	BitesTheDust.Run_Client(params, abilityDefs)

end


--// --------------------------------------------------------------------
--// Ability Functions
--// --------------------------------------------------------------------

function BitesTheDust.Run_Server(params, abilityDefs)

    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

    -- clone out a new hitpart
    local hitPart = ReplicatedStorage.EffectParts.Abilities.BitesTheDust  .HitBox:Clone()
    hitPart.Parent = Workspace.ServerHitboxes[params.InitUserId]
    hitPart.CFrame = initPlayer.Character.HumanoidRootPart.CFrame
    --Debris:AddItem(hitPart, abilityDuration + 1)
    utils.EasyWeld(initPlayer.Character.HumanoidRootPart, hitPart, hitPart)

    -- make a new hitbox
    local newHitbox = RayHitbox.New(initPlayer, abilityDefs, hitPart, false)
    newHitbox:HitStart()
    newHitbox:DebugMode(true)

end

function BitesTheDust.Run_Client(params, abilityDefs)

end

return BitesTheDust


