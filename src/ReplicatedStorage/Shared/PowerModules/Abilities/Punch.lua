-- Punch Ability
-- PDab
-- 12-1-2020

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
--local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local AbilityToggle = require(Knit.PowerUtils.AbilityToggle)
local ManageStand = require(Knit.Abilities.ManageStand)
local Cooldown = require(Knit.PowerUtils.Cooldown)
local RayHitbox = require(Knit.PowerUtils.RayHitbox)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)

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
    
    --[[
    -- tween effects
    spawn(function()
        Punch.Run_Effects(params, abilityDefs)
    end)
    ]]--
	
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

	-- set cooldown
    --Cooldown.Server_SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)

    -- block input
    require(Knit.PowerUtils.BlockInput).AddBlock(params.InitUserId, "Punch", 0.5)

    -- tween hitbox
    spawn(function()
        Punch.Run_Server(params, abilityDefs)
    end)
    
end

--// Execute
function Punch.Execute(params, abilityDefs)

    --[[
	if Players.LocalPlayer.UserId == params.InitUserId then
		--print("Players.LocalPlayer == initPlayer: DO NOT RENDER")
		return
	end
    ]]--

    -- tween effects
	Punch.Run_Effects(params, abilityDefs)

end


--// --------------------------------------------------------------------
--// Ability Functions
--// --------------------------------------------------------------------

function Punch.Run_Server(params, abilityDefs)

    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

    -- play animations and sounds
    if lastPunch == "Punch_1" then
        Knit.Services.PlayerUtilityService.PlayerAnimations[initPlayer.UserId].Punch_2:Play()
        WeldedSound.NewSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.General.GenericWhoosh_Slow, {SoundProperties = {PlaybackSpeed = 1.7}})
        lastPunch = "Punch_2"
    else
        Knit.Services.PlayerUtilityService.PlayerAnimations[initPlayer.UserId].Punch_1:Play()
        WeldedSound.NewSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.General.GenericWhoosh_Fast)
        lastPunch = "Punch_1"
    end

    -- clone out a new hitpart
    local hitPart = ReplicatedStorage.EffectParts.Abilities.Punch.HitBox:Clone()
    hitPart.Parent = Workspace.ServerHitboxes[params.InitUserId]
    --hitPart.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,2))
    Debris:AddItem(hitPart, .6)

    -- weld it
    local newWeld = Instance.new("Weld")
    newWeld.C1 =  CFrame.new(0, 0, 2)
    newWeld.Part0 = initPlayer.Character.HumanoidRootPart
    newWeld.Part1 = hitPart
    newWeld.Parent = hitPart

    -- make a new hitbox
    local newHitbox = RayHitbox.New(initPlayer, abilityDefs, hitPart, true)
    newHitbox:HitStart()
    --newHitbox:DebugMode(true)

    -- move it
    spawn(function()
        newWeld.C1 =  CFrame.new(0, 3, 2)
        wait(.2)
        newWeld.C1 =  CFrame.new(0, 0, 2)
    end)
    
    

end

function Punch.Run_Effects(params, abilityDefs)
    -- nothing here yet
end

return Punch


