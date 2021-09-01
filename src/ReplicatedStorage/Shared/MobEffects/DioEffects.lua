local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")


local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local WeldedSound = require(Knit.PowerUtils.WeldedSound)
local utils = require(Knit.Shared.Utils)


local DioEffects = {}

function DioEffects.Freeze(params)

    if not params.HitCharacter then return end
    local torso = params.HitCharacter:FindFirstChild("UpperTorso", true)
    if not torso then return end

    local hand = params.MobData.Model:FindFirstChild("RightHand", true)
    if not hand then return end

    local torsoAttach = Instance.new("Attachment")
    torsoAttach.Parent = torso

    local newBeam = ReplicatedStorage.EffectParts.MobEffects.DioBrando.FreezeEffect.Beam:Clone()
    newBeam.Parent = Workspace.RenderedEffects

    local newWeld = Instance.new("Weld")
	newWeld.Part0 = newBeam
	newWeld.Part1 = hand
	newWeld.Parent = newBeam

    newBeam.Beam.Attachment0 = newBeam.Attachment
    newBeam.Beam.Attachment1 = torsoAttach

    newBeam.Burst:Emit(25)

    wait(1.5)

    torsoAttach:Destroy()
    newBeam:Destroy()

end

function DioEffects.Laser(params)

    print("LASER EFFETCS!!!!")

    if not params.HitCharacter then return end
    local torso = params.HitCharacter:FindFirstChild("UpperTorso", true)
    if not torso then return end

    local head = params.MobData.Model:FindFirstChild("Head", true)
    if not head then return end

    local torsoAttach = Instance.new("Attachment")
    torsoAttach.Parent = torso

    local newBeam = ReplicatedStorage.EffectParts.MobEffects.DioBrando.LaserEffect.Beam:Clone()
    newBeam.Parent = Workspace.RenderedEffects

    local newWeld = Instance.new("Weld")
	newWeld.Part0 = newBeam
	newWeld.Part1 = head
	newWeld.Parent = newBeam

    newBeam.Beam_Left.Attachment0 = newBeam.Blast_Left.Attachment
    newBeam.Beam_Left.Attachment1 =  torsoAttach

    newBeam.Beam_Right.Attachment0 = newBeam.Blast_Right.Attachment
    newBeam.Beam_Right.Attachment1 =  torsoAttach

    wait(.75)

    torsoAttach:Destroy()
    newBeam:Destroy()

end

return DioEffects