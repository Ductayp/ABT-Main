-- Heavy Punch Ability
-- PDab
-- 12-1-2020

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)
local ManageStand = require(Knit.Abilities.ManageStand)

local HeavyPunch = {}

function HeavyPunch.Activate(initPlayer,params)
    
    -- spawn function for hitbox with a delay
    spawn(function()
        wait(.5)
        local hitBox = ReplicatedStorage.EffectParts.Abilities.HeavyPunch.Hitbox:Clone()
        hitBox.Parent = workspace.RenderedEffects
        hitBox.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-10)) -- positions somewhere good near the stand
        Debris:AddItem(hitBox,.5)

        local excludeCharacter = {} -- a dictionary of character to exclude, can be added to
        hitBox.Touched:Connect(function(hit) 
    
            local humanoid = hit.Parent:FindFirstChildWhichIsA("Humanoid")
            if humanoid then
                local hitPlayer = utils.GetPlayerFromCharacter(hit.Parent)
                if hitPlayer ~= initPlayer then

                    local isExcluded = false
                    for character,boolean in pairs (excludeCharacter) do
                        if character == hit.Parent then
                            print(hit.Parent)
                            isExcluded = true
                            break
                        end
                    end
    
                    if isExcluded == false then
                        print("second time",isExcluded)
                        excludeCharacter[hit.Parent] = true
                        Knit.Services.PowersService:RegisterHit(initPlayer,hit.Parent,params)
                    end
                    
                end
            end 
        end)
    end)
end

function HeavyPunch.Execute(initPlayer,params)

    -- setup the stand, if its not there then dont run return
	local targetStand = workspace.PlayerStands[initPlayer.UserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		return
    end

    --move the stand and do animations
    ManageStand.PlayAnimation(initPlayer,params,"HeavyPunch")
    wait(.2)
    ManageStand.MoveStand(initPlayer,{AnchorName = "Front"})
    spawn(function()
        wait(1.5)
        ManageStand.MoveStand(initPlayer,{AnchorName = "Idle"})
    end)

    -- animate things
    local fastBall = ReplicatedStorage.EffectParts.Abilities.HeavyPunch.FastBall:Clone()
    local ring_1 = ReplicatedStorage.EffectParts.Abilities.HeavyPunch.Ring:Clone()
    local ring_2 = ReplicatedStorage.EffectParts.Abilities.HeavyPunch.Ring:Clone()
    local ring_3 = ReplicatedStorage.EffectParts.Abilities.HeavyPunch.Ring:Clone()
    local shock_1 = ReplicatedStorage.EffectParts.Abilities.HeavyPunch.Shock:Clone()


    fastBall.Parent = workspace.RenderedEffects
    ring_1.Parent = workspace.RenderedEffects
    ring_2.Parent = workspace.RenderedEffects
    ring_3.Parent = workspace.RenderedEffects
    shock_1.Parent = workspace.RenderedEffects

    
    fastBall.CFrame = targetStand.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-5))
    ring_1.CFrame = targetStand.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-7))
    ring_2.CFrame = targetStand.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-12))
    ring_3.CFrame = targetStand.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-17))
    shock_1.CFrame = targetStand.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-6))


    if params.Color then
        --fastBall.Fireball.Color = params.Color
    end

    fastBallDestination = fastBall.CFrame:ToWorldSpace(CFrame.new( 0, 0, -20))

    local fastBall_Move = TweenService:Create(fastBall,TweenInfo.new(.4),{CFrame = fastBallDestination})
    local fastBall_FadeOut = TweenService:Create(fastBall.Fireball,TweenInfo.new(.4, Enum.EasingStyle.Quart),{Transparency = 1})

    local ring_1_FadeIn = TweenService:Create(ring_1.ShockRing,TweenInfo.new(.1),{Transparency = .6})
    local ring_2_FadeIn = TweenService:Create(ring_2.ShockRing,TweenInfo.new(.1),{Transparency = .7})
    local ring_3_FadeIn = TweenService:Create(ring_3.ShockRing,TweenInfo.new(.1),{Transparency = .8})
    local ring_1_FadeOut = TweenService:Create(ring_1.ShockRing,TweenInfo.new(2),{Transparency = 1})
    local ring_2_FadeOut = TweenService:Create(ring_2.ShockRing,TweenInfo.new(2),{Transparency = 1})
    local ring_3_FadeOut = TweenService:Create(ring_3.ShockRing,TweenInfo.new(2),{Transparency = 1})
    local ring_1_Move = TweenService:Create(ring_1,TweenInfo.new(2),{CFrame = ring_1.CFrame:ToWorldSpace(CFrame.new( 0, 0, -3))})
    local ring_2_Move = TweenService:Create(ring_2,TweenInfo.new(2),{CFrame = ring_2.CFrame:ToWorldSpace(CFrame.new( 0, 0, -3))})
    local ring_3_Move = TweenService:Create(ring_3,TweenInfo.new(2),{CFrame = ring_3.CFrame:ToWorldSpace(CFrame.new( 0, 0, -3))})

    local shock_1_FadeOut = TweenService:Create(shock_1.Shock,TweenInfo.new(2),{Transparency = 1})
    local shock_1_Size = TweenService:Create(shock_1.Shock,TweenInfo.new(2),{Size = (shock_1.Shock.Size + Vector3.new(3,3,3))})

    -- trigger cleanup tweens when the fastBall has finished
    fastBall_Move.Completed:Connect(function(playbackState)
        if playbackState == Enum.PlaybackState.Completed then
  
            --fades
            ring_1_FadeOut:Play()
            wait(.2)
            ring_2_FadeOut:Play()
            wait(.2)
            ring_3_FadeOut:Play()

            -- debris
            Debris:AddItem(fastBall,2)
            Debris:AddItem(ring_1,2)
            Debris:AddItem(ring_2,2)
            Debris:AddItem(ring_3,2)
            Debris:AddItem(shock_1,2)

            
        end
    end)

    -- play the initial tweens
    fastBall_Move:Play()
    fastBall_FadeOut:Play()

    shock_1_FadeOut:Play()
    shock_1_Size:Play()

    ring_1_FadeIn:Play()
    ring_1_Move:Play()
    wait(0.05)
    ring_2_FadeIn:Play()
    ring_2_Move:Play()
    wait(0.05)
    ring_3_FadeIn:Play()
    ring_3_Move:Play()
    
    




end

return HeavyPunch


