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
--local MobAnimations = require(Knit.MobUtils.MobAnimations)

local healAmount = 7
local healDuration = 7

local module = {}

module.InputBlockTime = 1

-- MobilityLock params
module.MobilityLockParams = {}
module.MobilityLockParams.Duration = 0
module.MobilityLockParams.ShiftLock_NoSpin = true
module.MobilityLockParams.AnchorCharacter = true

local HIT_DURATION = 6
local EFFECT_DURATION = 5
local RANGE = 3
local HIT_DELAY = 0

--// Server_Setup
function module.Server_Setup(params, abilityDefs, initPlayer)


end

--// Server_Run
function module.Server_Run(params, abilityDefs, initPlayer)

    if not initPlayer then return end

    local character = initPlayer.Character
    if not character then return end

    local HRP = character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end

    local endTime = os.clock() + HIT_DURATION

    while os.clock() < endTime do

        hitCharacters = TargetByZone.GetAllInRange(initPlayer, HRP.Position, RANGE, true)

        for _, character in pairs(hitCharacters) do

            if not character:FindFirstChild("Flag_OrganInversion", true) then

                spawn(function()
                    local newFlag = Instance.new("BoolValue")
                    newFlag.Name = "Flag_OrganInversion"
                    newFlag.Parent = character
                    wait(HIT_DURATION + 1)
                    newFlag:Destroy()
                end)

                abilityDefs.HitEffects = {
                    RunFunctions = {
                        Damage = {Damage = 30},
                        {RunOn = "Client", Script = script, FunctionName = "Client_InversionEffect", Arguments = {HitCharacter = character}},
                    },
                }

                Knit.Services.PowersService:RegisterHit(initPlayer, character, abilityDefs)

            end
        end
        
        wait(.1)

    end

end

function module.Client_InversionEffect(params)

    if not params.HitCharacter then return end
    local HRP = params.HitCharacter:FindFirstChild("HumanoidRootPart")
    if not HRP then return end

    spawn(function()

        local endTime = os.clock() + EFFECT_DURATION - 1
        while os.clock() < endTime do

            local ball = ReplicatedStorage.EffectParts.Abilities.BasicAbility.GravityShift.Ball:Clone()
            ball.CFrame = HRP.CFrame
            ball.Parent = Workspace.RenderedEffects

            local moveTween = TweenService:Create(ball,TweenInfo.new(1), {Position = ball.Position + Vector3.new(0,5,0), Transparency = 1, Size = Vector3.new(1,1,1)})
            moveTween.Completed:Connect(function()
                ball:Destroy()
            end)
            moveTween:Play()

            wait(.25)
        end

    end)

end

function module.Client_Initialize(params, abilityDefs, delayOffset)

    --[[
    spawn(function()
        Knit.Controllers.PlayerUtilityController.PlayerAnimations.Rage:Play()
        wait(2)
        Knit.Controllers.PlayerUtilityController.PlayerAnimations.Rage:Stop()
    end)
    ]]--

    
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


        wait(HIT_DURATION)
        floorDisc:Destroy()

    end)


end

--// Client_Stage_2
function module.Client_Stage_2(params, abilityDefs, initPlayer)

    local character = initPlayer.Character
    if not character then return end

    local HRP = character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end

    local endTime = os.clock() + 5.5
    while os.clock() < endTime do

        local shockRing = ReplicatedStorage.EffectParts.Abilities.BasicAbility.GravityShift.RingAssembly:Clone()
        --shockRing.Ring_Mesh.Size = Vector3.new(.1,.4,.1)
        shockRing.Parent = Workspace.RenderedEffects
        shockRing.CFrame = HRP.CFrame

        local newWeld = Instance.new("Weld")
        newWeld.C1 =  CFrame.new(0, 0, 0)
        newWeld.Part0 = shockRing
        newWeld.Part1 = HRP
        newWeld.Parent = shockRing

        local moveTween = TweenService:Create(newWeld,TweenInfo.new(1),{C1 = CFrame.new(0,2,0)})
        moveTween.Completed:Connect(function()
            shockRing:Destroy()
        end)
        
        local transTween = TweenService:Create(shockRing.Ring_Mesh,TweenInfo.new(1),{Transparency = 1})

        moveTween:Play()
        transTween:Play()

        wait(.25)

    end

end


return module