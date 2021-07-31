-- SoulPunch

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local AnchoredSound = require(Knit.PowerUtils.AnchoredSound)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)
local ManageStand = require(Knit.Abilities.ManageStand)

local GHOST_DURATION = 7

local module = {}

--// ServerSetup ------------------------------------------------------------------------------------
function module.Server_Setup(params, abilityDefs, initPlayer)

end

--// HitCharacter ------------------------------------------------------------------------------------
function module.HitCharacter(params, abilityDefs, initPlayer, hitCharacter)

    abilityDefs.HitEffects = {
        Slow = {WalkSpeedModifier = -11, Duration = 7},
        RunFunctions = {
            {RunOn = "Client", Script = script, FunctionName = "WitherEffects", Arguments = {HitCharacter = hitCharacter}}
        }
    }

    Knit.Services.PowersService:RegisterHit(initPlayer, hitCharacter, abilityDefs)

    spawn(function()
        abilityDefs.HitEffects = {
            Damage = {Damage = 4, HideEffects = true},
            LifeSteal = {Quantity = 2},
        }
        for count = 1, 7 do
            Knit.Services.PowersService:RegisterHit(initPlayer, hitCharacter, abilityDefs)
            wait(1)
        end
    end)

end

--// Client_Initialize ------------------------------------------------------------------------------------
function module.Client_Initialize(params, abilityDefs, initPlayer)

end

--// Client_Stage1 ------------------------------------------------------------------------------------
function module.Client_StandAnimations(params, abilityDefs, initPlayer)

    spawn(function() 

        local targetStand = Workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
        if not targetStand then
            targetStand = ManageStand.QuickRender(params)
        end

        ManageStand.MoveStand(params, "Front")
        ManageStand.PlayAnimation(params, "HeavyPunch")
        ManageStand.Aura_On(params)
        wait(1)
        ManageStand.MoveStand(params, "Idle")
        wait(1)
        ManageStand.Aura_Off(params)

    end)

end

--// Client_Animation_A ------------------------------------------------------------------------------------
function module.Client_Animation_A(params, abilityDefs, initPlayer)

    spawn(function()

        local initCharacter = initPlayer.Character
        if not initCharacter then return end
        local HRP = initCharacter:FindFirstChild("HumanoidRootPart")
        if not HRP then return end
    
        AnchoredSound.NewSound(HRP.Position, ReplicatedStorage.Audio.Abilities.HeavyPunch)
    
        local shockRing = ReplicatedStorage.EffectParts.Abilities.HeavyPunch.Shock:Clone()
        shockRing.Parent = Workspace.RenderedEffects
        Debris:AddItem(shockRing, 3)
    
        local shockWeld = Instance.new("Weld")
        shockWeld.C1 =  CFrame.new(0,0,9)
        shockWeld.Part0 = HRP
        shockWeld.Part1 = shockRing
        shockWeld.Parent = shockRing
    
        local shockTween = TweenService:Create(shockRing.Shock, TweenInfo.new(1), {Transparency = 1, Size = Vector3.new(5, 1.5, 5)})
        shockTween:Play()
        shockTween:Destroy()

    end)

end


--// Client_Animation_B ------------------------------------------------------------------------------------
function module.Client_Animation_B(params, abilityDefs, initPlayer)

    spawn(function() 

        local initCharacter = initPlayer.Character
        if not initCharacter then return end
        local HRP = initCharacter:FindFirstChild("HumanoidRootPart")
        if not HRP then return end
    
        local fastBall = ReplicatedStorage.EffectParts.Abilities.HeavyPunch.FastBall:Clone()
        fastBall.Parent = Workspace.RenderedEffects
        Debris:AddItem(fastBall, 3)

        local ballWeld = Instance.new("Weld")
        ballWeld.C1 =  CFrame.new(0,0,8)
        ballWeld.Part0 = HRP
        ballWeld.Part1 = fastBall
        ballWeld.Parent = fastBall

        local ballTrans = TweenService:Create(fastBall.Fireball, TweenInfo.new(.5), {Transparency = 1})
        local ballMove = TweenService:Create(ballWeld, TweenInfo.new(.5), {C1 = CFrame.new( 0, 0, 12)})

        ballTrans:Play()
        ballMove:Play()

    end)

end

function module.WitherEffects(functionParams)

    if not functionParams.HitCharacter and functionParams.HitCharacter.HumanoidRootPart then return end

    local redParticle = ReplicatedStorage.EffectParts.Abilities.HeavyPunch.WitherPunch.RedParticle:Clone()
    local blackParticle = ReplicatedStorage.EffectParts.Abilities.HeavyPunch.WitherPunch.BlackParticle:Clone()

    redParticle.Parent = functionParams.HitCharacter.HumanoidRootPart
    blackParticle.Parent = functionParams.HitCharacter.HumanoidRootPart

    wait(7)

    redParticle.Enabled = false
    blackParticle.Enabled = false

    wait(10)

    redParticle:Destroy()
    blackParticle:Destroy()

end

return module