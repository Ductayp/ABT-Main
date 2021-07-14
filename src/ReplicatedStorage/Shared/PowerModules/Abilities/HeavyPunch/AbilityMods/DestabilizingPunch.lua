-- DestabilizingPunch

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local AnchoredSound = require(Knit.PowerUtils.AnchoredSound)
local ManageStand = require(Knit.Abilities.ManageStand)

local module = {}

--// ServerSetup ------------------------------------------------------------------------------------
function module.Server_Setup(params, abilityDefs, initPlayer)

end

--// HitCharacter ------------------------------------------------------------------------------------
function module.HitCharacter(params, abilityDefs, initPlayer, hitCharacter)

    
    abilityDefs.HitEffects = {
        RunFunctions = {
            {RunOn = "Server", Script = script, FunctionName = "Server_GhostEffect", Arguments = {}},
            {RunOn = "Client", Script = script, FunctionName = "Client_GhostEffect", Arguments = {}}
        },
        Damage = {Damage = 20},
        RemoveStand = {},
    }

    Knit.Services.PowersService:RegisterHit(initPlayer, hitCharacter, abilityDefs)

end

--// Client_Initialize ------------------------------------------------------------------------------------
function module.Client_Initialize(params, abilityDefs, initPlayer)

end

--// Client_Stage1 ------------------------------------------------------------------------------------
function module.Client_Stage_1(params, abilityDefs, initPlayer)

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

end

--// Client_Stage2 ------------------------------------------------------------------------------------
function module.Client_Stage_2(params, abilityDefs, initPlayer)

    local initCharacter = initPlayer.Character
    if not initCharacter then return end
    local HRP = initCharacter:FindFirstChild("HumanoidRootPart")
    if not HRP then return end
 
    AnchoredSound.NewSound(HRP.Position, ReplicatedStorage.Audio.Abilities.HeavyPunch)

    local fastBall = ReplicatedStorage.EffectParts.Abilities.HeavyPunch.FastBall:Clone()
    fastBall.Parent = Workspace.RenderedEffects
    --fastBall.CFrame = HRP.CFrame:ToWorldSpace(CFrame.new(0,0,-9))
    Debris:AddItem(fastBall, 3)

    local ballWeld = Instance.new("Weld")
	ballWeld.C1 =  CFrame.new(0,0,8)
	ballWeld.Part0 = HRP
	ballWeld.Part1 = fastBall
	ballWeld.Parent = fastBall


    local shockRing = ReplicatedStorage.EffectParts.Abilities.HeavyPunch.Shock:Clone()
    --shockRing.CFrame = HRP.CFrame:ToWorldSpace(CFrame.new(0,0,-9))
    shockRing.Parent = Workspace.RenderedEffects
    Debris:AddItem(shockRing, 3)

    local shockWeld = Instance.new("Weld")
	shockWeld.C1 =  CFrame.new(0,0,9)
	shockWeld.Part0 = HRP
	shockWeld.Part1 = shockRing
	shockWeld.Parent = shockRing

    local ballTrans = TweenService:Create(fastBall.Fireball, TweenInfo.new(.5), {Transparency = 1})
    local ballMove = TweenService:Create(ballWeld, TweenInfo.new(.5), {C1 = CFrame.new( 0, 0, 12)})
    local shockTween = TweenService:Create(shockRing.Shock, TweenInfo.new(1), {Transparency = 1, Size = Vector3.new(5, 1.5, 5)})

    ballTrans:Play()
    ballMove:Play()
    shockTween:Play()

end

function module.Server_GhostEffect(params)

    print("SERVER", params)

    local originCFRame = params.HitCharacter.HumanoidRootPart.CFrame
    wait(7)
    params.HitCharacter.HumanoidRootPart.CFrame = originCFRame

end

function module.Client_GhostEffect(params)

    print("GHOST EFFECTS", params)

    if not params.InitPlayer then return end
    if not params.InitPlayer.Character then return end

    if not params.HitCharacter then return end

    AnchoredSound.NewSound(params.InitPlayer.Character.HumanoidRootPart.Position, ReplicatedStorage.Audio.General.LaserBeamDescend)

    spawn(function()

        local characterCopy = params.HitCharacter:Clone()
        for _, object in pairs(characterCopy:GetDescendants()) do
            if object:IsA("BasePart") then
                object.Anchored = true
            end
        end
        characterCopy.Parent = Workspace.RenderedEffects

        for _, object in pairs(params.HitCharacter:GetDescendants()) do
            if object:IsA("BasePart") then
                object.Transparency = .8
            end
        end

        wait(7)

        params.HitCharacter.HumanoidRootPart.CFrame = characterCopy.HumanoidRootPart.CFrame

        characterCopy:Destroy()

        for _, object in pairs(params.HitCharacter:GetDescendants()) do
            if object:IsA("BasePart") then
                if object.Name ~= "HumanoidRootPart" then
                    object.Transparency = 0
                end
            end
        end

    end)




end



return module