-- AngeloRock

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local WeldedSound = require(Knit.PowerUtils.WeldedSound)
local utils = require(Knit.Shared.Utils)

local AngeloRock = {}

function AngeloRock.Server_ApplyEffect(initPlayer, hitCharacter, params)

    local hitPlayer = utils.GetPlayerFromCharacter(hitCharacter)
    if hitPlayer then
        Knit.Services.PowersService:ForceRemoveStand(hitPlayer)
    end
    
    params.HitCharacter = hitCharacter
    Knit.Services.PowersService:RenderHitEffect_AllPlayers("IceBlock", params)
end

function AngeloRock.Client_RenderEffect(params)

    if not params.HitCharacter and params.HitCharacter.HumanoidRootPart then
        return
    end

    WeldedSound.NewSound(params.HitCharacter.HumanoidRootPart, ReplicatedStorage.Audio.General.Freeze)
    
    local icePart = ReplicatedStorage.EffectParts.Abilities.BasicAbility.TimeFreeze.Ice:Clone()
    icePart.CFrame = params.HitCharacter.HumanoidRootPart.CFrame
    icePart.Parent = Workspace.RenderedEffects
    icePart.CanCollide = false

    icePart.BurstEmitter:Emit(100)
    
    icePart.Transparency = 1
    local tweenIn_1 = TweenService:Create(icePart, TweenInfo.new(.5),{Transparency = .6})
    tweenIn_1:Play()

    wait(params.Duration)
    icePart.Anchored = true
    local tweenOut_1 = TweenService:Create(icePart, TweenInfo.new(1),{Size = Vector3.new(2,2,2)})
    local tweenOut_2 = TweenService:Create(icePart, TweenInfo.new(1),{Position = icePart.Position + Vector3.new(0,-10,0)})
    tweenOut_1:Play()
    tweenOut_2:Play()
    wait(2)
    icePart:Destroy()

end


return AngeloRock