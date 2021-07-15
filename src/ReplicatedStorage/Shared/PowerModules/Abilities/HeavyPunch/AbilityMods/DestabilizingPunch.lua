-- DestabilizingPunch

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local AnchoredSound = require(Knit.PowerUtils.AnchoredSound)
local ManageStand = require(Knit.Abilities.ManageStand)

local GHOST_DURATION = 7

local module = {}

--// ServerSetup ------------------------------------------------------------------------------------
function module.Server_Setup(params, abilityDefs, initPlayer)

end

--// HitCharacter ------------------------------------------------------------------------------------
function module.HitCharacter(params, abilityDefs, initPlayer, hitCharacter)

    
    abilityDefs.HitEffects = {
        GiveImmunity = {AbilityName = "DestabilizingPunch", Duration = GHOST_DURATION + 1},
        Damage = {Damage = 20},
        RemoveStand = {},
        RunFunctions = {
            {RunOn = "Server", Script = script, FunctionName = "Server_GhostEffect", Arguments = {}}
        },
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
    
        local shockTween = TweenService:Create(shockRing.Shock, TweenInfo.new(2), {Transparency = 1, Size = Vector3.new(5, 1.5, 5)})
        shockTween:Play()
        shockTween:Destroy()

        --[[
        local newBurst = ReplicatedStorage.EffectParts.Abilities.HeavyPunch.FatBurst:Clone()
        newBurst.Parent = Workspace.RenderedEffects
        Debris:AddItem(newBurst, 3)

        local burstWeld = Instance.new("Weld")
        burstWeld.C1 =  CFrame.new(0,0,10)
        burstWeld.Part0 = HRP
        burstWeld.Part1 = newBurst
        burstWeld.Parent = newBurst

        local burstTween = TweenService:Create(newBurst, TweenInfo.new(2),{Size = Vector3.new(3,3,3), Transparency = 1})
        burstTween:Play()
        burstTween:Destroy()
        ]]--
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

function module.Server_GhostEffect(params)

    if params.HitParams.IsMob then

        require(Knit.MobUtils.HideHealth).Hide_Duration(params.HitParams.MobId, GHOST_DURATION)
        require(Knit.MobUtils.BlockHits).Block_Duration(params.HitParams.MobId, GHOST_DURATION + 1)

    end

    local originCFRame = params.HitCharacter.HumanoidRootPart.CFrame

    params.HitCharacter.Archivable = true
    local characterCopy = params.HitCharacter:Clone()

    for _, object in pairs(characterCopy:GetDescendants()) do
        if object:IsA("BasePart") then
            object.Anchored = true
        end
    end

    local hitPlayer = utils.GetPlayerFromCharacter(params.HitCharacter)
    if hitPlayer then

        local playerProxy = Instance.new("ObjectValue")
        playerProxy.Value = hitPlayer
        playerProxy.Name = "PlayerProxy"
        playerProxy.Parent = characterCopy
        
    end

    characterCopy.Parent = Workspace.RenderedEffects

    for _, object in pairs(params.HitCharacter:GetDescendants()) do
        if object:IsA("BasePart") then
            if object.Name ~= "HumanoidRootPart" then
                object.Transparency = .8
            end
        end
    end

    local invulnerableBool_2 = Instance.new("BoolValue")
    invulnerableBool_2.Value = true
    invulnerableBool_2.Name = "Invulnerable_HitEffect"
    invulnerableBool_2.Parent = params.HitCharacter.HumanoidRootPart

    local effectParams = {}
    effectParams.CharacterCopy = characterCopy
    effectParams.HitCharacter =  params.HitCharacter
    Knit.Services.PowersService:RenderAbilityEffect_AllPlayers(script, "Client_GhostEffect", effectParams)

    wait(GHOST_DURATION)

    if params.HitCharacter then

        if params.HitCharacter:FindFirstChild("HumanoidRootPart") then
            params.HitCharacter.HumanoidRootPart.CFrame = originCFRame
            params.HitCharacter.Humanoid.Health = characterCopy.Humanoid.Health
        end

        invulnerableBool_2:Destroy()

        for _, object in pairs(params.HitCharacter:GetDescendants()) do
            if object:IsA("BasePart") then
                if object.Name ~= "HumanoidRootPart" then
                    object.Transparency = 0
                end
            end
        end
    end
    
    characterCopy:Destroy()
    
end

function module.Client_GhostEffect(params)

    print("GHOST EFFECTS", params)

    if not params.CharacterCopy then return end
    if not params.HitCharacter then return end

    print("YES")

    AnchoredSound.NewSound(params.HitCharacter.HumanoidRootPart.Position, ReplicatedStorage.Audio.General.LaserBeamDescend)

    --[[
    spawn(function()

        wait(GHOST_DURATION)

    end)
    ]]--

end



return module