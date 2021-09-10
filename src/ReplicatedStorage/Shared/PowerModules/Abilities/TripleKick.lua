-- TripleKick Ability
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

local TripleKick = {}

--// --------------------------------------------------------------------
--// Handler Functions
--// --------------------------------------------------------------------

--// Initialize
function TripleKick.Initialize(params, abilityDefs)

	-- checks
	if params.KeyState == "InputBegan" then params.CanRun = true end
    if params.KeyState == "InputEnded" then params.CanRun = false return end
    if not Cooldown.Client_IsCooled(params) then params.CanRun = false return end
    if not Cooldown.Server_IsCooled(params) then params.CanRun = false return end
    if abilityDefs.RequireToggle_On then
        if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then params.CanRun = false print("YESSSSS") return end
    end

    Cooldown.Client_SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)
    
    -- tween effects
    spawn(function()
        TripleKick.Run_Effects(params, abilityDefs)
    end)
	
end

--// Activate
function TripleKick.Activate(params, abilityDefs)

	-- checks
	if params.KeyState == "InputBegan" then params.CanRun = true end
    if params.KeyState == "InputEnded" then params.CanRun = false return end
    if not Cooldown.Server_IsCooled(params) then params.CanRun = false return end
    if abilityDefs.RequireToggle_On then
        if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then params.CanRun = false return end
    end

    Cooldown.Server_SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)

    -- block input
    require(Knit.PowerUtils.BlockInput).AddBlock(params.InitUserId, "TripleKick", 2)

    -- tween hitbox
    spawn(function()
        TripleKick.Run_HitBox(params, abilityDefs)
    end)
    
end

--// Execute
function TripleKick.Execute(params, abilityDefs)

	if Players.LocalPlayer.UserId == params.InitUserId then
		return
	end

    -- tween effects
	TripleKick.Run_Effects(params, abilityDefs)

end


--// --------------------------------------------------------------------
--// Ability Functions
--// --------------------------------------------------------------------


function TripleKick.Run_HitBox(params, abilityDefs)

    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    
    -- drop the walkspeed
    spawn(function()
        initPlayer.Character.Humanoid.WalkSpeed = 5
        wait(2)
        initPlayer.Character.Humanoid.WalkSpeed = require(Knit.StateModules.WalkSpeed).GetModifiedValue(initPlayer)
    end)

    -- spawn function for hitbox with a delay
    spawn(function()

        -- clone out a new hitpart
        local hitPart = ReplicatedStorage.EffectParts.Abilities.TripleKick.HitBox:Clone()
        hitPart.Parent = Workspace.ServerHitboxes[params.InitUserId]

        -- weld it
        local newWeld = Instance.new("Weld")
        newWeld.C1 =  CFrame.new(0, 0, 6.5)
        newWeld.Part0 = initPlayer.Character.HumanoidRootPart
        newWeld.Part1 = hitPart
        newWeld.Parent = hitPart

        -- small delay here for animations
        wait(.3) 

        -- hit counter for triple kick
        for count = 1, 3 do

            -- set the HitEffects based on the hit counter
            abilityDefs.HitEffects = require(abilityDefs.AbilityMod).HitEffects[count]

            -- create a new hitbox and pass is the abilitDef.HItEffect based on the hit ounter
            local newHitbox = RayHitbox.New(initPlayer, abilityDefs, hitPart, true)
            newHitbox:HitStart()
            --newHitbox:DebugMode(true)

            -- move it to make rays happen
            newWeld.C1 =  CFrame.new(0, 0, 5)
            wait() 
            newWeld.C1 =  CFrame.new(0, 0, 6.5)

            wait(.3)-- the pause between hitboxes so it matches with animations
            newHitbox:HitStop()
            wait()

            -- cleanup at the end
            if count == 3 then
                hitPart:Destroy()
            end

        end

    end)
end

function TripleKick.Run_Effects(params, abilityDefs)

    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

    -- setup the stand, if its not there then dont run return
	local targetStand = workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		targetStand = ManageStand.QuickRender(params)
    end

    --move the stand and do animations
    spawn(function()
        ManageStand.MoveStand(params, "Front")
        ManageStand.PlayAnimation(params, "TripleKick")
        wait(1.5)
        ManageStand.MoveStand(params, "Idle")
    end)

        -- run animation
    if abilityDefs.StandAnimation then
        ManageStand.PlayAnimation(params, abilityDefs.StandAnimation)
    end

    local pop_1 = ReplicatedStorage.EffectParts.Abilities.TripleKick.TripleKickPop:Clone()
    local pop_2 = ReplicatedStorage.EffectParts.Abilities.TripleKick.TripleKickPop:Clone()
    local pop_3 = ReplicatedStorage.EffectParts.Abilities.TripleKick.TripleKickPop:Clone()

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
    WeldedSound.NewSound(targetStand.HumanoidRootPart, ReplicatedStorage.Audio.General.GenericWhoosh_Fast)
    
    wait(.4)
    pop_2.Parent = workspace.RenderedEffects
    pop_2.CFrame = targetStand.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(-.4,-.6,-3.5))
    pop_2_Size:Play()
    pop_2_Fade:Play()
    WeldedSound.NewSound(targetStand.HumanoidRootPart, ReplicatedStorage.Audio.General.GenericWhoosh_Fast)

    wait(.5)
    pop_3.Parent = workspace.RenderedEffects
    pop_3.CFrame = targetStand.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,.5,-5.5))
    pop_3_Size:Play()
    pop_3_Fade:Play()
    WeldedSound.NewSound(targetStand.HumanoidRootPart, ReplicatedStorage.Audio.General.GenericWhoosh_Slow)

end

return TripleKick


