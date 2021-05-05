local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local UseArrow = {}

--// Server_Run
function UseArrow.Server_Run(params)

    print("UseArrow.Server_Run", params)

    local playerData = Knit.Services.PlayerDataService:GetPlayerData(params.TargetPlayer)
    if not playerData then return end

    if not params.TargetPlayer.Character then return end
    params.TargetPlayer.Character.HumanoidRootPart.Anchored = true

    local newArrow = ReplicatedStorage.EffectParts.CutScenes.UseArrow.StabArrow:Clone()
    newArrow.Parent = Workspace.RenderedEffects
    local newWeld = Instance.new("Weld")
    newWeld.C1 =  CFrame.new(0,0,0)
    newWeld.Part0 = newArrow
    newWeld.Part1 = params.TargetPlayer.Character.LeftHand
    newWeld.Parent = newArrow

    require(Knit.PowerUtils.BlockInput).AddBlock(params.TargetPlayer.UserId, "CutSceneService", 600)
    Knit.Services.StateService:AddEntryToState(params.TargetPlayer, "Invulnerable", "CutSceneService", true)
    Knit.Services.PlayerUtilityService.PlayerAnimations[params.TargetPlayer.UserId].UseArrow:Play()

    local powerParams = {
        CanRun = true,
        InitUserId = params.TargetPlayer.UserId,
        InputId = "Q",
        KeyState = "InputBegan",
        PowerID = playerData.CurrentStand.Power,
        PowerRank = playerData.CurrentStand.Rank,
        SystemStage = "Initialize",
        BypassInputBlock = true
    }

    spawn(function()
        Knit.Services.PlayerUtilityService.PlayerAnimations[params.TargetPlayer.UserId].UseArrow.Stopped:wait()
        Knit.Services.PowersService:ActivatePower(params.TargetPlayer, powerParams)
        wait(2)
        newArrow:Destroy()
    end)

    params.CanRun = true
    return params
end

--// Server_End
function UseArrow.Server_End(params)

    if not params.TargetPlayer.Character then return end
    params.TargetPlayer.Character.HumanoidRootPart.Anchored = false

    require(Knit.PowerUtils.BlockInput).RemoveBlock(params.TargetPlayer.UserId, "CutSceneService")
    Knit.Services.StateService:RemoveEntryFromState(params.TargetPlayer, "Invulnerable", "CutSceneService", true)
    --Knit.Services.PlayerUtilityService.PlayerAnimations[params.TargetPlayer.UserId].UseArrow:Stop()

    params.CanRun = true
    return params
end

--// Client_Run
function UseArrow.Client_Run(params)

    print("UseArrow.Client_Run", params)

    if not Players.LocalPlayer.Character then return end

    print("MODULE RUN SCENE", params)
    local camera = Workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Scriptable

    local target = Players.LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 1, 0)
    local eye = Players.LocalPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(6, 3, -11)).Position
    local cameraCFrame = utils.LookAt(eye, target)
    local cameraTween = TweenService:Create(camera, TweenInfo.new(.5), {CFrame = cameraCFrame})
    cameraTween:Play()


    --camera.CFrame = utils.LookAt(eye, target)
end

--// Client_End
function UseArrow.Client_End(params)
    local camera = Workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Custom 
end


return UseArrow