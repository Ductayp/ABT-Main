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

    -- run effects
	StandJump.Run_Client(params, abilityDefs)

end


--// --------------------------------------------------------------------
--// Ability Functions
--// --------------------------------------------------------------------

function StandJump.Setup(params, abilityDefs)

end

function StandJump.Run_Server(params, abilityDefs)

end

function StandJump.Run_Client(params, abilityDefs)

    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

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
    groundShock.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,-2.5,0))
    groundShock.Parent = workspace.RenderedEffects

    local sizeTween = TweenService:Create(groundShock,TweenInfo.new(1.5),{Size = (groundShock.Size + Vector3.new(1,2,1))})
    local fadeTween = TweenService:Create(groundShock,TweenInfo.new(2),{Transparency = 1})

    fadeTween.Completed:Connect(function(playbackState)
        if playbackState == Enum.PlaybackState.Completed then
            groundShock:Destroy()
        end
    end)

    sizeTween:Play()
    fadeTween:Play()

    -- apply deffect to the initPlayer
    if initPlayer == Players.LocalPlayer then

        -- depth of field effect
        local newDepthOfField = ReplicatedStorage.EffectParts.Effects.DepthOfField.Default:Clone()
        newDepthOfField.Name = "newDepthOfField"
        newDepthOfField.Parent = game:GetService("Lighting")
        Debris:AddItem(newDepthOfField, 1)

        -- declare here for use everywhere
        local velocityX
        local velocityZ
        local velocityY
        local duration

        -- grab the LookVector before we do anything else
        local lookVector = initPlayer.Character.HumanoidRootPart.CFrame.LookVector
        velocityX = lookVector.X * defaultVelocityX 
        velocityZ = lookVector.Z * defaultVelocityZ
        velocityY = defaultVelocityY
        duration = defaultDuration

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

    --[[ -- trails commented out because they didnt look great, but im leaving them here justin case :)
    -- add some trails
    local locations = {"Head","UpperTorso","LeftLowerLeg","RightLowerLeg","LeftHand","RightHand"}
    for count = 1, 6 do
        local newTrail = ReplicatedStorage.EffectParts.Abilities.StandJump.StandJumpTrail:Clone()
        local thisLocation = locations[count]
        newTrail.CFrame = initPlayer.Character[thisLocation].CFrame
        newTrail.Parent = initPlayer.Character[thisLocation]
        utils.EasyWeld(newTrail,initPlayer.Character[thisLocation],newTrail)
        spawn(function()
            wait(.1)
            newTrail.Trail.MaxLength = 0
            wait(1)
            newTrail:Destroy()
        end)
    end
    ]]--


end

return StandJump


