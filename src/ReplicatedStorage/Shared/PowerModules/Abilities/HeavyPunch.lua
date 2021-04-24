-- Heavy Punch Ability
-- PDab
-- 12-1-2020

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local AbilityToggle = require(Knit.PowerUtils.AbilityToggle)
local ManageStand = require(Knit.Abilities.ManageStand)
local Cooldown = require(Knit.PowerUtils.Cooldown)
local RayHitbox = require(Knit.PowerUtils.RayHitbox)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)

local HITBOX_DELAY = 0.4
local ANIMATION_DELAY = 0.4

local HeavyPunch = {}

--// --------------------------------------------------------------------
--// Handler Functions
--// --------------------------------------------------------------------

--// Initialize
function HeavyPunch.Initialize(params, abilityDefs)

	-- check KeyState
	if params.KeyState == "InputBegan" then
		params.CanRun = true
	else
		params.CanRun = false
		return
    end
    
    -- check cooldown
    if not Cooldown.Client_IsCooled(params) then
        print("not cooled down", params)
		params.CanRun = false
		return
    end

    if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
        params.CanRun = false
        return params
    end

    -- tween effects
    spawn(function()
        --HeavyPunch.Run_Effects(params, abilityDefs)
    end)
	
end

--// Activate
function HeavyPunch.Activate(params, abilityDefs)

	-- check KeyState
	if params.KeyState == "InputBegan" then
		params.CanRun = true
	else
		params.CanRun = false
		return
    end
    
    -- check cooldown
	if not Cooldown.Client_IsCooled(params) then
		params.CanRun = false
		return
    end
    

    if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
        params.CanRun = false
        return params
    end

	-- set cooldown
    Cooldown.SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)

    -- block input
    require(Knit.PowerUtils.BlockInput).AddBlock(params.InitUserId, "HeavyPunch", 1)

    -- tween hitbox
    HeavyPunch.Run_HitBox(params, abilityDefs)

end

--// Execute
function HeavyPunch.Execute(params, abilityDefs)

    --[[
	if Players.LocalPlayer.UserId == params.InitUserId then
		print("Players.LocalPlayer == initPlayer: DO NOT RENDER")
		return
	end
    ]]--

    -- tween effects
	HeavyPunch.Run_Effects(params, abilityDefs)

end


--// --------------------------------------------------------------------
--// Ability Functions
--// --------------------------------------------------------------------

function HeavyPunch.Run_HitBox(params, abilityDefs)

    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    
    -- handle walkspeed
    spawn(function()
        initPlayer.Character.Humanoid.WalkSpeed = 0
        wait(1)
        initPlayer.Character.Humanoid.WalkSpeed = require(Knit.StateModules.WalkSpeed).GetModifiedValue(initPlayer)
    end)


    -- spawn function for hitbox with a delay
    spawn(function()
        wait(HITBOX_DELAY)

        -- clone out a new hitpart
        local hitPart = ReplicatedStorage.EffectParts.Abilities.HeavyPunch.HitBox:Clone()
        hitPart.Parent = Workspace.ServerHitboxes[params.InitUserId]
        hitPart.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-7))
        Debris:AddItem(hitPart, .6)

        -- make a new hitbox
        local newHitbox = RayHitbox.New(initPlayer, abilityDefs, hitPart, true)
        newHitbox:HitStart()
        --newHitbox:DebugMode(true)

        -- tween the hitbox a tiny bit to register hits
        local tweenInfo = TweenInfo.new(.7)
        local tween = TweenService:Create(hitPart, tweenInfo, {CFrame = hitPart.CFrame * CFrame.new(0,0,-5)})
        tween:Play()

    end)
end

function HeavyPunch.Run_Effects(params, abilityDefs)

    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

    -- setup the stand, if its not there then dont run return
	local targetStand = workspace.PlayerStands[initPlayer.UserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		targetStand = ManageStand.QuickRender(params)
    end

    --move the stand and do animations
    spawn(function()
        local moveTime = ManageStand.MoveStand(params, "Front")
        ManageStand.PlayAnimation(params, "HeavyPunch")
        ManageStand.Aura_On(params)
        wait(1.5)
        ManageStand.MoveStand(params, "Idle")
        wait(.5)
        ManageStand.Aura_Off(params)
    end)

    wait(ANIMATION_DELAY)

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

    local ring_1_FadeIn = TweenService:Create(ring_1.ShockRing,TweenInfo.new(.1),{Transparency = .9})
    local ring_2_FadeIn = TweenService:Create(ring_2.ShockRing,TweenInfo.new(.1),{Transparency = .9})
    local ring_3_FadeIn = TweenService:Create(ring_3.ShockRing,TweenInfo.new(.1),{Transparency = .9})
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

    -- play the sound
	WeldedSound.NewSound(targetStand.HumanoidRootPart, abilityDefs.Sounds.Punch)

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


