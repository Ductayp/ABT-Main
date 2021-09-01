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

local GHOST_DURATION = 5

local module = {}

module.InputBlockTime = 1

--// SERVER FUNCTIONS ----------------------------------------------------------------------------------------------------------------------

--// ServerSetup ------------------------------------------------------------------------------------
function module.Server_Setup(params, abilityDefs, initPlayer)

end

--// HitCharacter ------------------------------------------------------------------------------------
function module.HitCharacter(params, abilityDefs, initPlayer, hitCharacter, hitBox)

    abilityDefs.HitEffects = {
        GiveImmunity = {AbilityName = "SoulPunch", Duration = GHOST_DURATION + 1},
        Damage = {Damage = 10},
        ExtraDamage = {Duration = GHOST_DURATION, Value = 5},
        PinCharacter = {Duration = GHOST_DURATION},
        BlockAttacks = {Duration = GHOST_DURATION},
        RemoveStand = {},
        RunFunctions = {
            {RunOn = "Server", Script = script, FunctionName = "Server_GhostEffect", Arguments = {HitBoxCFrame = hitBox.CFrame}}
        },
    }

    Knit.Services.PowersService:RegisterHit(initPlayer, hitCharacter, abilityDefs)

end

--// Server_GhostEffect
function module.Server_GhostEffect(params)

    local originCFRame = params.HitCharacter.HumanoidRootPart.CFrame
    Knit.Services.PowersService:RenderAbilityEffect_AllPlayers(script, "Client_GhostEffect", params)

end

--// CLIENT FUNCTIONS --------------------------------------------------------------------------------------------------------------------

function module.Client_GhostEffect(params)

    print("GHOST EFFECTS START", params)

    if not params.HitCharacter then return end

    params.HitCharacter.Archivable = true

    AnchoredSound.NewSound(params.HitCharacter.HumanoidRootPart.Position, ReplicatedStorage.Audio.General.MagicBoom)

    local head1 = params.HitCharacter:FindFirstChild("Head", true)
    if head1 then

        local newSound1 = WeldedSound.NewSound(head1, ReplicatedStorage.Audio.General.EnergySource20sec, {SoundProperties = {PlaybackSpeed = 0.5}})


        local newParticles = ReplicatedStorage.EffectParts.Abilities.HeavyPunch.SoulPunch.Particles:Clone()
        newParticles.Parent = Workspace.RenderedEffects
        newParticles.Dark.Enabled = false
        newParticles.CFrame = head1.CFrame

        Debris:AddItem(newParticles, 20)
        utils.EasyWeld(newParticles, head1, newParticles)

        spawn(function()
            wait(GHOST_DURATION)
            newParticles.Burst:Emit(150)
            WeldedSound.NewSound(head1, ReplicatedStorage.Audio.General.MagicBoom)
            newParticles.Gold.Enabled = false
            newSound1:Destroy()
            wait(5)
            newParticles:Destroy()
        end)
        
    end

    local characterCopy = params.HitCharacter:Clone()

    for _, object in pairs(characterCopy:GetDescendants()) do

        if object:IsA("BasePart") or object:IsA("Decal") then
            if not object:FindFirstChild("Transparent", true) then
                if object.Name ~= "HumanoidRootPart" then
                    object.Transparency = .7
                end
            end

        end

        if object.Name == "DamageNumber" then
            object:Destroy()
        end
    end

    characterCopy.Parent = Workspace.RenderedEffects
    characterCopy.HumanoidRootPart.CFrame = params.HitCharacter.HumanoidRootPart.CFrame
    Debris:AddItem(characterCopy, GHOST_DURATION + 10) -- just in case

    local animator = characterCopy.Humanoid.Animator
    local animation = animator:LoadAnimation(ReplicatedStorage.EffectParts.Abilities.HeavyPunch.SoulPunch.GhostAnimation)
    animation:Play()

    local head2 = characterCopy:FindFirstChild("Head", true)
    if head2 then

        local newParticles = ReplicatedStorage.EffectParts.Abilities.HeavyPunch.SoulPunch.Particles:Clone()
        newParticles.Parent = head2
        newParticles.CFrame = head2.CFrame
        Debris:AddItem(newParticles, GHOST_DURATION + 10)

        utils.EasyWeld(newParticles, head2, newParticles)
        newParticles.Burst:Emit(200)

        local newBeam = ReplicatedStorage.EffectParts.Abilities.HeavyPunch.SoulPunch.Beam:Clone()
        newBeam.Parent = head2
        Debris:AddItem(newBeam, GHOST_DURATION + 10)

        local attach0 = Instance.new("Attachment")
        Debris:AddItem(attach0, GHOST_DURATION + 10)
        local attach1 = Instance.new("Attachment")
        Debris:AddItem(attach1, GHOST_DURATION + 10)

        attach0.Parent = head2
        attach1.Parent = head1

        newBeam.Attachment0 = attach0
        newBeam.Attachment1 = attach1

    end

    local locations = {
        [1] = "Head",
        [2] = "UpperTorso",
        [3] = "LeftLowerLeg",
        [4] = "RightLowerLeg",
        [5] = "LeftUpperArm",
        [6] = "RightUpperArm",
    }

    for count = 1,6 do

        local bodyPart = characterCopy:FindFirstChild(locations[count], true)

        local trail = ReplicatedStorage.EffectParts.Abilities.HeavyPunch.SoulPunch.Trail:Clone()
        trail.Parent = bodyPart
        trail.CFrame = bodyPart.CFrame
        --Debris:AddItem(trail, GHOST_DURATION + 10)

        utils.EasyWeld(trail, bodyPart, trail)
        
    end

    local destination = params.HitBoxCFrame:ToWorldSpace(CFrame.new(0,0,-15))

    characterCopy.HumanoidRootPart.Anchored = true

    local tween1 = TweenService:Create(characterCopy.HumanoidRootPart, TweenInfo.new(.3), {CFrame = CFrame.new(destination.Position, params.HitCharacter.HumanoidRootPart.Position)})
    tween1:Play()


    --[[
    tween1.Completed:Connect(function()
        wait()
        characterCopy.HumanoidRootPart.Anchored = false
    end)
    ]]--

    
    wait(GHOST_DURATION)

    if params.HitCharacter:FindFirstChild("HumanoidRootPart", true) then
        characterCopy.HumanoidRootPart.Anchored = true
        local tween2 = TweenService:Create(characterCopy.HumanoidRootPart, TweenInfo.new(.3), {CFrame = params.HitCharacter.HumanoidRootPart.CFrame})
        tween2:Play()
        tween2.Completed:Connect(function()
            characterCopy:Destroy()
        end)
    else
        characterCopy:Destroy()
    end

    

    

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







return module