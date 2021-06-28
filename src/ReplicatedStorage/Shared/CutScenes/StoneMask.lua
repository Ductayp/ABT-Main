local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local WeldedSound = require(Knit.PowerUtils.WeldedSound)
local utils = require(Knit.Shared.Utils)

local StoneMask = {}

--// Server_Run
function StoneMask.Server_Run(params)

    if not params.TargetPlayer.Character then return end
    params.TargetPlayer.Character.HumanoidRootPart.Anchored = true

    require(Knit.PowerUtils.BlockInput).AddBlock(params.TargetPlayer.UserId, "CutSceneService", 600)
    Knit.Services.StateService:AddEntryToState(params.TargetPlayer, "Invulnerable", "CutSceneService", true)
    Knit.Services.PlayerUtilityService.PlayerAnimations[params.TargetPlayer.UserId].UseItem:Play()

    spawn(function()
        Knit.Services.PlayerUtilityService.PlayerAnimations[params.TargetPlayer.UserId].UseItem.Stopped:wait()
        wait(1)
        require(Knit.PowerUtils.BlockInput).RemoveBlock(params.TargetPlayer.UserId, "CutSceneService")
        Knit.Services.StateService:RemoveEntryFromState(params.TargetPlayer, "Invulnerable", "CutSceneService", true)
        params.TargetPlayer.Character.HumanoidRootPart.Anchored = false
    end)

    params.CanRun = true
    return params
end

--// Client_Run
function StoneMask.Client_Run(params)

    if params.TargetPlayer == Players.LocalPlayer then

        if not Players.LocalPlayer.Character then return end

        StoneMask.HideCharacters()
        spawn(function()
            wait(3)
            StoneMask.ShowCharacters()
        end)

        Knit.Controllers.GuiController.Modules.StandData.HideStand()
        Knit.Controllers.GuiController.Modules.AbilityBar.HideAbilities()

        Knit.Controllers.GuiController.Modules.ShiftLock.SetOff()
        local camera = Workspace.CurrentCamera
        camera.CameraType = Enum.CameraType.Scriptable
    
        local target = Players.LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 1, 0)
        local eye = Players.LocalPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(6, 3, -11)).Position
        local cameraCFrame = utils.LookAt(eye, target)
        local cameraTween1 = TweenService:Create(camera, TweenInfo.new(.5), {CFrame = cameraCFrame})

        cameraTween1.Completed:Connect(function()
            local target = Players.LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 1, 0)
            local eye = Players.LocalPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(6, 3, -7)).Position
            local cameraCFrame = utils.LookAt(eye, target)
            local cameraTween2 = TweenService:Create(camera, TweenInfo.new(3), {CFrame = cameraCFrame})
            cameraTween2:Play()
        end)
        
        cameraTween1:Play()

        local redCC = ReplicatedStorage.EffectParts.CutScenes.StoneMask.ColorCorrection_Red:Clone()
        local satCC = ReplicatedStorage.EffectParts.CutScenes.StoneMask.ColorCorrection_Saturation:Clone()
        local depth = ReplicatedStorage.EffectParts.CutScenes.StoneMask.DepthOfField:Clone()
        depth.Parent = game:GetService("Lighting")
        redCC.Parent = game:GetService("Lighting")
        satCC.Parent = game:GetService("Lighting")

        spawn(function()
            satCC.Enabled = true
            wait(1.5)
            redCC.Enabled = true
            wait(.07)
            redCC.Enabled = false
            wait(.05)
            redCC.Enabled = true
            wait(.07)
            redCC.Enabled = false
            wait(.05)
            redCC.Enabled = true
            wait(.07)
            redCC:Destroy()
            depth:Destroy()

            wait(1)
            camera.CameraType = Enum.CameraType.Custom 

            Knit.Controllers.GuiController.Modules.StandData.ShowStand()
            Knit.Controllers.GuiController.Modules.AbilityBar.ShowAbilities()

            satCC:Destroy()
        end)
    
        spawn(function()
            
        end)
    end

    local newMask = ReplicatedStorage.EffectParts.CutScenes.StoneMask.StoneMask:Clone()
    newMask.Parent = Workspace.RenderedEffects
    newMask.Name = "StoneMask_" .. params.TargetPlayer.UserId
    local maskWeld = Instance.new("Weld")
    maskWeld.C1 =  CFrame.new(0,0,0)
    maskWeld.Part0 = newMask
    maskWeld.Part1 = params.TargetPlayer.Character.LeftHand
    maskWeld.Parent = newMask
    Debris:AddItem(newMask, 20)
    
    local effectParts = {
        ball = ReplicatedStorage.EffectParts.CutScenes.StoneMask.Ball:Clone(),
        burst1 = ReplicatedStorage.EffectParts.CutScenes.StoneMask.SkinnyBurst_1:Clone(),
        burst2 = ReplicatedStorage.EffectParts.CutScenes.StoneMask.SkinnyBurst_2:Clone(),
    }

    for _, part in pairs(effectParts) do
        --part.Position = Vector3.new(0, -9999, 0)
        part.Parent = Workspace.RenderedEffects
        Debris:AddItem(part, 10)

        local newWeld = Instance.new("Weld")
        newWeld.C1 =  CFrame.new(0,0,0)
        newWeld.Part0 = newMask.StoneMask
        newWeld.Part1 = part
        newWeld.Parent = newMask.StoneMask

    end

    local ballTween = TweenService:Create(effectParts.ball, TweenInfo.new(2), {Transparency = .7, Size = Vector3.new(1, 1, 1)})
    local burstTween1 = TweenService:Create(effectParts.burst1.mesh, TweenInfo.new(.5), {Transparency = 1, Size = Vector3.new(15,15,15)})
    local burstTween2 = TweenService:Create(effectParts.burst2.mesh, TweenInfo.new(.5), {Transparency = 1, Size = Vector3.new(8,8,8)})

    ballTween.Completed:Connect(function()

        maskWeld:Destroy()
        newMask.Anchored = true
        newMask.StoneMask.Transparency = 1
        newMask.StoneMask.particle.Enabled = false
        effectParts.ball:Destroy()

        effectParts.burst1.mesh.Transparency = 0
        effectParts.burst2.mesh.Transparency = 0

        burstTween1:Play()
        burstTween2:Play()

        local newBloodParticle = ReplicatedStorage.EffectParts.CutScenes.StoneMask.BloodParticles:Clone()
        newBloodParticle.Parent = Workspace.RenderedEffects
        local newWeld = Instance.new("Weld")
        newWeld.C1 =  CFrame.new(0,0,0)
        newWeld.Part0 = params.TargetPlayer.Character.Head
        newWeld.Part1 = newBloodParticle
        newWeld.Parent = newBloodParticle
        Debris:AddItem(newBloodParticle, 10)
        newBloodParticle.Blood:Emit(300)
        newBloodParticle.Mist:Emit(200)

    end)

    ballTween:Play()
    WeldedSound.NewSound(params.TargetPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.General.PowerUpDistorted, {Volume = 2})
    WeldedSound.NewSound(params.TargetPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.General.Wry)
    spawn(function()
        wait(1.5)
        WeldedSound.StopSound(params.TargetPlayer.Character.HumanoidRootPart, "PowerUpDistorted", .1)
        WeldedSound.NewSound(params.TargetPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.General.MagicDoubleWoosh, {Volume = 2})
    end)

end

function StoneMask.HideCharacters()

    for i, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            if player.Character then
                for i, v in pairs(player.Character:GetDescendants()) do
                    if v:IsA("BasePart") or v:IsA("Decal") then
                        if v.Name ~= "HumanoidRootPart" then
                            v.Transparency = 1
                        end
                    end
                end
            end
        end
    end

    for _, playerFolder in pairs(Workspace.PlayerStands:GetChildren()) do
        for _, stand in pairs(playerFolder:GetChildren()) do
            for _, object in pairs(stand:GetDescendants()) do
                if object:IsA("BasePart") or object:IsA("Decal") then
                    if object.Name ~= "HumanoidRootPart" then
                        object.Transparency = 1
                    end
                end
            end
        end
    end

end

function StoneMask.ShowCharacters()

    for i, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            if player.Character then
                for i, v in pairs(player.Character:GetDescendants()) do
                    if v:IsA("BasePart") or v:IsA("Decal") then
                        if v.Name ~= "HumanoidRootPart" then
                            v.Transparency = 0
                        end
                    end
                end
            end
        end
    end

    for _, playerFolder in pairs(Workspace.PlayerStands:GetChildren()) do
        for _, stand in pairs(playerFolder:GetChildren()) do
            for _, object in pairs(stand:GetDescendants()) do
                if object:IsA("BasePart") or object:IsA("Decal") then
                    if object.Name ~= "HumanoidRootPart" then
                        object.Transparency = 0
                    end
                end
            end
        end
    end

end




return StoneMask