-- RedHot_Mob Mob
-- Pdab
-- 1/10/21

-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))


local RedHot_Mob = {}

--/ Model
RedHot_Mob.Model = ReplicatedStorage.Mobs.RHCP_Model

--/ Spawn
RedHot_Mob.RespawnTime = 5
RedHot_Mob.RandomPlacement = true
RedHot_Mob.Spawn_Z_Offset = 0
RedHot_Mob.Max_Spawned = 4

--/ Animations
RedHot_Mob.Animations = {
    Idle = "rbxassetid://507766666",
    Walk = "rbxassetid://507777826",
    Attack = {"rbxassetid://6245847704"},
}

--/ Defs
RedHot_Mob.Defs = {}
RedHot_Mob.Defs.XpValue = 500
RedHot_Mob.Defs.Health = 100
RedHot_Mob.Defs.WalkSpeed = 0
RedHot_Mob.Defs.JumpPower = 50
RedHot_Mob.Defs.Aggressive = true
RedHot_Mob.Defs.AttackSpeed = 3
RedHot_Mob.Defs.AttackRange = 20
RedHot_Mob.Defs.HitEffects = {Damage = {Damage = 20}}
RedHot_Mob.Defs.SeekRange = 60 -- In Studs
RedHot_Mob.Defs.ChaseRange = 80 -- In Studs
RedHot_Mob.Defs.IsMobile = false
RedHot_Mob.Defs.LifeSpan = 60 -- how long the mob lives before resapwn, in seconds

--/ Spawn Function
function RedHot_Mob.Pre_Spawn(mobData)

    -- set mob to inactive so its brain doesnt run yet
    mobData.Active = false
    mobData.SpawnCFrame = mobData.SpawnCFrame * CFrame.new(0,-4,0)

end

--/ Spawn Function
function RedHot_Mob.Post_Spawn(mobData)

    mobData.Model.HumanoidRootPart.Anchored = true
    
    local spawnTween = TweenService:Create(mobData.Model.HumanoidRootPart, TweenInfo.new(.5), {Position = mobData.Model.HumanoidRootPart.Position + Vector3.new(0, 4, 0)})
    spawnTween:Play()

    spawnTween.Completed:Connect(function()
        -- make the mob active so the brain runs
        mobData.Active = true
    end)

end

--// Setup_Animations
function RedHot_Mob.Setup_Animations(mobData)

        -- add an animator
        mobData.Animations = {} -- setup a table
        mobData.Animations.Attack = {} -- we need another table for attack aniamtions
        local animator = Instance.new("Animator")
        animator.Parent = mobData.Model.Humanoid
    
        -- idle animation
        local idleAnimation = Instance.new("Animation")
        idleAnimation.AnimationId = RedHot_Mob.Animations.Idle
        mobData.Animations.Idle = animator:LoadAnimation(idleAnimation)
        idleAnimation:Destroy()
    
        -- walk animation
        local walkAnimation = Instance.new("Animation")
        walkAnimation.AnimationId = RedHot_Mob.Animations.Walk
        mobData.Animations.Walk = animator:LoadAnimation(walkAnimation)
        walkAnimation:Destroy()
    
        -- attack animations
        for index, animationId in pairs(RedHot_Mob.Animations.Attack) do
            local newAnimation = Instance.new("Animation")
            newAnimation.AnimationId = animationId
            local newTrack = animator:LoadAnimation(newAnimation)
            table.insert(mobData.Animations.Attack, newTrack)
            newAnimation:Destroy()
        end

end

--// Setup_Attack
function  RedHot_Mob.Setup_Attack(mobData)
    -- nothing here. yet ...
end

--// Attack
function  RedHot_Mob.Attack(mobData)

    print("RHCP ATTACK - mobData: ", mobData)

    spawn(function()

        -- play attack animation
        local rand = math.random(1, #mobData.Animations.Attack)
        mobData.Animations.Attack[rand]:Play()

        local shockBall = ReplicatedStorage.EffectParts.Projectiles.ShockBall:Clone()
        shockBall.CFrame = mobData.Model.HumanoidRootPart.CFrame
        shockBall.Parent = Workspace
        shockBall.Anchored = false
        shockBall.BodyPosition.D = 125
        shockBall.BodyPosition.P = 1000
        shockBall.BodyPosition.MaxForce = Vector3.new(1,1,1) * 2000
        shockBall:SetNetworkOwner(nil)

        local expireTime = os.clock() + 5

        while game:GetService("RunService").Heartbeat:Wait() do

            if not mobData.AttackTarget then
                shockBall:Destroy()
                break
            end

            if not mobData.AttackTarget.Character then
                shockBall:Destroy()
                break
            end
            
            if not mobData.AttackTarget.Character.Humanoid then
                shockBall:Destroy()
                break
            end

            -- expire the shockball if its too old
            if os.clock() > expireTime then
                shockBall:Destroy()
                break
            end

            -- check for hits
            local magnitude = (shockBall.Position - mobData.AttackTarget.Character.HumanoidRootPart.Position).Magnitude
            if magnitude < .5 then
                if mobData.AttackTarget.Character.Humanoid then
                    if mobData.AttackTarget.Character.Humanoid.Health <= 0 then
                        shockBall:Destroy()
                        break
                    else
                        Knit.Services.MobService:HitPlayer(mobData.AttackTarget, mobData.Defs.HitEffects)
                        shockBall:Destroy()
                        break
                    end
                else
                    shockBall:Destroy()
                    break
                end
                break
            end

            -- update the BodyPosition
            shockBall.BodyPosition.Position = mobData.AttackTarget.Character.HumanoidRootPart.Position
            wait()
        end
    
    end)                          
end

--// Setup_Death
function RedHot_Mob.Setup_Death(mobData)
    -- nothing here, yet ...
end

--// Death
function RedHot_Mob.Death(mobData)

    local deathTween = TweenService:Create(mobData.Model.HumanoidRootPart, TweenInfo.new(.5), {Position = mobData.Model.HumanoidRootPart.Position + Vector3.new(0, -4, 0)})
    deathTween:Play()

end

--// Setup_Drop
function RedHot_Mob.Setup_Drop(mobData)

end

--// Drop
function RedHot_Mob.Drop(player, mobData)

end



return RedHot_Mob