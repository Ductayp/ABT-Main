local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local StoneMask = {}

--// Server_Run
function StoneMask.Server_Run(params)

    print("StoneMask.Server_Run", params)

    if not params.TargetPlayer.Character then return end
    params.TargetPlayer.Character.HumanoidRootPart.Anchored = true

    local newMask = ReplicatedStorage.EffectParts.CutScenes.StoneMask.StoneMask:Clone()
    newMask.Parent = Workspace.RenderedEffects
    newMask.Name = "StoneMask_" .. params.TargetPlayer.UserId
    local newWeld = Instance.new("Weld")
    newWeld.C1 =  CFrame.new(0,0,0)
    newWeld.Part0 = newMask
    newWeld.Part1 = params.TargetPlayer.Character.LeftHand
    newWeld.Parent = newMask

    params.Mask = newMask

    require(Knit.PowerUtils.BlockInput).AddBlock(params.TargetPlayer.UserId, "CutSceneService", 600)
    Knit.Services.StateService:AddEntryToState(params.TargetPlayer, "Invulnerable", "CutSceneService", true)
    Knit.Services.PlayerUtilityService.PlayerAnimations[params.TargetPlayer.UserId].UseItem:Play()

    spawn(function()
        Knit.Services.PlayerUtilityService.PlayerAnimations[params.TargetPlayer.UserId].UseItem.Stopped:wait()
        wait(2)


        newMask:Destroy()

        require(Knit.PowerUtils.BlockInput).RemoveBlock(params.TargetPlayer.UserId, "CutSceneService")
        Knit.Services.StateService:RemoveEntryFromState(params.TargetPlayer, "Invulnerable", "CutSceneService", true)
        params.TargetPlayer.Character.HumanoidRootPart.Anchored = false
    end)

    params.CanRun = true
    return params
end

--// Client_Run
function StoneMask.Client_Run(params)


    print("StoneMask.Client_Run", params)

    if params.TargetPlayer == Players.LocalPlayer then

        if not Players.LocalPlayer.Character then return end

        local animator = Players.LocalPlayer.Character.Humanoid.Animator
        local playingTracks = animator:GetPlayingAnimationTracks()
        print("TRACKS",playingTracks)

        require(Knit.GuiModules.BottomGui).HideStand()
        local camera = Workspace.CurrentCamera
        camera.CameraType = Enum.CameraType.Scriptable
    
        local target = Players.LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 1, 0)
        local eye = Players.LocalPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(6, 3, -11)).Position
        local cameraCFrame = utils.LookAt(eye, target)
        local cameraTween = TweenService:Create(camera, TweenInfo.new(.5), {CFrame = cameraCFrame})
        cameraTween:Play()
    
        spawn(function()
            wait(5)
            camera.CameraType = Enum.CameraType.Custom 
            require(Knit.GuiModules.BottomGui).ShowStand()
        end)
    end

    local effectParts = {
        ball = ReplicatedStorage.EffectParts.CutScenes.StoneMask.Ball:Clone(),
    }

    for _, part in pairs(effectParts) do
        part.Parent = Workspace.RenderedEffects
        part.Position = params.Mask.StoneMask.Position
        --Debris:AddItem(part, 10)
    end

    local newWeld = Instance.new("Weld")
    newWeld.C1 =  CFrame.new(0,0,0)
    newWeld.Part0 = params.Mask.StoneMask
    newWeld.Part1 = effectParts.ball
    newWeld.Parent = params.Mask.StoneMask

    local tweens = {}
    tweens.Ball = {
        Part = effectParts.ball,
        Tweens = {
            Transparency = {
                Defs = {thisInfo = TweenInfo.new(2), thisParams = {Transparency = .7}},
                Delay = 0
            },
            
            Size = {
                Defs = {thisInfo = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), thisParams = {Size = Vector3.new(.1, .1, .1)}},
                Delay = 0
            }
        }
    }

    -- run the Tweens
    for _, table in pairs(tweens) do
        if table.Tweens then
            for _, tweenDef in pairs(table.Tweens) do
                spawn(function()
                    wait(tweenDef.Delay)
                    local thisTween = TweenService:Create(table.Part,tweenDef.Defs.thisInfo, tweenDef.Defs.thisParams)
                    thisTween:Play()
                    thisTween = nil
                end)
                
            end
        end
    end
    

    print(params.Mask)
    print(params.Mask.Parent)







end




return StoneMask