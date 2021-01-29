-- Basic Projectile
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
local AbilityToggle = require(Knit.PowerUtils.AbilityToggle)
local ManageStand = require(Knit.Abilities.ManageStand)
local Cooldown = require(Knit.PowerUtils.Cooldown)
local RaycastHitbox = require(Knit.Shared.RaycastHitboxV3)


local BasicProjectile = {}

--// --------------------------------------------------------------------
--// Handler Functions
--// --------------------------------------------------------------------

--// Initialize
function BasicProjectile.Initialize(params, abilityDefs)

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
    
    -- tween effects
	BasicProjectile.Tween_Effects(params, abilityDefs)

end

--// Activate
function BasicProjectile.Activate(params, abilityDefs)

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

     -- require toggles to be inactive, excluding "Q"
     if not AbilityToggle.RequireOff(params.InitUserId, abilityDefs.RequireToggle_Off) then
        params.CanRun = false
        return params
    end

	-- set cooldown
    Cooldown.SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)

    -- set toggle
    AbilityToggle.QuickToggle(params.InitUserId, params.InputId, true)

    -- tween hitbox
    BasicProjectile.Tween_HitBox(params, abilityDefs)

end

--// Execute
function BasicProjectile.Execute(params, abilityDefs)

	if Players.LocalPlayer.UserId == params.InitUserId then
		print("Players.LocalPlayer == initPlayer: DO NOT RENDER")
		return
	end

    -- tween effects
	BasicProjectile.Tween_Effects(params, abilityDefs)

end


--// --------------------------------------------------------------------
--// Ability Functions
--// --------------------------------------------------------------------

function BasicProjectile.Tween_HitBox(params, abilityDefs)

    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

    -- clone out a new hitpart
    local hitPart = abilityDefs.HitBox:Clone()
    hitPart.Parent = Workspace.ServerHitboxes[params.InitUserId]
    hitPart.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,1,-6))
    hitPart:SetNetworkOwner(nil)

    -- make a new hitbox
    local newHitbox = RaycastHitbox:Initialize(hitPart)
    newHitbox:HitStart()
    --newHitbox:DebugMode(true)

    -- Makes a new event listener for raycast hits
    newHitbox.OnHit:Connect(function(hit, humanoid)
        Knit.Services.PowersService:RegisterHit(initPlayer, humanoid.Parent, abilityDefs.HitEffects)
    end)

    -- calculate flight data
    local destinatonCFrame = hitPart.CFrame:ToWorldSpace(CFrame.new( 0, 0, - abilityDefs.Range))
    local flightTime = (abilityDefs.Range / abilityDefs.Speed)

    -- add to Debris
    Debris:AddItem(hitPart, fightTime)

    -- Tween hitbox
    local tweenInfo = TweenInfo.new(flightTime, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hitPart, tweenInfo, {CFrame = destinatonCFrame})
    tween:Play()

    tween.Completed:Connect(function(playbackState)
        if playbackState == Enum.PlaybackState.Completed then
            hitPart:Destroy()
        end
    end)

end

function BasicProjectile.Tween_Effects(params, abilityDefs)


    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

    -- setup the stand, if its not there then dont run return
	local targetStand = workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		targetStand = ManageStand.QuickRender(params)
    end

    -- run animation
    if abilityDefs.StandAnimation then
        ManageStand.PlayAnimation(params, abilityDefs.StandAnimation)
    end
    
    if abilityDefs.StandMove then
        ManageStand.MoveStand(params, abilityDefs.StandMove.PositionName)
        spawn(function()
            wait(abilityDefs.StandMove.ReturnDelay)
            ManageStand.MoveStand(params, "Idle")
        end)
    end

    -- clone in all parts
    local projectilePart = abilityDefs.Projectile:Clone()
    projectilePart.Parent = workspace.RenderedEffects
    projectilePart.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,1,-6))
    Debris:AddItem(projectilePart, 30) -- be sure we debris i sjust in case

    -- calculate flight time
    local ping = Knit.Controllers.PlayerUtilityController:GetPing()
    local flightTime = (abilityDefs.Range / abilityDefs.Speed)
    local newFlightTime
    if params.SystemStage == "Initialize" then
        newFlightTime = flightTime + ping -- this is the initPlayer, add their ping to flight time so it syncs with hitbox
    else
        newFlightTime = flightTime - ping-- this is the all other players, subtract their ping to flight time so it syncs with hitbox
    end

    -- garuntee at least 0.1 flight time and no more that 150% of original time
    if newFlightTime < 0.1 then
        newFlightTime = 0.1
    elseif newFlightTime > (flightTime * 1.5) then
        newFlightTime = lightTime * 1.5
    end

    -- set destimation cframe
    local destinatonCFrame = projectilePart.CFrame:ToWorldSpace(CFrame.new( 0, 0, - abilityDefs.Range))

    -- the tween
    local tweenInfo = TweenInfo.new(newFlightTime, Enum.EasingStyle.Linear)
    local tweenPart = TweenService:Create(projectilePart, tweenInfo,{CFrame = destinatonCFrame})

    -- CFrame the parts right before we launch them
    projectilePart.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,1,-6))
    tweenPart:Play()

    -- destroy when tween is done
    tweenPart.Completed:Connect(function(playbackState)
        if playbackState == Enum.PlaybackState.Completed then
            projectilePart:Destroy()
        end
    end)

    -- setup destroying cosmetic parts, destroy when it hits a humanoid
    projectilePart.Touched:Connect(function(hit)
        --local hitToggle = true
        local humanoid = hit.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            if humanoid.Parent.Name ~= initPlayer.Name then

                --[[
                if hitToggle == true then
                    hitToggle = false
                    local effectParams = {
                        HideNumbers = true,
                        HitCharacter = humanoid.Parent
                    }
                    require(Knit.Effects.Damage).Client_RenderEffect(effectParams)
                end
                ]]--

                wait(.25)
                projectilePart:Destroy()
            end
        end
    end) 
    
    

end

return BasicProjectile