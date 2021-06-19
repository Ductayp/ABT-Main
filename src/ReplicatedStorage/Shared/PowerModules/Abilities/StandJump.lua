-- Bullet Kick Ability
-- PDab
-- 12-1-2020

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local AbilityToggle = require(Knit.PowerUtils.AbilityToggle)
local ManageStand = require(Knit.Abilities.ManageStand)
local Cooldown = require(Knit.PowerUtils.Cooldown)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)

-- default values
local defaultVelocityX = 10000 
local defaultVelocityZ = 10000 
local defaultVelocityY = 2800
local jumpVelocityY = 7000
local defaultDuration = 0.3

local StandJump = {}


--// --------------------------------------------------------------------
--// Handler Functions
--// --------------------------------------------------------------------

--// Initialize
function StandJump.Initialize(params, abilityDefs)

	-- check KeyState
	if params.KeyState == "InputBegan" then
		params.CanRun = true
	else
		params.CanRun = false
		return
    end

    if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
        params.CanRun = false
        return params
    end
    
    -- check cooldown
	if not Cooldown.Client_IsCooled(params) then
		params.CanRun = false
		return
    end

    StandJump.Run_Initialize(params, abilityDefs)
    
end

--// Activate
function StandJump.Activate(params, abilityDefs)

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
    require(Knit.PowerUtils.BlockInput).AddBlock(params.InitUserId, "StandJump", 2)

    StandJump.Run_Server(params, abilityDefs)
    
end

--// Execute
function StandJump.Execute(params, abilityDefs)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    if initPlayer ~= Players.LocalPlayer then
        StandJump.Run_Effects(params, abilityDefs, initPlayer)
    end

end


--// --------------------------------------------------------------------
--// Ability Functions
--// --------------------------------------------------------------------

function StandJump.Run_Initialize(params, abilityDefs)

    -- get initPlayer
    local initPlayer = Players.LocalPlayer

    params.OriginCFrame = initPlayer.Character.HumanoidRootPart.CFrame

    Knit.Controllers.PlayerUtilityController.PlayerAnimations.PlayerJump:Play()
    spawn(function()
        wait(0.7)
        Knit.Controllers.PlayerUtilityController.PlayerAnimations.PlayerJump:Stop()
    end)

    -- depth of field effect
    local newDepthOfField = ReplicatedStorage.EffectParts.Effects.DepthOfField.Default:Clone()
    newDepthOfField.Name = "newDepthOfField"
    newDepthOfField.Parent = game:GetService("Lighting")
    Debris:AddItem(newDepthOfField, 1)

    StandJump.Run_Effects(params, abilityDefs, Players.LocalPlayer)

    -- grab the LookVector before we do anything else
    local lookVector = initPlayer.Character.HumanoidRootPart.CFrame.LookVector
    local velocityX = lookVector.X * defaultVelocityX 
    local velocityZ = lookVector.Z * defaultVelocityZ
    local velocityY = defaultVelocityY
    local duration = defaultDuration

    -- do the body mover
    local bodyPosition = Instance.new("BodyPosition")
    bodyPosition.MaxForce = Vector3.new(10000,10000,10000)
    bodyPosition.P = 50000
    bodyPosition.D = 6000
    bodyPosition.Position = (initPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 150, -300)).Position
    bodyPosition.Parent = initPlayer.Character.HumanoidRootPart

    local duration = 0.4
    local startTime = tick()
    while tick() < startTime + duration do
        RunService.Heartbeat:Wait()
    end
    bodyPosition:Destroy()


end

function StandJump.Run_Server(params, abilityDefs)
    --[[
    Knit.Services.PlayerUtilityService.PlayerAnimations[params.InitUserId].PlayerJump:Play()
    spawn(function()
        wait(.7)
        Knit.Services.PlayerUtilityService.PlayerAnimations[params.InitUserId].PlayerJump:Stop()
    end)
    ]]--
end

function StandJump.Run_Effects(params, abilityDefs, initPlayer)

    -- get initPlayer
    --local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

    -- setup the stand, if its not there then dont run return
	local targetStand = workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		targetStand = ManageStand.QuickRender(params)
    end

    -- play the sound
    WeldedSound.NewSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.Abilities.StandLeap)


    --move the stand and do animations
    spawn(function() 
        ManageStand.PlayAnimation(params, "StandJump")
        ManageStand.MoveStand(params, "StandJump")
        wait(1.5)
        ManageStand.StopAnimation(params, "StandJump")
        ManageStand.MoveStand(params, "Idle")
    end)

    -- pop the part effects
    local groundShock = ReplicatedStorage.EffectParts.Abilities.StandJump.GroundShock:Clone()
    groundShock.CFrame = params.OriginCFrame:ToWorldSpace(CFrame.new(0,-2.5,0))
    groundShock.Parent = workspace.RenderedEffects

    local sizeTween = TweenService:Create(groundShock,TweenInfo.new(1),{Size = (groundShock.Size + Vector3.new(8,2,8))})
    local fadeTween = TweenService:Create(groundShock,TweenInfo.new(1),{Transparency = 1})

    fadeTween.Completed:Connect(function(playbackState)
        if playbackState == Enum.PlaybackState.Completed then
            groundShock:Destroy()
        end
    end)

    sizeTween:Play()
    fadeTween:Play()

end

return StandJump


