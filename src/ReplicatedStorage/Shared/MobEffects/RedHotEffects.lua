local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")


local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local WeldedSound = require(Knit.PowerUtils.WeldedSound)


local RedHotEffects = {}

function RedHotEffects.ElectroBall(params)

    local mobHRP = params.MobModel:FindFirstChild("HumanoidRootPart", true)
    if not mobHRP then return end

    local effectParts = {}
    effectParts.InnerBall = ReplicatedStorage.EffectParts.MobEffects.RHCP.InnerBall:Clone()
    effectParts.OuterBall = ReplicatedStorage.EffectParts.MobEffects.RHCP.OuterBall:Clone()

    for _, part in pairs(effectParts) do
        part.Position = mobHRP.Position
        part.Parent = Workspace.RenderedEffects
        Debris:AddItem(part, 2)
    end

    local sizeTween = TweenService:Create(effectParts.OuterBall, TweenInfo.new(0.5), {Size = Vector3.new(1, 1, 1)})
    local transTween = TweenService:Create(effectParts.OuterBall, TweenInfo.new(0.5), {Transparency = 1})
    sizeTween:Play()
    transTween:Play()
    sizeTween:Destroy()
    transTween:Destroy()

    effectParts.InnerBall.EmitBolts:Emit(100)
    effectParts.InnerBall.Attachment.RingBolts.Enabled = true
    wait(.6)
    effectParts.InnerBall.Attachment.RingBolts.Enabled = false

end

return RedHotEffects