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

	-- checks
	if params.KeyState == "InputBegan" then params.CanRun = true end
    if params.KeyState == "InputEnded" then params.CanRun = false return end
    if not Cooldown.Client_IsCooled(params) then params.CanRun = false return end
    if not Cooldown.Server_IsCooled(params) then params.CanRun = false return end
    if abilityDefs.RequireToggle_On then
        if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then params.CanRun = false return end
    end

    Cooldown.Client_SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)
    
end

--// Activate
function StandJump.Activate(params, abilityDefs)

	-- checks
	if params.KeyState == "InputBegan" then params.CanRun = true end
    if params.KeyState == "InputEnded" then params.CanRun = false return end
    if not Cooldown.Server_IsCooled(params) then params.CanRun = false return end
    if abilityDefs.RequireToggle_On then
        if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then params.CanRun = false return end
    end

    Cooldown.Server_SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)

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
    Knit.Services.PlayerUtilityService.PlayerAnimations[params.InitUserId].PlayerJump:Play()
    spawn(function()
        wait(.7)
        Knit.Services.PlayerUtilityService.PlayerAnimations[params.InitUserId].PlayerJump:Stop()
    end)
end

function StandJump.Run_Client(params, abilityDefs)

    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

    -- play the sound
    WeldedSound.NewSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.Abilities.StandLeap)

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
end

return StandJump


