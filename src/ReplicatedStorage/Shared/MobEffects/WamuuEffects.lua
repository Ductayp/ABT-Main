local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")


local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local WeldedSound = require(Knit.PowerUtils.WeldedSound)


local WamuuEffects = {}

function WamuuEffects.Tornado(params)

    local mobHRP = params.MobModel:FindFirstChild("HumanoidRootPart", true)
    if not mobHRP then return end

    local tweens = {}
    tweens.tornado_A = {
        Part = ReplicatedStorage.EffectParts.MobEffects.Wamuu.Tornado_A:Clone(),
        Tweens = {
            Transparency = {
                Defs = {thisInfo = TweenInfo.new(1.5), thisParams = {Transparency = 1}},
                Delay = 0
            },
            
            Size = {
                Defs = {thisInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), thisParams = {Size = Vector3.new(8, 24, 8)}},
                Delay = 0
            },

            Spin = {
                Defs = {thisInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), thisParams = {Orientation = Vector3.new(0, 359, 0)}},
                Delay = 0
            }
        }
    }

    tweens.tornado_B = {
        Part = ReplicatedStorage.EffectParts.MobEffects.Wamuu.Tornado_B:Clone(),
        Tweens = {
            Transparency = {
                Defs = {thisInfo = TweenInfo.new(1.5), thisParams = {Transparency = 1}},
                Delay = 0
            },
            
            Size = {
                Defs = {thisInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), thisParams = {Size = Vector3.new(8, 24, 8)}},
                Delay = 0
            },
            
            Spin = {
                Defs = {thisInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), thisParams = {Orientation = Vector3.new(0, 180, 0)}},
                Delay = 0
            }
        }
    }

    tweens.basicTornado = {
        Part = ReplicatedStorage.EffectParts.MobEffects.Wamuu.BasicTornado:Clone(),
        Tweens = {
            Transparency = {
                Defs = {thisInfo = TweenInfo.new(1.5), thisParams = {Transparency = 1}},
                Delay = 0
            },
            
            Size = {
                Defs = {thisInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), thisParams = {Size = Vector3.new(15, 7.5, 15)}},
                Delay = 0
            },
            
            Spin = {
                Defs = {thisInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), thisParams = {Orientation = Vector3.new(0, 359, 0)}},
                Delay = 0
            }
        }
    }



    -- run the Tweens
    for _, table in pairs(tweens) do

        table.Part.Position = mobHRP.Position
        table.Part.Parent = Workspace.RenderedEffects
        Debris:AddItem(table.Part, 5)

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

    wait(1.5)
    tweens.basicTornado.Part.Part.Wind.Enabled = false


end

return WamuuEffects