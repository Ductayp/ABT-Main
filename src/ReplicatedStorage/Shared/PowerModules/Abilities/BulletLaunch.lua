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
local WeldedSound = require(Knit.PowerUtils.WeldedSound)
local hitboxMod = require(Knit.Shared.RaycastProjectileHitbox)

local Velocity = 300
local Lifetime = 2

local BulletLaunch = {}

--// --------------------------------------------------------------------
--// Handler Functions
--// --------------------------------------------------------------------

--// Initialize
function BulletLaunch.Initialize(params, abilityDefs)

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

end

--// Activate
function BulletLaunch.Activate(params, abilityDefs)

	-- check KeyState
	if params.KeyState == "InputBegan" then
		params.CanRun = true
	else
		params.CanRun = false
		return params
    end
    
    -- check cooldown
    if not Cooldown.Server_IsCooled(params) then
        params.CanRun = false
        return params
    end
    
    if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
        params.CanRun = false
        return params
    end

	-- set cooldown
    Cooldown.SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)

    -- block input
    require(Knit.PowerUtils.BlockInput).AddBlock(params.InitUserId, "BulletLaunch", 0.05)

    -- tween hitbox
    BulletLaunch.Run_Server(params, abilityDefs)

end

--// Execute
function BulletLaunch.Execute(params, abilityDefs)

    -- tween effects
	BulletLaunch.Run_Client(params, abilityDefs)

end


--// --------------------------------------------------------------------
--// Ability Functions
--// --------------------------------------------------------------------

function BulletLaunch.Run_Server(params, abilityDefs)

    print("BulletLaunch - SERVER")

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    local rootPart = initPlayer.Character.HumanoidRootPart
    params.BulletCFrame = initPlayer.Character.HumanoidRootPart.CFrame

    -- setup the hitbox
    local ignoreList = require(Knit.Shared.RaycastProjectileHitbox.IgnoreList)
    table.insert(ignoreList, initPlayer.Character)

    local dataPoints = hitboxMod:GetSquarePoints(rootPart.CFrame, 2, 2)
    local projectileData = {}
    projectileData["Points"] = dataPoints
    projectileData["Direction"] = rootPart.CFrame.LookVector
    projectileData["Velocity"] = Velocity
    projectileData["Lifetime"] = Lifetime
    projectileData["Iterations"] = Velocity / 3
    projectileData["Visualize"] = true
    projectileData["Ignore"] = ignoreList

    projectileData["Function"] = function(result)
        if result.Instance.Parent then

            --print("result", result)
            print("result parent", result.Instance.Parent)

            if result.Instance.Parent:FindFirstChild("Humanoid") then
                print("HIT A HUMANOID", result.Instance.Parent)

            end
            --localSkillEvent:FireAllClients("FlameLocalMod", "FirePunchBeamStop", player)
            --partHitPos = result.Position
        end
    end
    
    hitboxMod:CastProjectileHitbox(projectileData)

end

function BulletLaunch.Run_Client(params, abilityDefs)

    print("BulletLaunch - CLIENT")

    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    local rootPart = initPlayer.Character.HumanoidRootPart

    -- setup the stand, if its not there then dont run return
	local targetStand = Workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		targetStand = ManageStand.QuickRender(params)
    end

    -- run animation
    ManageStand.PlayAnimation(params, "KnifeThrow")

    --[[
    ManageStand.MoveStand(params, "Front")
    spawn(function()
        wait(1.5)
        ManageStand.MoveStand(params, "Idle")
    end)
    ]]--

    -- play the sound when it is fired
	WeldedSound.NewSound(targetStand.HumanoidRootPart, ReplicatedStorage.Audio.General.GenericWhoosh_Fast)


    -- clone in all parts
    local bullet = ReplicatedStorage.EffectParts.Abilities.BulletLaunch.Bullet:Clone()
    bullet.BodyVelocity.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
    bullet.BodyVelocity.P = 300
    bullet.BodyVelocity.Velocity = params.BulletCFrame.LookVector * 300 -- rootPart.CFrame.LookVector * 300
    bullet.CFrame = params.BulletCFrame --initPlayer.Character.HumanoidRootPart.CFrame --:ToWorldSpace(0,0,0)
    bullet.Parent = Workspace.RenderedEffects

    bullet.Touched:Connect(function(hit)
        print(hit)
    end)

    spawn(function()
        wait(Lifetime)
        bullet:Destroy()
    end)
    
    

end

return BulletLaunch