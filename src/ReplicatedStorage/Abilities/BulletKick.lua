-- Bullet Kick Ability
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
local DamageEffect = require(Knit.Effects.Damage)
local KnockBack = require(Knit.Effects.KnockBack)

local BulletKick = {}

function BulletKick.Activate(initPlayer,params)
    
    -- drop the walkspeed
    --initPlayer.Character.Humanoid.WalkSpeed = 0

    -- spawn function for hitbox with a delay
    spawn(function()
        wait(.3)

        -- make a new hitbox, it stays in place
        local boxParams = {}
        boxParams.Size = Vector3.new(4,3,6)
        boxParams.Transparency = .5

        boxParams.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-3))
        
        -- set the look vector for the KnockBack effect
        params.BulletKick.Effects.KnockBack.LookVector = boxParams.CFrame.LookVector 

        -- make a new hitbox
        local newHitbox = powerUtils.SimpleHitbox(initPlayer,boxParams)
        Debris:AddItem(newHitbox, .5)

        newHitbox.ChildAdded:Connect(function(hit)
            if hit.Name == "CharacterHit" then
                if hit.Value ~= initPlayer.Character then
                    print(hit,hit.Value)
                    for effect,params in pairs(params.BulletKick.Effects) do
                        require(Knit.Effects[effect]).Server_ApplyEffect(hit.Value,params)
                    end
                end
            end
        end)

        -- pause then restore the players WalkSpeed
        --wait(1)
        --local totalWalkSpeed = require(Knit.ModifierService.WalkSpeed).GetModifiedValue(initPlayer)
        --initPlayer.Character.Humanoid.WalkSpeed = totalWalkSpeed
        
    end)
end

function BulletKick.Execute(initPlayer,params)

    -- setup the stand, if its not there then dont run return
	local targetStand = workspace.PlayerStands[initPlayer.UserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		return
    end

    --move the stand and do animations
    ManageStand.MoveStand(initPlayer,{AnchorName = "Front"})
    ManageStand.PlayAnimation(initPlayer,params,"BulletKick")
    spawn(function()
        wait(1.5)
        ManageStand.MoveStand(initPlayer,{AnchorName = "Idle"})
    end)

    local pop_1 = ReplicatedStorage.EffectParts.Abilities.BulletKick.BulletKickPop:Clone()
    local pop_2 = ReplicatedStorage.EffectParts.Abilities.BulletKick.BulletKickPop:Clone()
    local pop_3 = ReplicatedStorage.EffectParts.Abilities.BulletKick.BulletKickPop:Clone()

    
    
    
    local tweenInfo_Fast = TweenInfo.new(.4)
    local tweenInfo_Slow = TweenInfo.new(.7)

    local pop_1_Size = TweenService:Create(pop_1.RoughSpikeShock,tweenInfo_Fast,{Size = (pop_1.RoughSpikeShock.Size + Vector3.new(1,1,1))})
    local pop_2_Size = TweenService:Create(pop_2.RoughSpikeShock,tweenInfo_Fast,{Size = (pop_2.RoughSpikeShock.Size + Vector3.new(1,1,1))})
    local pop_3_Size = TweenService:Create(pop_3.RoughSpikeShock,tweenInfo_Slow,{Size = (pop_3.RoughSpikeShock.Size + Vector3.new(2,2,3))})

    local pop_1_Fade = TweenService:Create(pop_1.RoughSpikeShock,tweenInfo_Fast,{Transparency = 1})
    local pop_2_Fade = TweenService:Create(pop_2.RoughSpikeShock,tweenInfo_Fast,{Transparency = 1})
    local pop_3_Fade = TweenService:Create(pop_3.RoughSpikeShock,tweenInfo_Slow,{Transparency = 1})

    pop_3_Fade.Completed:Connect(function(playbackState)
        if playbackState == Enum.PlaybackState.Completed then
            pop_1:Destroy()
            pop_2:Destroy()
            pop_3:Destroy()
        end
    end)

    wait(.2)
    pop_1.Parent = workspace.RenderedEffects
    pop_1.CFrame = targetStand.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(-.2,-.2,-4.5))
    pop_1_Size:Play()
    pop_1_Fade:Play()
    wait(.4)
    pop_2.Parent = workspace.RenderedEffects
    pop_2.CFrame = targetStand.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(-.4,-.6,-3.5))
    pop_2_Size:Play()
    pop_2_Fade:Play()
    wait(.5)
    pop_3.Parent = workspace.RenderedEffects
    pop_3.CFrame = targetStand.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,.5,-5.5))
    pop_3_Size:Play()
    pop_3_Fade:Play()

end

return BulletKick


