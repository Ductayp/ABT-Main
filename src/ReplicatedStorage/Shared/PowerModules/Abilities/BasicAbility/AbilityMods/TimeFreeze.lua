-- BlackHole

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")

local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)
local AnchoredSound = require(Knit.PowerUtils.AnchoredSound)
local ManageStand = require(Knit.Abilities.ManageStand)
local TargetByZone = require(Knit.PowerUtils.TargetByZone)

local RANGE = 80
local EFFECT_DELAY = 2
local DURATION = 7


local module = {}

-- MobilityLock params
module.MobilityLockParams = {}
module.MobilityLockParams.Duration = 2.5
module.MobilityLockParams.ShiftLock_NoSpin = true
module.MobilityLockParams.AnchorCharacter = true


--// Server_Setup
function module.Server_Setup(params, abilityDefs, initPlayer)

end

--// Server_Run
function module.Server_Run(params, abilityDefs, initPlayer)

    spawn(function()

        local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
        if not initPlayer then return end
        if not initPlayer.Character then return end
    
        local dayCycle = Knit.Services.EnvironmentService.CurrentCycle
    
        wait(EFFECT_DELAY)
    
        local hitPlayers = TargetByZone.GetPlayers(initPlayer, params.Origin, RANGE, true)
        local hitCharacters = TargetByZone.GetAllInRange(initPlayer, params.Origin, RANGE, true)

        -- set HitEffects to ColorShift function only
        abilityDefs.HitEffects = {
            RenderEffects = {
                {Script = script, Function = "ColorShiftEffect", Arguments = {DayCycle = dayCycle}}
            }
        }
        
        -- run colorshift on intiPlayer
        Knit.Services.PowersService:RegisterHit(initPlayer, initPlayer.Character, abilityDefs)

        -- run other effects for all hitCharacters
        for _, character in pairs(hitCharacters) do

            abilityDefs.HitEffects = {
                RenderEffects = {
                    {Script = script, Function = "ColorShiftEffect", Arguments = {DayCycle = dayCycle}},
                    {Script = script, Function = "FreezeEffect", Arguments = {HitCharacter = character}}
                },
                Damage = {Damage = 1},
                PinCharacter = {Duration = DURATION},
            }

            Knit.Services.PowersService:RegisterHit(initPlayer, character, abilityDefs)
        end

    end)

end

function module.Client_Initialize(params, abilityDefs, delayOffset)

    local character = Players.LocalPlayer.Character
    if not character and character.HumanoidRootPart then return end
    params.Origin = character.HumanoidRootPart.Position


    spawn(function()

        Knit.Controllers.PlayerUtilityController.PlayerAnimations.PowerPose1:Play()
        wait(module.MobilityLockParams.Duration)
        Knit.Controllers.PlayerUtilityController.PlayerAnimations.PowerPose1:Stop()

    end)

end


--// Client_Stage_1
function module.Client_Stage_1(params, abilityDefs, delayOffset)

    spawn(function()

        local targetStand = Workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
        if not targetStand then
            targetStand = ManageStand.QuickRender(params)
        end
    
        local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
        if not initPlayer then return end
        if not initPlayer.Character then return end

        ManageStand.PlayAnimation(params, "TimeStop")
        ManageStand.Aura_On(params, 6)

        -- play the sound
        AnchoredSound.NewSound(params.Origin, ReplicatedStorage.Audio.StandSpecific.TheWorld.TimeStop)


    end)
 
end

--// Client_Stage_2
function module.Client_Stage_2(params, abilityDefs, initPlayer)

   spawn(function()
        -- animate spheres
        local sphereParams = {}
        sphereParams.CFrame = CFrame.new(params.Origin)
        sphereParams.Size = Vector3.new(1,1,1)
        sphereParams.Shape = "Ball"
        sphereParams.Parent = workspace.RenderedEffects
        sphereParams.Anchored = true
        sphereParams.CanCollide = false
        sphereParams.Transparency = -.5
        sphereParams.Material = Enum.Material.ForceField
        sphereParams.CastShadow = false

        local sphere1 = utils.EasyInstance("Part", sphereParams)
        local sphere2 = utils.EasyInstance("Part", sphereParams)
        local sphere3 = utils.EasyInstance("Part", sphereParams)

        sphere1.Color = Color3.fromRGB(255, 255, 255)
        sphere2.Color = Color3.fromRGB(114, 236, 236)
        sphere3.Color = Color3.fromRGB(76, 76, 255)
        
        Debris:AddItem(sphere1, abilityDefs.Duration)
        Debris:AddItem(sphere2, abilityDefs.Duration)
        Debris:AddItem(sphere3, abilityDefs.Duration)


        local size = RANGE * 2

        local tweenInfo = TweenInfo.new(
            1, -- Time
            Enum.EasingStyle.Linear, -- EasingStyle
            Enum.EasingDirection.In -- EasingDirection
        )

        local sphereTween1 = TweenService:Create(sphere1,tweenInfo,{Size = Vector3.new(size,size,size)})
        local sphereTween2 = TweenService:Create(sphere2,tweenInfo,{Size = Vector3.new(size,size,size)})
        local sphereTween3 = TweenService:Create(sphere3,tweenInfo,{Size = Vector3.new(size,size,size)})
        sphereTween1:Play()
        wait(.005)
        sphereTween2:Play()
        wait(.005)
        sphereTween3:Play()

        wait(2)

        local tweenInfo = TweenInfo.new(
            .25, -- Time
            Enum.EasingStyle.Linear, -- EasingStyle
            Enum.EasingDirection.Out -- EasingDirection
        )

        local sphereTween4 = TweenService:Create(sphere1,tweenInfo,{Size = Vector3.new(1,1,1)})
        local sphereTween5 = TweenService:Create(sphere2,tweenInfo,{Size = Vector3.new(1,1,1)})
        local sphereTween6 = TweenService:Create(sphere3,tweenInfo,{Size = Vector3.new(1,1,1)})

        sphereTween6.Completed:Connect(function(playbackState)
            if playbackState == Enum.PlaybackState.Completed then
                sphere1:Destroy()
                sphere2:Destroy()
                sphere3:Destroy()
            end
        end)

        sphereTween4:Play()
        wait(.005)
        sphereTween5:Play()
        wait(.005)
        sphereTween6:Play()

    end)

end


function module.ColorShiftEffect(params)

    if Lighting:FindFirstChild("New_ColorCorrection") then return end

    local originalColorCorrection = Lighting:FindFirstChild("ColorCorrection_Main")
    local originalContrast = originalColorCorrection.Contrast

    local newColorCorrection = originalColorCorrection:Clone()
    newColorCorrection.Name = "New_ColorCorrection"
    newColorCorrection.Parent = Lighting

    local targetBrightness
    if params.DayCycle == "Day" then
        targetBrightness = 0
    else
        targetBrightness = -0.5
    end

    local colorTween1 = TweenService:Create(newColorCorrection,TweenInfo.new(.5),{Contrast = -3, Brightness = targetBrightness, TintColor = Color3.fromRGB(0, 209, 255)})
    colorTween1:Play()

    originalColorCorrection.Enabled = false

    wait(DURATION)

    local colorTween2 = TweenService:Create(newColorCorrection,TweenInfo.new(.5),{Contrast = originalContrast})
    colorTween2:Play()

    wait(.5)

    originalColorCorrection.Enabled = true
    newColorCorrection:Destroy()

end

function module.FreezeEffect(params)

    if not params.HitCharacter and params.HitCharacter.HumanoidRootPart then
        return
    end

    WeldedSound.NewSound(params.HitCharacter.HumanoidRootPart, ReplicatedStorage.Audio.General.Freeze)
    
    local icePart = ReplicatedStorage.EffectParts.Abilities.BasicAbility.TimeFreeze.Ice:Clone()
    icePart.CFrame = params.HitCharacter.HumanoidRootPart.CFrame
    icePart.Parent = Workspace.RenderedEffects

    icePart.BurstEmitter:Emit(100)
    
    icePart.Transparency = 1
    local tweenIn_1 = TweenService:Create(icePart, TweenInfo.new(.5),{Transparency = .6})
    tweenIn_1:Play()

    wait(DURATION)

    --icePart.Anchored = true
    local tweenOut_1 = TweenService:Create(icePart, TweenInfo.new(1),{Size = Vector3.new(2,2,2)})
    local tweenOut_2 = TweenService:Create(icePart, TweenInfo.new(1),{Position = icePart.Position + Vector3.new(0,-10,0)})
    tweenOut_1:Play()
    tweenOut_2:Play()
    wait(2)
    icePart:Destroy()

end


return module