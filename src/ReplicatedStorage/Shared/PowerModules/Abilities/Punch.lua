-- Punch Ability
-- PDab
-- 12-1-2020

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
--local Players = game:GetService("Players")
--local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local AbilityToggle = require(Knit.PowerUtils.AbilityToggle)
local ManageStand = require(Knit.Abilities.ManageStand)
local Cooldown = require(Knit.PowerUtils.Cooldown)
local RayHitbox = require(Knit.PowerUtils.RayHitbox)

-- variables
local lastPunch = "Punch_2"

local Punch = {}


--// --------------------------------------------------------------------
--// Handler Functions
--// --------------------------------------------------------------------

--// Initialize
function Punch.Initialize(params, abilityDefs)

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
    
    -- tween effects
    spawn(function()
        Punch.Run_Effects(params, abilityDefs)
    end)
	
end

--// Activate
function Punch.Activate(params, abilityDefs)

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

     -- require toggles to be inactive, excluding "Q"
     if not AbilityToggle.RequireOff(params.InitUserId, abilityDefs.RequireToggle_Off) then
        params.CanRun = false
        return params
    end

	-- set cooldown
    Cooldown.SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)

    -- set toggle
    AbilityToggle.QuickToggle(params.InitUserId, params.InputId, true)

    -- tween hitbox
    spawn(function()
        Punch.Run_Server(params, abilityDefs)
    end)
    
end

--// Execute
function Punch.Execute(params, abilityDefs)

	if Players.LocalPlayer.UserId == params.InitUserId then
		print("Players.LocalPlayer == initPlayer: DO NOT RENDER")
		return
	end

    -- tween effects
	Punch.Run_Effects(params, abilityDefs)

end


--// --------------------------------------------------------------------
--// Ability Functions
--// --------------------------------------------------------------------

function Punch.Run_Server(params, abilityDefs)
    print("boop")

    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

    -- animations
    if lastPunch == "Punch_1" then
        Knit.Services.PlayerUtilityService.PlayerAnimations[initPlayer.UserId].Punch_2:Play()
        lastPunch = "Punch_2"
    else
        Knit.Services.PlayerUtilityService.PlayerAnimations[initPlayer.UserId].Punch_1:Play()
        lastPunch = "Punch_1"
    end

    -- clone out a new hitpart
    local hitPart = ReplicatedStorage.EffectParts.Abilities.HeavyPunch.HitBox:Clone()
    hitPart.Parent = Workspace.ServerHitboxes[params.InitUserId]
    hitPart.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-7))
    Debris:AddItem(hitPart, .6)

    -- make a new hitbox
    local newHitbox = RayHitbox.New(initPlayer, abilityDefs, hitPart, true)
    newHitbox:HitStart()
    

    

end

function Punch.Run_Effects(params, abilityDefs)
    -- nothing here yet
end

return Punch


