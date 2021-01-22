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
local ManageStand = require(Knit.Abilities.ManageStand)
local DamageEffect = require(Knit.Effects.Damage)
local SimpleHitbox = require(Knit.PowerUtils.SimpleHitbox)

local HeavyPunch = {}

function HeavyPunch.Activate(initPlayer,params)
    
    -- save the original walkspeed and slow the player down
    --local originalWalkSpeed = initPlayer.Character.Humanoid.WalkSpeed
    initPlayer.Character.Humanoid.WalkSpeed = 0

    -- spawn function for hitbox with a delay
    spawn(function()
        wait(.5)

        -- make a new hitbox, it stays in place
        local boxParams = {}
        boxParams.Size = Vector3.new(4,3,12)
        boxParams.Transparency = 1
        boxParams.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-12))
        
        local hitParams = {}
        hitParams.Damage = params.HeavyPunch.Damage

        local newHitbox = SimpleHitbox.NewHitBox(initPlayer,boxParams,hitParams)
        Debris:AddItem(newHitbox, .5)

        newHitbox.ChildAdded:Connect(function(hit)
            if hit.Name == "CharacterHit" then
                if hit.Value ~= initPlayer.Character then
                    local characterHit = hit.Value
                    Knit.Services.PowersService:RegisterHit(initPlayer,characterHit,params.HeavyPunch.HitEffects)
                end
            end
        end)

        -- pause the restore the players WalkSpeed
        wait(1)
        local totalWalkSpeed = require(Knit.StateModules.WalkSpeed).GetModifiedValue(initPlayer)
        initPlayer.Character.Humanoid.WalkSpeed = totalWalkSpeed
        
    end)
end

function HeavyPunch.Execute(initPlayer,params)

    -- setup the stand, if its not there then dont run return
	local targetStand = workspace.PlayerStands[initPlayer.UserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		return
    end

    --move the stand and do animations
    local moveTime = ManageStand.MoveStand(initPlayer,{AnchorName = "Front"})
    ManageStand.PlayAnimation(initPlayer,params,"HeavyPunch")
    ManageStand.Aura_On(initPlayer)
    spawn(function()
        wait(1.5)
        ManageStand.MoveStand(initPlayer,{AnchorName = "Idle"})
        wait(.5)
        ManageStand.Aura_Off(initPlayer)
    end)

    -- wait the time it takes the stand to move
    wait(moveTime + 0.25)

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

    
    fastBall.CFrame = targetStand.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-6))
    ring_1.CFrame = targetStand.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-4))
    ring_2.CFrame = targetStand.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-8))
    ring_3.CFrame = targetStand.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-12))
    shock_1.CFrame = targetStand.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-6))


    if params.Color then
        fastBall.Fireball.Color = params.Color
    end

    fastBallDestination = fastBall.CFrame:ToWorldSpace(CFrame.new( 0, 0, -10))

    local fastBall_Move = TweenService:Create(fastBall,TweenInfo.new(.6),{CFrame = fastBallDestination})
    local fastBall_FadeOut = TweenService:Create(fastBall.Fireball,TweenInfo.new(.6, Enum.EasingStyle.Quart),{Transparency = 1})

    local ring_1_FadeIn = TweenService:Create(ring_1.ShockRing,TweenInfo.new(.1),{Transparency = .6})
    local ring_2_FadeIn = TweenService:Create(ring_2.ShockRing,TweenInfo.new(.1),{Transparency = .7})
    local ring_3_FadeIn = TweenService:Create(ring_3.ShockRing,TweenInfo.new(.1),{Transparency = .8})
    local ring_1_FadeOut = TweenService:Create(ring_1.ShockRing,TweenInfo.new(2),{Transparency = 1})
    local ring_2_FadeOut = TweenService:Create(ring_2.ShockRing,TweenInfo.new(1.5),{Transparency = 1})
    local ring_3_FadeOut = TweenService:Create(ring_3.ShockRing,TweenInfo.new(1),{Transparency = 1})
    local ring_1_Move = TweenService:Create(ring_1,TweenInfo.new(2),{CFrame = ring_1.CFrame:ToWorldSpace(CFrame.new( 0, 0, -1.5))})
    local ring_2_Move = TweenService:Create(ring_2,TweenInfo.new(2),{CFrame = ring_2.CFrame:ToWorldSpace(CFrame.new( 0, 0, -1.5))})
    local ring_3_Move = TweenService:Create(ring_3,TweenInfo.new(2),{CFrame = ring_3.CFrame:ToWorldSpace(CFrame.new( 0, 0, -1.5))})

    local shock_1_FadeOut = TweenService:Create(shock_1.Shock,TweenInfo.new(2),{Transparency = 1})
    local shock_1_Size = TweenService:Create(shock_1.Shock,TweenInfo.new(2),{Size = (shock_1.Shock.Size + Vector3.new(3,3,3))})

    -- trigger cleanup tweens when the fastBall has finished
    fastBall_Move.Completed:Connect(function(playbackState)
        if playbackState == Enum.PlaybackState.Completed then
  
            --fades
            ring_1_FadeOut:Play()
            ring_2_FadeOut:Play()
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


