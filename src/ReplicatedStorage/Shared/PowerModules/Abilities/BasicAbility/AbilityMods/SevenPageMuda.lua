-- BlackHole

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)
local AnchoredSound = require(Knit.PowerUtils.AnchoredSound)
local ManageStand = require(Knit.Abilities.ManageStand)
local TargetByZone = require(Knit.PowerUtils.TargetByZone)
local CamShakeTools = require(Knit.PowerUtils.CamShakeTools)
local BlockInput = require(Knit.PowerUtils.BlockInput)

local initPlayerTracker = {}

local mudaDuration = 10

local HITBOX_DELAY = .2
local HITBOX_DURATION = .5
local HITBOX_SIZE = Vector3.new(6, 5, 12)
local HITBOX_OFFSET = CFrame.new(0, 0, 6)

local module = {}

module.InputBlockTime = 1.5

-- MobilityLock params
module.MobilityLockParams = {}
module.MobilityLockParams.Duration = 1
module.MobilityLockParams.ShiftLock_NoSpin = true
module.MobilityLockParams.AnchorCharacter = true

------------------------------------------------------------------------------------------------------------------
--// CLIENT FUNTIONS ---------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------

--// Client_Initialize
function module.Client_Initialize(params, abilityDefs, delayOffset)

    local thisHRP = Players.LocalPlayer.Character.HumanoidRootPart
    if not thisHRP then return end

    params.PinCFrame = thisHRP.CFrame:ToWorldSpace(CFrame.new(0,0, -8))

    spawn(function()
        local character = Players.LocalPlayer.Character
        if not character and character.HumanoidRootPart then return end
    
        Knit.Controllers.PlayerUtilityController.PlayerAnimations.PowerPose1:Play()
        wait(module.MobilityLockParams.Duration)
        Knit.Controllers.PlayerUtilityController.PlayerAnimations.PowerPose1:Stop()
    end)

end


--// Client_Stage_1
function module.Client_Stage_1(params, abilityDefs, delayOffset)

    local targetStand = Workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
    if not targetStand then
        targetStand = ManageStand.QuickRender(params)
    end

    WeldedSound.NewSound(targetStand.HumanoidRootPart, ReplicatedStorage.Audio.General.GenericWhoosh_Slow)

    ManageStand.Aura_On(params)
    ManageStand.MoveStand(params, "Front")
    ManageStand.PlayAnimation(params, "Point")

    --wait(module.MobilityLockParams.Duration + .1)

    --ManageStand.StopAnimation(params, "Point")
    --ManageStand.MoveStand(params, "Idle")
    --ManageStand.Aura_Off(params)

end

--// Client_Stage_2
function module.Client_Stage_2(params, abilityDefs, initPlayer)

    if not initPlayer and initPlayer.Character then return end

    local targetStand = Workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
    if not targetStand then
        targetStand = ManageStand.QuickRender(params)
    end

    wait(HITBOX_DELAY - .1)

    CamShakeTools.Client_PresetRadiusShake(targetStand:FindFirstChild("HumanoidRootPart", true).Position, 8, "HeavyPunch")

    WeldedSound.NewSound(targetStand.HumanoidRootPart, ReplicatedStorage.Audio.General.HeavyBlast)

    local standBurst = ReplicatedStorage.EffectParts.Abilities.BasicAbility.SevenPageMuda.StandBurst:Clone()
    standBurst.CFrame = targetStand.HumanoidRootPart.CFrame
    utils.EasyWeld(targetStand.HumanoidRootPart, standBurst, standBurst)
    standBurst.Parent = Workspace.RenderedEffects
    Debris:AddItem(standBurst, 5)

    standBurst.Burst:Emit(30)

    spawn(function()

        wait(module.MobilityLockParams.Duration + .1)

        if params.HitBool.Value == false then
            ManageStand.StopAnimation(params, "Point")
            ManageStand.MoveStand(params, "Idle")
            ManageStand.Aura_Off(params)
        end

    end)

    for count = 1,3 do

        local newWave = ReplicatedStorage.EffectParts.Abilities.BasicAbility.SevenPageMuda.ShockRing:Clone()
        newWave.Parent = Workspace.RenderedEffects
        newWave.CFrame = targetStand:FindFirstChild("HumanoidRootPart", true).CFrame:ToWorldSpace(CFrame.new(0,0,-2))

        local moveTween = TweenService:Create(newWave, TweenInfo.new(.5), {CFrame = newWave.CFrame:ToWorldSpace(CFrame.new(0,0,-6))})
        local otherTween = TweenService:Create(newWave.Mesh, TweenInfo.new(.5), {Size = Vector3.new(4,0.4,4), Transparency = 1})

        moveTween.Completed:Connect(function()
            newWave:Destroy()
        end)

        moveTween:Play()
        otherTween:Play()

        wait(.2)

    end

end

--// Client_MudaEffect
function module.Client_MudaEffect(params)

    local standParams = {}
    standParams.InitUserId = params.InitPlayer.UserId

	local targetStand = workspace.PlayerStands[params.InitPlayer.UserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		ManageStand.QuickRender(standParams)
	end

    -- move stand and play Barrage animation
    ManageStand.StopAnimation(standParams, "Point")
    ManageStand.PlayAnimation(standParams, "Barrage")
    ManageStand.MoveStand(standParams, "Front")
    spawn(function()
        wait(mudaDuration)
        ManageStand.StopAnimation(standParams, "Barrage")
        ManageStand.MoveStand(standParams, "Idle")
        ManageStand.Aura_Off(standParams)
    end)

    WeldedSound.NewSound(targetStand.HumanoidRootPart, ReplicatedStorage.Audio.General.PowerUpDistorted)
    WeldedSound.NewSound(targetStand.HumanoidRootPart, ReplicatedStorage.Audio.StandSpecific.GoldExperience.Barrage)
    spawn(function()
        wait(5)
        WeldedSound.NewSound(targetStand.HumanoidRootPart, ReplicatedStorage.Audio.General.PulseRay6)
        WeldedSound.NewSound(targetStand.HumanoidRootPart, ReplicatedStorage.Audio.StandSpecific.GoldExperience.Barrage)
    end)

    -- placeholder for custom animaitons, might not use this at all
    local hitPlayer = utils.GetPlayerFromCharacter(params.HitCharacter)
    if hitPlayer then
        --params.HitCharacter.Humanoid.Animator.SevenPageMuda:Play()
    elseif params.HitParams.IsMob then
        --print("IS MOB!")
    end

    
    -- do the camera effects for the players involved
    if hitPlayer == Players.LocalPlayer or params.InitPlayer == Players.LocalPlayer then

        Knit.Controllers.GuiController.Modules.ShiftLock.SetOff()

        local defaultCamera = Workspace.CurrentCamera
        defaultCamera.CameraType = Enum.CameraType.Scriptable
        spawn(function()
            wait(mudaDuration)
            defaultCamera.CameraType = Enum.CameraType.Custom
        end)

        game:GetService("StarterGui"):SetCore("ResetButtonCallback", false)

        local target = params.PinCFrame.Position

        local eyeA1 = params.PinCFrame:ToWorldSpace(CFrame.new(12, 10, 18)).Position
        local eyeA2 = params.PinCFrame:ToWorldSpace(CFrame.new(3, 5, 8)).Position

        local eyeB1 = params.PinCFrame:ToWorldSpace(CFrame.new(12, 10, -18)).Position
        local eyeB2 = params.PinCFrame:ToWorldSpace(CFrame.new(3, 5, -8)).Position
        

        local cameraTween1 = TweenService:Create(defaultCamera, TweenInfo.new(5), {CFrame = utils.LookAt(eyeA2, target)})
        local cameraTween2 = TweenService:Create(defaultCamera, TweenInfo.new(5), {CFrame = utils.LookAt(eyeB2, target)})

        cameraTween1.Completed:Connect(function()
            defaultCamera.CFrame = utils.LookAt(eyeB1, target)
            cameraTween2:Play()
        end)

        cameraTween2.Completed:Connect(function()
            --defaultCamera.CameraType = Enum.CameraType.Custom
            game:GetService("StarterGui"):SetCore("ResetButtonCallback", true)
        end)

        defaultCamera.CFrame = utils.LookAt(eyeA1, target)

        cameraTween1:Play()

        -- do the screen gui effects
        local playerGui = game:GetService('Players').LocalPlayer:WaitForChild('PlayerGui')
        local mudaGui = ReplicatedStorage.EffectParts.Abilities.BasicAbility.SevenPageMuda.MudaGui:Clone()
        mudaGui.Parent = playerGui

        local scaleTween = TweenService:Create(mudaGui.SpeedLines.BaseLines, TweenInfo.new(mudaDuration), {Size = mudaGui.SpeedLines.BaseLines.Size + UDim2.new(1,1,1,1)})
        scaleTween:Play()

        local endTime = os.clock() + mudaDuration

        -- destroy gui timer
        spawn(function()

            while os.clock() < endTime - 0.5 do
                wait()
            end

            mudaGui:Destroy()

        end)

        -- Speed Lines
        spawn(function()

            local stepsPerSecond = 20

            while os.clock() < endTime do

                -- steps per second
                for count = 1, stepsPerSecond do

                    if not mudaGui:FindFirstChild("SpeedLines") then return end

                    local thisImage = mudaGui.SpeedLines:FindFirstChild(math.random(1, 5))

                    thisImage.Visible = true

                    wait(1 / stepsPerSecond)

                    thisImage.Visible = false
                end

            end

            --mudaGui:Destroy()
        
        end)

        -- Muda Text
        spawn(function()

            local stepsPerSecond = 20

            local mudaText = mudaGui.MudaText:FindFirstChild("TextLabel", true)
            mudaText.Visible = false

            while os.clock() < endTime do

                for count = 1, stepsPerSecond do

                    if not mudaGui:FindFirstChild("MudaText") then return end

                    local thisImage = mudaText:Clone()
                    thisImage.Parent = mudaGui.MudaText

                    local posX
                    local posY

                    local position = math.random(1,4)

                    if position == 1 then -- left side

                        posX = math.random(0, 30) / 100
                        posY = math.random(0, 100) / 100

                    elseif position == 2 then -- top side

                        posX = math.random(0, 100) / 100
                        posY = math.random(0, 20) / 100

                    elseif position == 3 then -- right side

                        posX = math.random(70, 100) / 100
                        posY = math.random(0, 100) / 100

                    elseif position == 4 then -- bottom side

                        posX = math.random(0, 100) / 100
                        posY = math.random(80, 100) / 100

                    end

                    thisImage.Position = UDim2.fromScale(posX, posY)

                    local sizeX = math.random(10, 30) / 100
                    local sizeY = math.random(5, 15) / 100
                    thisImage.Size = UDim2.fromScale(sizeX, sizeY)

                    local rot = math.random(-15,15)
                    thisImage.Rotation = rot

                    
                    thisImage.Visible = true

                    wait(1 / stepsPerSecond)

                end


            end

        end)

    end

end

------------------------------------------------------------------------------------------------------------------
--// SERVER FUNTIONS ---------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------

--// Server_Setup
function module.Server_Setup(params, abilityDefs, initPlayer)

    local hitBool = Instance.new("BoolValue")
    hitBool.Name = "SevenPageMudaHit" .. initPlayer.UserId
    hitBool.Value = false
    hitBool.Parent = Workspace.RenderedEffects
    Debris:AddItem(hitBool, mudaDuration + 1)

    params.HitBool = hitBool

end

--// Server_Run
function module.Server_Run(params, abilityDefs, initPlayer)

    local thisHRP = initPlayer.Character.HumanoidRootPart
    if not thisHRP then return end

    -- make initPlayer invulnerable
    local newBool = Instance.new("BoolValue")
    newBool.Value = true
    newBool.Name = "Invulnerable_HitEffect"
    newBool.Parent = thisHRP

    spawn(function()
        wait(mudaDuration)
        newBool:Destroy()
    end)

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
	newWeld.Part0 = thisHRP
	newWeld.Part1 = hitBox
	newWeld.Parent = hitBox

    --params.HitBox = hitBox

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
                module.HitCharacter(params, abilityDefs, initPlayer, character, hitBox)
            end
        end

        hitBox.Touched:Connect(function(part)
            if part.Parent:FindFirstChild("Humanoid") then
                local character = part.Parent
                if not hitCharacters[character] then
                    hitCharacters[character] = true
                    module.HitCharacter(params, abilityDefs, initPlayer, character, hitBox)
                end
            end
        end)

        wait(HITBOX_DURATION)
        hitBox:Destroy()

    end)
end

--// HitCharacter
function module.HitCharacter(params, abilityDefs, initPlayer, hitCharacter, hitBox)

    if not initPlayer.Character then return end

    BlockInput.AddBlock(params.InitUserId, "SevenPageMuda", mudaDuration)

    abilityDefs.HitEffects = {Teleport = {TargetPosition = params.PinCFrame.Position, LookAt = initPlayer.Character.HumanoidRootPart.Position}}
    Knit.Services.PowersService:RegisterHit(initPlayer, hitCharacter, abilityDefs)

    abilityDefs.HitEffects = {
        DamageOverTime = {Damage = 2, TickCount = 35, TickLength = .25},
        PinCharacter = {Duration = mudaDuration},
        Invulnerable = {Duration = mudaDuration},
        RunFunctions = {
            {RunOn = "Server", Script = script, FunctionName = "Server_MudaEffect", Arguments = {}},
            {RunOn = "Client", Script = script, FunctionName = "Client_MudaEffect", Arguments = {PinCFrame = params.PinCFrame}}
        },
    }

    local canHit = Knit.Services.PowersService:RegisterHit(initPlayer, hitCharacter, abilityDefs)

    -- handle initPlayer, this will fire ONCE for the intiPlayer and ONLY if they hit another character
    if not canHit then return end
    if initPlayerTracker[initPlayer.UserId] then return end

    params.HitBool.Value = true

    initPlayerTracker[initPlayer.UserId] = true
    spawn(function()
        wait(mudaDuration)
        initPlayerTracker[initPlayer.UserId] = nil
    end)

    local anchorPart = Instance.new("Part")
    anchorPart.Transparency = 1
    anchorPart.Anchored = true
    utils.EasyWeld(initPlayer.Character.HumanoidRootPart, anchorPart, anchorPart)
    anchorPart.Parent = Workspace.RenderedEffects
    spawn(function()
        wait(mudaDuration)
        anchorPart:Destroy()
    end)

    require(Knit.PowerUtils.BlockInput).AddBlock(initPlayer.UserId, "SevenPageMuda", mudaDuration)

end

--// Server_MudaEffect
function module.Server_MudaEffect(params)

    --print("SERVER MUDA", params)



end


return module