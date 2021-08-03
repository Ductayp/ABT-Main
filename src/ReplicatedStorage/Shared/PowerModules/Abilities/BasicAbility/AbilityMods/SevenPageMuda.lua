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

local module = {}

local initPlayerTracker = {}

local mudaDuration = 7

local HITBOX_DELAY = .2
local HITBOX_DURATION = .5
local HITBOX_SIZE = Vector3.new(6, 5, 12)
local HITBOX_OFFSET = CFrame.new(0, 0, 6)

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

    wait(module.MobilityLockParams.Duration + .1)

    ManageStand.StopAnimation(params, "Point")
    ManageStand.MoveStand(params, "Idle")
    ManageStand.Aura_Off(params)

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

    print("MUDA EFFECT PARAMS", params)

end

------------------------------------------------------------------------------------------------------------------
--// SERVER FUNTIONS ---------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------

--// Server_Setup
function module.Server_Setup(params, abilityDefs, initPlayer)



end

--// Server_Run
function module.Server_Run(params, abilityDefs, initPlayer)

    local thisHRP = initPlayer.Character.HumanoidRootPart
    if not thisHRP then return end

    -- hitbox
	local hitBox = Instance.new("Part")
    hitBox.CanCollide = false
    hitBox.Massless = true
	hitBox.Size = HITBOX_SIZE
	hitBox.Transparency = .7
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

        hitBox.Color = Color3.fromRGB(232, 99, 255)

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

    abilityDefs.HitEffects = {Teleport = {TargetPosition = params.PinCFrame.Position}}
    Knit.Services.PowersService:RegisterHit(initPlayer, hitCharacter, abilityDefs)

    abilityDefs.HitEffects = {
        Damage = {Damage = 1},
        PinCharacter = {Duration = mudaDuration},
        RunFunctions = {
            {RunOn = "Server", Script = script, FunctionName = "Server_MudaEffect", Arguments = {InitPlayer = initPlayer, HitCharacter = hitCharacter}}
        },
    }
    local canHit = Knit.Services.PowersService:RegisterHit(initPlayer, hitCharacter, abilityDefs)

    -- handle initPlayer, this will fire ONCE for the intiPlayer and ONLY if they hit another character
    if not canHit then return end
    if initPlayerTracker[initPlayer.UserId] then return end

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

    Knit.Services.PowersService:RenderAbilityEffect_SinglePlayer(initPlayer, script, "Client_MudaEffect", params)

end

--// Server_MudaEffect
function module.Server_MudaEffect(params)

    print("SERVER MUDA", params)

end


return module