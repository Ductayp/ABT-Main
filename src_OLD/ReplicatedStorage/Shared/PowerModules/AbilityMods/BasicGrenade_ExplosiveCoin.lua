-- Basic Grenade Ability
-- PDab
-- 11-27-2020

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local ExplosiveCoin = {}

ExplosiveCoin.PartAssembly = ReplicatedStorage.EffectParts.AbilityMods.ExplosiveCoin.Coin
ExplosiveCoin.OriginOffset = CFrame.new(0,1,-2) -- this is the offset in front fo the character
ExplosiveCoin.Velocity = { -- this controls the movement of the coin toss
    X = 3,
    Z = 3,
    Y = 20,
}

ExplosiveCoin.DetonationDelay = 4
ExplosiveCoin.HitRadius = 30


function ExplosiveCoin.new(initPlayer)

    local newGrenadePart = ExplosiveCoin.PartAssembly:Clone()
    newGrenadePart.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(ExplosiveCoin.OriginOffset)

    local newGrenade = {
        MainPart = newGrenadePart,
        BodyVelocity = newGrenadePart.BodyVelocity,
        BodyAngularVelocity = newGrenadePart.BodyAngularVelocity,
        DetonationDelay = ExplosiveCoin.DetonationDelay,
        HitRadius = ExplosiveCoin.HitRadius,
        HitCharacters = {} -- table to hold hits
    }

    return newGrenade
end

function ExplosiveCoin.GetHitEffects(initPlayer, hitCharacter, grenade)

    local newLookVector = (hitCharacter.HumanoidRootPart.Position - grenade.MainPart.Position).unit

    local newHitEffects = {Damage = {Damage = 35, HideEffects = true}, Blast = {}, KnockBack = {Force = 70, ForceY = 50, LookVector = newLookVector}}

    return newHitEffects
end

function ExplosiveCoin.PlayAnimation(initPlayer)
    Knit.Services.PlayerUtilityService.PlayerAnimations[initPlayer.UserId].CoinFlip:Play()
end

function ExplosiveCoin.Server_Launch(initPlayer, grenade)

    local baseCFrame = initPlayer.Character.HumanoidRootPart.CFrame
    local velocityX = baseCFrame.LookVector.X * ExplosiveCoin.Velocity.X
    local velocityZ = baseCFrame.LookVector.Z * ExplosiveCoin.Velocity.Z

    grenade.BodyVelocity.MaxForce = Vector3.new(5000,5000,5000)
    grenade.BodyVelocity.P = 1000
    grenade.BodyVelocity.Velocity =  Vector3.new(velocityX, ExplosiveCoin.Velocity.Y, velocityZ)
    Debris:AddItem(grenade.BodyVelocity, .2)

    grenade.BodyAngularVelocity.MaxTorque = Vector3.new(400,400,400)
    Debris:AddItem(grenade.BodyAngularVelocity, .2)

    grenade.MainPart.Parent = Workspace.RenderedEffects
    --grenade.MainPart:SetNetworkOwner(nil)

end

function ExplosiveCoin.Server_Explode(initPlayer, grenade)
    -- nothign now
end

function ExplosiveCoin.Client_Launch(initPlayer, grenade)

end

function ExplosiveCoin.Client_Explode(initPlayer, grenade)

    local effectParts = {}

    effectParts.SpikeShock = {
        Part = ReplicatedStorage.EffectParts.AbilityMods.ExplosiveCoin.SpikeShock:Clone(),
        Params = {
            Position = grenade.MainPart.Position,
            Parent = Workspace.RenderedEffects,
        },
        Tweens = {
            SizeTween = {
                Defs = {thisInfo = TweenInfo.new(.55, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), thisParams = {Size = Vector3.new(grenade.HitRadius,grenade.HitRadius / 5,grenade.HitRadius)}},
                Delay = 0
            },
            TransparencyTween = {
                Defs = {thisInfo = TweenInfo.new(.25), thisParams = {Transparency = 1}},
                Delay = .25
            }
        }
    }

    effectParts.RoughSpikeShock = {
        Part = ReplicatedStorage.EffectParts.AbilityMods.ExplosiveCoin.RoughSpikeShock:Clone(),
        Params = {
            Position = grenade.MainPart.Position + Vector3.new(0,3,0),
            Parent = Workspace.RenderedEffects,
            --Size = Vector3.new(grenade.HitRadius / 2, grenade.HitRadius / 2, grenade.HitRadius / 2 ),
        },
        Tweens = {
            SizeTween = {
                Defs = {thisInfo = TweenInfo.new(.55, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), thisParams = {Size = Vector3.new(grenade.HitRadius / 3,grenade.HitRadius / 4,grenade.HitRadius/ 3)}},
                Delay = 0
            },
            TransparencyTween = {
                Defs = {thisInfo = TweenInfo.new(.5), thisParams = {Transparency = 1}},
                Delay = .25
            },
            ColorTween = {
                Defs = {thisInfo = TweenInfo.new(.25), thisParams = {Color = Color3.new(255/255,255/255,255/255)}},
                Delay = 0
            }
        }
    }

    effectParts.Ball = {
        Part = ReplicatedStorage.EffectParts.AbilityMods.ExplosiveCoin.Ball:Clone(),
        Params = {
            Size = Vector3.new(grenade.HitRadius / 2, grenade.HitRadius / 2, grenade.HitRadius / 2 ),
            CFrame = grenade.MainPart.CFrame,
            Parent = Workspace.RenderedEffects
        },
        Tweens = {
            SizeTween = {
                Defs = {thisInfo = TweenInfo.new(.25), thisParams = {Size = Vector3.new(grenade.HitRadius, grenade.HitRadius, grenade.HitRadius)}},
                Delay = 0
            },
            TransparencyTween = {
                Defs = {thisInfo = TweenInfo.new(1), thisParams = {Transparency = 1}},
                Delay = 0
            }
        }
    }

    effectParts.Shockwave = {
        Part = ReplicatedStorage.EffectParts.AbilityMods.ExplosiveCoin.Shockwave:Clone(),
        Params = {
            Size = Vector3.new(grenade.HitRadius / 3, 0.25, grenade.HitRadius / 3 ),
            Position = grenade.MainPart.Position + Vector3.new(0,2.5,0),
            Parent = Workspace.RenderedEffects,

        },
        Tweens = {
            SizeTween = {
                Defs = {thisInfo = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), thisParams = {Size = Vector3.new(grenade.HitRadius * 2, 0.5, grenade.HitRadius * 2)}},
                Delay = 0
            },
            TransparencyTween = {
                Defs = {thisInfo = TweenInfo.new(1), thisParams = {Transparency = 1}},
                Delay = 1
            }
        }

    }

 


    -- setup the parts
    for _,partTable in pairs(effectParts) do

        for paramIndex, paramValue in pairs(partTable.Params) do
            partTable.Part[paramIndex] = paramValue
            Debris:AddItem(partTable.Part, 5)
        end

        for _,tween in pairs(partTable.Tweens) do

            spawn(function()
                wait(tween.Delay)
                local thisTween = TweenService:Create(partTable.Part,tween.Defs.thisInfo, tween.Defs.thisParams)
                thisTween:Play()
                thisTween = nil
            end)

        end
    end

end


return ExplosiveCoin


