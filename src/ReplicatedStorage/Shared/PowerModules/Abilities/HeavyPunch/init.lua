-- HeavyPunch

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local AbilityToggle = require(Knit.PowerUtils.AbilityToggle)
local ManageStand = require(Knit.Abilities.ManageStand)
local Cooldown = require(Knit.PowerUtils.Cooldown)
local BlockInput = require(Knit.PowerUtils.BlockInput)
local SanityChecks = require(Knit.PowerUtils.SanityChecks)
local MobilityLock = require(Knit.PowerUtils.MobilityLock)
local CameraShaker = require(Knit.Shared.CameraShaker)

local HITBOX_DURATION = .2
local HITBOX_SIZE = Vector3.new(5, 5, 12)
local HITBOX_OFFSET = CFrame.new(0, 0, 6)
local HITBOX_DELAY = 0.4

local HeavyPunch = {}

--// Initialize --------------------------------------------------------------------------------------------------------
function HeavyPunch.Initialize(params, abilityDefs)

    params.CanRun = false

    local character = Players.LocalPlayer.Character
    if not character and character.HumanoidRootPart then return end

    -- checks
	if params.KeyState == "InputEnded" then return end
	if not Cooldown.Client_IsCooled(params) then return end
    if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then return end

    params.CanRun = true

    -- set origin here isnetad of inside the abilityMod because we MUST always have it. We do a SanityCheck on the server
    params.CFrameOrigin_Client = character.HumanoidRootPart.CFrame
    
    -- run abilityMod setup
    local abilityMod = require(abilityDefs.AbilityMod)
    abilityMod.Client_Initialize(params, abilityDefs)
    spawn(function()
        abilityMod.Client_Stage_1(params, abilityDefs)

        wait(.4)
        local lockParams = {}
        lockParams.Duration = .4
        lockParams.ShiftLock_NoSpin = true
        lockParams.AnchorCharacter = true
        MobilityLock.Client_AddLock(lockParams)

        local camera = Workspace.CurrentCamera
        local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCf)
            camera.CFrame = camera.CFrame * shakeCf
        end)

        camShake:Start()
        camShake:Shake(CameraShaker.Presets.Rumble)
    end)


end

--// Activate --------------------------------------------------------------------------------------------------------
function HeavyPunch.Activate(params, abilityDefs)

    -- checks
    if params.KeyState == "InputEnded" then return end
    if not Cooldown.Server_IsCooled(params) then return end
    if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then return end

    params.CanRun = true

    -- get player and character
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    if not initPlayer then return end
    local initCharacter = initPlayer.Character
    if not initCharacter then return end

    local abilityMod = require(abilityDefs.AbilityMod)

    -- set cooldown and input block
    Cooldown.Server_SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)
    BlockInput.AddBlock(params.InitUserId, "HeavyPunch", abilityMod.InputBlockTime)

    -- server start
    abilityMod.Server_Setup(params, abilityDefs, initPlayer)

    -- CFrame sanity check
    params.CFrameOrigin_Server = SanityChecks.TestCFrame(initPlayer, params.CFrameOrigin_Client)

    -- hitbox
	local hitBox = Instance.new("Part")
    hitBox.CanCollide = false
    hitBox.Massless = true
	hitBox.Size = HITBOX_SIZE
	hitBox.Transparency = 1
	hitBox.Parent = Workspace.ServerHitboxes[params.InitUserId]
    hitBox.Touched:Connect(function() end)

    local newWeld = Instance.new("Weld")
	newWeld.C1 =  HITBOX_OFFSET
	newWeld.Part0 = initPlayer.Character.HumanoidRootPart
	newWeld.Part1 = hitBox
	newWeld.Parent = hitBox

    params.HitBox = hitBox

    spawn(function()

        wait(HITBOX_DELAY)

        --hitBox.Color = Color3.fromRGB(232, 99, 255)

        local hit = hitBox:GetTouchingParts()
        local hitCharacters = {}
        for _, part in pairs(hit) do
            if part.Parent:FindFirstChild("Humanoid") then
                hitCharacters[part.Parent] = true
            end
        end

        for character, _ in pairs(hitCharacters) do
            local thisPlayer = utils.GetPlayerFromCharacter(character)
            if thisPlayer ~= initPlayer then
                abilityMod.HitCharacter(params, abilityDefs, initPlayer, character, hitBox)
            end
        end

        hitBox.Touched:Connect(function(part)
            if part.Parent:FindFirstChild("Humanoid") then
                if not hitCharacters[part.Parent] then
                    hitCharacters[part.Parent] = true
                    abilityMod.HitCharacter(params, abilityDefs, initPlayer, character, hitBox)
                end
            end
        end)

        wait(HITBOX_DURATION)
        hitBox:Destroy()

    end)

end

--// Execute --------------------------------------------------------------------------------------------------------
function HeavyPunch.Execute(params, abilityDefs)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    if not initPlayer then return end

    local abilityMod = require(abilityDefs.AbilityMod)

    if initPlayer ~= Players.LocalPlayer then
        spawn(function()
            abilityMod.Client_Stage_1(params, abilityDefs, initPlayer)
        end)
    end

    wait(HITBOX_DELAY)
    
    abilityMod.Client_Stage_2(params, abilityDefs, initPlayer)

end

return HeavyPunch