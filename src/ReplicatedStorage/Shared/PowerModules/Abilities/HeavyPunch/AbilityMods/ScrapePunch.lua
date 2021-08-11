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

local module = {}

module.InputBlockTime = 1

--// ServerSetup ------------------------------------------------------------------------------------
function module.Server_Setup(params, abilityDefs, initPlayer)

end

--// HitCharacter ------------------------------------------------------------------------------------
function module.HitCharacter(params, abilityDefs, initPlayer, hitCharacter)
    
    abilityDefs.HitEffects = {
        Damage = {Damage = 20},
        PinCharacter = {Duration = 5.2},
        Invulnerable = {Duration = 5},
        RemoveStand = {},
        HideCharacter = {Duration = 5},
        RunFunctions = {
            {
                RunOn = "Client",
                Script = script, FunctionName = "BlackHole",
                Arguments = {Position = hitCharacter.HumanoidRootPart.Position, HitCharacter = hitCharacter}
            }
        }
    }
    Knit.Services.PowersService:RegisterHit(initPlayer, hitCharacter, abilityDefs)

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

        local scrapeAssembly = ReplicatedStorage.EffectParts.Abilities.HeavyPunch.ScrapePunch.Scrape:Clone()
        scrapeAssembly.Parent = Workspace.RenderedEffects
        Debris:AddItem(scrapeAssembly, 3)

        local scrapeWeld = Instance.new("Weld")
        scrapeWeld.C1 =  CFrame.new(0,0,8)
        scrapeWeld.Part0 = HRP
        scrapeWeld.Part1 = scrapeAssembly
        scrapeWeld.Parent = scrapeAssembly

        local scrapeTrans_1 = TweenService:Create(scrapeAssembly.Main, TweenInfo.new(.5), {Transparency = 1})
        local scrapeTrans_2 = TweenService:Create(scrapeAssembly.Left, TweenInfo.new(.5), {Transparency = 1})
        local scrapeTrans_3 = TweenService:Create(scrapeAssembly.Right, TweenInfo.new(.5), {Transparency = 1})
        local scrapeMove = TweenService:Create(scrapeWeld, TweenInfo.new(.5), {C1 = CFrame.new( 0, 0, 12)})

        scrapeTrans_1:Play()
        scrapeTrans_2:Play()
        scrapeTrans_3:Play()
        scrapeMove:Play()

    end)

end

function module.BlackHole(params)

    --AnchoredSound.NewSound(params.TargetPosition, ReplicatedStorage.Audio.General.MagicBoom)
    local droneSound = AnchoredSound.NewSound(params.Position, ReplicatedStorage.Audio.General.EnergySource20sec)
    AnchoredSound.NewSound(params.Position, ReplicatedStorage.Audio.General.PowerUpStinger3)

    -- setup black hole parts
    local blackHoleParts = {
        newBlackBall = ReplicatedStorage.EffectParts.Abilities.HeavyPunch.ScrapePunch.BlackBall:Clone(),
        newWhisps = ReplicatedStorage.EffectParts.Abilities.HeavyPunch.ScrapePunch.Whisps:Clone(),
        newParticle = ReplicatedStorage.EffectParts.Abilities.HeavyPunch.ScrapePunch.Particle:Clone(),
    }
    blackHoleParts.newWhisps.BodyPosition.Position = params.Position

    -- render black hole parts
    for i,v in pairs (blackHoleParts) do
        v.CFrame = CFrame.new(params.Position)
        v.Parent = Workspace.RenderedEffects
    end

    local newBurst = ReplicatedStorage.EffectParts.Abilities.HeavyPunch.ScrapePunch.Burst:Clone()
    newBurst.CFrame = CFrame.new(params.Position)
    newBurst.Parent = Workspace.RenderedEffects
    newBurst.Pop:Emit(50)

    wait(5)

    droneSound:Destroy()
    AnchoredSound.NewSound(params.Position, ReplicatedStorage.Audio.General.MagicBoom)

    newBurst.Pop:Emit(50)
    newBurst.Purple.Enabled = false
    Debris:AddItem(newBurst, 5)

    blackHoleParts.newBlackBall:Destroy()
    blackHoleParts.newWhisps:Destroy()
    blackHoleParts.newParticle.ParticleEmitter.Enabled = false
    Debris:AddItem(blackHoleParts.newParticle, 3)

end


return module