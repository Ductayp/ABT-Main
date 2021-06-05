local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")


local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local WeldedSound = require(Knit.PowerUtils.WeldedSound)


local AkiraEffects = {}

function AkiraEffects.SoundWaves(params)

    --print("ElectroBall", params)

    local mobHRP = params.MobModel:FindFirstChild("HumanoidRootPart", true)
    if not mobHRP then return end

    local handGuitar = params.MobModel:FindFirstChild("Guitar_Hand")
    local chestGuitar = params.MobModel:FindFirstChild("Guitar_Chest")

    handGuitar.Transparency = 1
    chestGuitar.Transparency = 0

    local effectParts = {}
    effectParts.Shock = ReplicatedStorage.EffectParts.MobEffects.Akira.Shock:Clone()
    effectParts.Tornado = ReplicatedStorage.EffectParts.MobEffects.Akira.Tornado:Clone()

    local beams = {}
    for _, character in pairs(params.HitCharacters) do
        if character:FindFirstChild("HumanoidRootPart") then

            local newBeam = ReplicatedStorage.EffectParts.MobEffects.Akira.SoundWaves:Clone()
            newBeam.Parent = Workspace.RenderedEffects
            Debris:AddItem(newBeam, 3)

            -- cframe and weld
            local newWeld = Instance.new("Weld")
            newWeld.C1 =  CFrame.new(0, 0, 0)
            newWeld.Part0 = mobHRP
            newWeld.Part1 = newBeam
            newWeld.Parent = newBeam

            newBeam.Attachment1.Parent = character.HumanoidRootPart
            table.insert(beams, newBeam)
        end
    end
    --effectParts.SoundWaves = ReplicatedStorage.EffectParts.MobEffects.Akira.SoundWaves:Clone()

    --effectParts.SpikeShock.CFrame = mobHRP.CFrame

    for _, part in pairs(effectParts) do
        part.CFrame = mobHRP.CFrame
        part.Parent = Workspace.RenderedEffects
        Debris:AddItem(part, 3)

        -- cframe and weld
        local newWeld = Instance.new("Weld")
        newWeld.C1 =  CFrame.new(0, 0, 0)
        newWeld.Part0 = mobHRP
        newWeld.Part1 = part
        newWeld.Parent = part

    end


    local tweens = {}
    tweens.Shock = {
        Part = effectParts.Shock.ShockMesh,
        Tweens = {
            Transparency = {
                Defs = {thisInfo = TweenInfo.new(1), thisParams = {Transparency = 1}},
                Delay = 0
            },
            
            Size = {
                Defs = {thisInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), thisParams = {Size = Vector3.new(8, 1.5, 8)}},
                Delay = 0
            },
        }
    }

    tweens.Tornado = {
        Part = effectParts.Tornado.TornadoMesh,
        Tweens = {
            Transparency = {
                Defs = {thisInfo = TweenInfo.new(1), thisParams = {Transparency = 1}},
                Delay = 0
            },
            
            Size = {
                Defs = {thisInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), thisParams = {Size = Vector3.new(4, 8, 4)}},
                Delay = 0
            },
        }
    }

    -- run the Tweens
    for _, table in pairs(tweens) do
        for _, tweenDef in pairs(table.Tweens) do
            spawn(function()
                wait(tweenDef.Delay)
                local thisTween = TweenService:Create(table.Part,tweenDef.Defs.thisInfo, tweenDef.Defs.thisParams)
                thisTween:Play()
                thisTween = nil
            end)
            
        end
    end

    --[[
    local target = params.AttackTarget.Character:FindFirstChild("HumanoidRootPart")
    if target then
        effectParts.SoundWaves.Attachment1.Parent = params.AttackTarget.Character.HumanoidRootPart
    else
        effectParts.SoundWaves.Attachment1.Position = Vector3.new(0,0,-20)
    end
    ]]--
    

    wait(2)

    for _, part in pairs(effectParts) do
        part:Destroy()
    end

    for _, beam in pairs(beams) do
        beam:Destroy()
    end

    handGuitar.Transparency = 0
    chestGuitar.Transparency = 1

end

return AkiraEffects