-- Blast Effect
-- PDab
-- 1-22-2020

-- applies both pracitcal effects such as actual damage in numbers as well as the visual effects

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)

local Blast = {}

function Blast.Server_ApplyEffect(initPlayer, hitCharacter, params)

    -- just a final check to be sure were hitting a humanoid
    if hitCharacter:FindFirstChild("Humanoid") then

        -- send the visual effects to all clients
        params.HitCharacter = hitCharacter
        Knit.Services.PowersService:RenderEffect_AllPlayers("Blast", params)
        
    end

end

function Blast.Client_RenderEffect(params)

    -- EFFECT PARTS
    local effectParts = {}
    effectParts.Shockwave = {
        Part = ReplicatedStorage.EffectParts.Effects.Blast.Shockwave:Clone(),
        Tweens = {

            Transparency = {
                Defs = {thisInfo = TweenInfo.new(.5), thisParams = {Transparency = 1}},
                Delay = 1
            },
            
            Size = {
                Defs = {thisInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), thisParams = {Size = Vector3.new(15, 1, 15)}},
                Delay = 0
            }
        }
    }

    effectParts.FatBurst = {
        Part = ReplicatedStorage.EffectParts.Effects.Blast.FatBurst:Clone(),
        Tweens = {
            
            Transparency = {
                Defs = {thisInfo = TweenInfo.new(.2), thisParams = {Transparency = 1}},
                Delay = .1
            },
            
            Size = {
                Defs = {thisInfo = TweenInfo.new(.3), thisParams = {Size = Vector3.new(7,7,7)}},
                Delay = 0
            }
        }
    }

    effectParts.SkinnyBurst_Big = {
        Part = ReplicatedStorage.EffectParts.Effects.Blast.SkinnyBurst_Big:Clone(),
        Tweens = {
            
            Transparency = {
                Defs = {thisInfo = TweenInfo.new(.4), thisParams = {Transparency = 1}},
                Delay = .1
            },
            
            Size = {
                Defs = {thisInfo = TweenInfo.new(.5), thisParams = {Size = Vector3.new(12,12,12)}},
                Delay = 0
            }
        }
    }

    effectParts.SkinnyBurst_Small = {
        Part = ReplicatedStorage.EffectParts.Effects.Blast.SkinnyBurst_Small:Clone(),
        Tweens = {
            
            Transparency = {
                Defs = {thisInfo = TweenInfo.new(.2), thisParams = {Transparency = 1}},
                Delay = .1
            },
            
            Size = {
                Defs = {thisInfo = TweenInfo.new(.3), thisParams = {Size = Vector3.new(8,8,8)}},
                Delay = 0
            }
        }
    }


    effectParts.Smoke = {
        Part = ReplicatedStorage.EffectParts.Effects.Blast.Smoke:Clone(),
        Tweens = {
            
            Transparency = {
                Defs = {thisInfo = TweenInfo.new(2.5), thisParams = {Transparency = 1}},
                Delay = 1
            },
            
            Size = {
                Defs = {thisInfo = TweenInfo.new(3), thisParams = {Size = Vector3.new(10,10,10)}},
                Delay = .5
            }
        }
    }




    -- handle character particles
    spawn(function()
        -- setup
        local thisPart = ReplicatedStorage.EffectParts.Effects.Blast.Blast_Particles:Clone()
        thisPart.CFrame = params.HitCharacter.HumanoidRootPart.CFrame
        thisPart.Parent = Workspace.RenderedEffects
        thisPart.Anchored = false
        utils.EasyWeld(params.HitCharacter.HumanoidRootPart, thisPart, thisPart)
        Debris:AddItem(thisPart, 7)

        -- control
        thisPart.Smoke_Particle.Enabled = true
        thisPart.Flame_Particle.Enabled = true
        wait(.5)
        thisPart.Flame_Particle.Enabled = false
        wait(5)
        thisPart.Smoke_Particle.Enabled = false
    end)


    -- handle effect particles
    spawn(function()
        -- setup
        local thisPart = ReplicatedStorage.EffectParts.Effects.Blast.Blast_Particles:Clone()
        thisPart.CFrame = params.HitCharacter.HumanoidRootPart.CFrame
        thisPart.Parent = Workspace.RenderedEffects
        Debris:AddItem(thisPart, 7)

        -- control
        thisPart.Smoke_Particle.Enabled = true
        thisPart.Flame_Particle.Enabled = true
        wait(.5)
        thisPart.Flame_Particle.Enabled = false
        --wait(1)
        thisPart.Smoke_Particle.Enabled = false
    end)

    -- setup the effect parts
    for name, table in pairs(effectParts) do
        table.Part.CFrame = params.HitCharacter.HumanoidRootPart.CFrame
        table.Part.Parent = Workspace.RenderedEffects
        Debris:AddItem(table.Part, 10)
    end

    WeldedSound.NewSound(params.HitCharacter.HumanoidRootPart, ReplicatedStorage.Audio.General.Explosion_2, {PlaybackSpeed = 2})

    -- run the Tweens
    for name, table in pairs(effectParts) do
        if table.Tweens then
            for name2,tweenDef in pairs(table.Tweens) do
                spawn(function()
                    wait(tweenDef.Delay)
                    local thisTween = TweenService:Create(table.Part,tweenDef.Defs.thisInfo, tweenDef.Defs.thisParams)
                    thisTween:Play()
                    thisTween = nil
                end)
                
            end
        end
    end

end


return Blast