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

local healAmount = 7
local healDuration = 7

local module = {}

module.InputBlockTime = 1

-- MobilityLock params
module.MobilityLockParams = {}
module.MobilityLockParams.Duration = 0
module.MobilityLockParams.ShiftLock_NoSpin = true
module.MobilityLockParams.AnchorCharacter = true

local TICK_COUNT = 24
local TICK_DURATION = .25
local EFFECT_DURATION = 5
local RANGE = 10
local HIT_DELAY = .4

--// Server_Setup
function module.Server_Setup(params, abilityDefs, initPlayer)


end

--// Server_Run
function module.Server_Run(params, abilityDefs, initPlayer)

    print("SERVER")

    wait(HIT_DELAY)

    local duration = TICK_COUNT * TICK_DURATION
    for count = 1, TICK_COUNT do



        local hitCharacters = TargetByZone.GetAllInRange(initPlayer, params.InitPlayerCFrame.Position, RANGE, true)
        for _, character in pairs(hitCharacters) do

            if not character:FindFirstChild("Flag_GravityShift", true) then

                spawn(function()
                    local newFlag = Instance.new("BoolValue")
                    newFlag.Name = "Flag_GravityShift"
                    newFlag.Parent = character
                    wait(EFFECT_DURATION)
                    newFlag:Destroy()
                end)

                abilityDefs.HitEffects = {
                    Damage = {Damage = 1},
                    PinCharacter = {Duration = duration},
                }

                Knit.Services.PowersService:RegisterHit(initPlayer, character, abilityDefs)


                abilityDefs.HitEffects = {
                    RunFunctions = {
                        {RunOn = "Server", Script = script, FunctionName = "Server_GravityEffect", Arguments = {HitCharacter = character}},
                        {RunOn = "Client", Script = script, FunctionName = "Client_GravityEffect", Arguments = {HitCharacter = character}},
                    },
                }

                Knit.Services.PowersService:RegisterHit(initPlayer, character, abilityDefs)

            end
        end

        wait(TICK_DURATION)

    end

end

function module.Server_GravityEffect(params)

    if not params.HitCharacter then return end
    local HRP = params.HitCharacter:FindFirstChild("HumanoidRootPart")
    if not HRP then return end

    HRP.Anchored = true
    spawn(function()
        wait(TICK_COUNT * TICK_DURATION)
        HRP.Anchored = false
    end)

    local floatTween = TweenService:Create(HRP, TweenInfo.new(.5), {CFrame = HRP.CFrame:ToWorldSpace(CFrame.new(0,3,0))})
    floatTween:Play()

end

function module.Client_Initialize(params, abilityDefs, delayOffset)

    local character = Players.LocalPlayer.Character
    if not character and character.HumanoidRootPart then return end

    params.InitPlayerCFrame = character.HumanoidRootPart.CFrame

    spawn(function()
        Knit.Controllers.PlayerUtilityController.PlayerAnimations.Rage:Play()
        wait(2)
        Knit.Controllers.PlayerUtilityController.PlayerAnimations.Rage:Stop()
    end)

    
end


--// Client_Stage_1
function module.Client_Stage_1(params, abilityDefs, initPlayer)

    local character = initPlayer.Character
    if not character then return end
    
    local HRP = character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end

    local targetStand = Workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
    if not targetStand then
        targetStand = ManageStand.QuickRender(params)
    end

    WeldedSound.NewSound(targetStand.HumanoidRootPart, ReplicatedStorage.Audio.General.PulseRay6)

    local duration = TICK_COUNT * TICK_DURATION

    spawn(function()

        ManageStand.Aura_On(params)
        ManageStand.MoveStand(params, "IdleHigh")
        ManageStand.PlayAnimation(params, "CastOnUser")
        wait(2)
        ManageStand.StopAnimation(params, "CastOnUser")
        ManageStand.MoveStand(params, "Idle")
        ManageStand.Aura_Off(params)

    end)

    spawn(function()

        local floorDisc = ReplicatedStorage.EffectParts.Abilities.BasicAbility.GravityShift.DiscAssembly:Clone()
        floorDisc.Parent = Workspace.RenderedEffects
        floorDisc.CFrame = HRP.CFrame

        local newWeld = Instance.new("Weld")
        newWeld.C1 = CFrame.new(0, 0, 0)
        newWeld.Part0 = floorDisc
        newWeld.Part1 = HRP
        newWeld.Parent = floorDisc

        wait(duration)
        floorDisc:Destroy()
    
    end)

    --[[
    spawn(function()

        local shockWave = ReplicatedStorage.EffectParts.Abilities.BasicAbility.GravityShift.Shockwave:Clone()
        shockWave.Parent = Workspace.RenderedEffects
        shockWave.CFrame = HRP.CFrame

        for count = 1, TICK_COUNT do

            local shockWave = ReplicatedStorage.EffectParts.Abilities.BasicAbility.GravityShift.Shockwave:Clone()
            shockWave.Parent = Workspace.RenderedEffects
            shockWave.CFrame = HRP.CFrame

            local newWeld = Instance.new("Weld")
            newWeld.C1 = CFrame.new(0, -3, 0)
            newWeld.Part0 = HRP
            newWeld.Part1 = shockWave
            newWeld.Parent = shockWave

            local moveTween = TweenService:Create(newWeld, TweenInfo.new(TICK_DURATION), {C1 = CFrame.new(0, 1, 0)})
            moveTween.Completed:Connect(function()
                newWeld:Destroy()
            end)
            moveTween:Play()

            
            local transTween = TweenService:Create(shockWave, TweenInfo.new(TICK_DURATION), {Transparency = 1})
            transTween:Play()

            wait(TICK_DURATION)
        end

    end)

    ]]--



end

--// Client_Stage_2
function module.Client_Stage_2(params, abilityDefs, initPlayer)

    local character = initPlayer.Character
    if not character then return end

    local HRP = character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end

    for count = 1, TICK_COUNT do

        local shockAssembly = ReplicatedStorage.EffectParts.Abilities.BasicAbility.GravityShift.ShockAssembly:Clone()
        shockAssembly.Parent = Workspace.RenderedEffects
        shockAssembly.CFrame = HRP.CFrame

        local newWeld = Instance.new("WeldConstraint")
        newWeld.Parent = shockAssembly
        newWeld.Part0 = HRP
        newWeld.Part1 = shockAssembly

        local shockRing = ReplicatedStorage.EffectParts.Abilities.BasicAbility.GravityShift.ShockAssembly.ShockRing:Clone()
        shockRing.CFrame = shockAssembly.CFrame
        shockRing.Parent = shockAssembly

        local motor = Instance.new("Motor6D")
        motor.Part0 =  shockAssembly
        motor.Part1 = shockRing
        motor.C0 = CFrame.new(0, 0, 0)
        motor.Parent = shockRing

        --[[
        local shockRing = ReplicatedStorage.EffectParts.Abilities.BasicAbility.GravityShift.ShockRing:Clone()
        shockRing.CFrame = HRP.CFrame
        shockRing.Parent = HRP

        local motor = Instance.new("Motor6D")
        motor.Part0 =  HRP
        motor.Part1 = shockRing
        motor.C0 = CFrame.new(0, 0, 0)
        motor.Parent = shockRing

        local moveTween = TweenService:Create(motor, TweenInfo.new(TICK_DURATION), {C0 = CFrame.new(0, 3, 0)})
        moveTween.Completed:Connect(function()
            --shockAssembly:Destroy()
        end)
        moveTween:Play()
        ]]--
        
        --[[
        local shockAssembly = ReplicatedStorage.EffectParts.Abilities.BasicAbility.GravityShift.ShockAssembly:Clone()
        shockAssembly.Motor6D.C0 = CFrame.new(0, -3, 0)
        shockAssembly.Parent = Workspace.RenderedEffects
        shockAssembly.CFrame = HRP.CFrame

        local newWeld = Instance.new("WeldConstraint")
        newWeld.Parent = shockAssembly
        newWeld.Part0 = HRP
        newWeld.Part1 = shockAssembly

        print("beep")
        
        local moveTween = TweenService:Create(shockAssembly.Motor6D, TweenInfo.new(TICK_DURATION), {C0 = CFrame.new(0, 0, 0)})
        moveTween.Completed:Connect(function()
            --shockAssembly:Destroy()
        end)
        moveTween:Play()
        ]]--

        
        --[[
        local transTween = TweenService:Create(shockWave, TweenInfo.new(TICK_DURATION), {Transparency = 1})
        transTween:Play()
        ]]--


        wait(TICK_DURATION)

    end




end


return module