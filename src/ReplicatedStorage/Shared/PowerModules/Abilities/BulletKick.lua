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
local ManageStand = require(Knit.Abilities.ManageStand)
local DamageEffect = require(Knit.Effects.Damage)
local KnockBack = require(Knit.Effects.KnockBack)
local SimpleHitbox = require(Knit.PowerUtils.SimpleHitbox)

local BulletKick = {}

function BulletKick.Activate(initPlayer,params)
    
    -- drop the walkspeed
    spawn(function()
        initPlayer.Character.Humanoid.WalkSpeed = 5
        wait(2)
        initPlayer.Character.Humanoid.WalkSpeed = require(Knit.StateModules.WalkSpeed).GetModifiedValue(initPlayer)
    end)
    

    -- spawn function for hitbox with a delay
    spawn(function()

        wait(.3) -- small delay here for animations

        -- make a new hitbox, it stays in place
        local boxParams = {}
        boxParams.Size = Vector3.new(4,3,6.5)
        boxParams.Transparency = 1
    
        for count = 1, 3 do

            boxParams.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-4.5))
        
            -- set the look vector for the KnockBack effect
            params.BulletKick.HitEffects.KnockBack.LookVector = boxParams.CFrame.LookVector 
    
            -- make a new hitbox
            local newHitbox = SimpleHitbox.NewHitBox(initPlayer,boxParams)
            Debris:AddItem(newHitbox, .5)
    
            newHitbox.ChildAdded:Connect(function(hit)
                if hit.Name == "CharacterHit" then
                    if hit.Value ~= initPlayer.Character then

                        if count == 3 then
                            local characterHit = hit.Value
                            Knit.Services.PowersService:RegisterHit(initPlayer,characterHit,params.BulletKick.HitEffects)
                        else
                            local characterHit = hit.Value
                            Knit.Services.PowersService:RegisterHit(initPlayer,characterHit,{Damage = params.BulletKick.HitEffects.Damage})
                        end
                        
                    end
                end
            end)

            wait(.3) -- the pause between hitboxes so it matches with animations
        end

    end)
end

function BulletKick.Execute(initPlayer,params)

    -- setup the stand, if its not there then dont run return
	local targetStand = workspace.PlayerStands[initPlayer.UserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		return
    end

    --move the stand and do animations
    spawn(function()
        ManageStand.MoveStand(initPlayer,{AnchorName = "Front"})
        ManageStand.PlayAnimation(initPlayer,params,"BulletKick")
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


