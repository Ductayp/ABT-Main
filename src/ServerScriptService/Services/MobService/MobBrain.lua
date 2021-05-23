-- MobService - MobBrai

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

local MobBrain = {}

function MobBrain.Run()

    
    while game:GetService("RunService").Heartbeat:Wait() do
       
        -- iterate through all spawned mobs on each loop
        for index, mobData in pairs(Knit.Services.MobService.SpawnedMobs) do

            -- only run the mobs brain if it is active
            if mobData.Active then

                -- only run the brain if the mobs last update is more than .25 seconds ago
                if mobData.LastUpdate < os.clock() + 0.25 then
                    mobData.LastUpdate = os.clock()

                    if Knit.Services.MobService.DebugMode then
                        if mobData.Model.Head:FindFirstChild("StateText") then
                            mobData.Model.Head.StateText.TextLabel.Visible = true
                            mobData.Model.Head.StateText.TextLabel.Text = mobData.BrainState
                        end
                    end
                    
                    -- test print
                    --[[
                    if mobData.BrainState == "Wait" then
                        print(mobData.BrainState)
                        print(mobData.Model.Name)
                        print(Knit.Services.MobService.SpawnedMobs)
                    end
                    ]]--

                    -- NOT DEAD: if this mob is NOT dead, do the brain!
                    if mobData.IsDead == false then

                        --// STATES ---------------------------------------------

                        if MobBrain["State_" .. mobData.BrainState] then
                            MobBrain["State_" .. mobData.BrainState](mobData)
                        end

                        
                        --// ACTIONS ---------------------------------------------

                        -- BRAIN ACTION: Do Move
                        if mobData.Defs.IsMobile then
                            if mobData.MoveTarget then

                                local isPinned = mobData.Model.HumanoidRootPart:FindFirstChild("IsPinned")
                                if not isPinned then

                                    -- do the move
                                    mobData.Model.Humanoid:MoveTo(mobData.MoveTarget)

                                    -- handle animations
                                    if mobData.DisableAnimations then
                                        mobData.Animations.Walk:Stop()
                                    else
                                        if not mobData.Animations.Walk.IsPlaying then mobData.Animations.Walk:Play() end
                                        mobData.Animations.Idle:Stop()
                                    end

                                end

                            else
                                -- stop movement
                                mobData.Model.Humanoid:MoveTo(mobData.Model.HumanoidRootPart.Position)

                                -- handle animations
                                mobData.Animations.Walk:Stop()
                                if not mobData.Animations.Idle.IsPlaying then mobData.Animations.Idle:Play() end

                            end
                        else
                            if not mobData.Animations.Idle.IsPlaying then mobData.Animations.Idle:Play() end
                        end

                        --// EVENTS ---------------------------------------------

                        -- BRAIN EVENT: Set Target
                        if not mobData.TargetTime then mobData.TargetTime = os.clock() end
                        if os.clock() >  mobData.TargetTime then

                            mobData.TargetTime = os.clock() + .5

                            local playersInZone = Knit.Services.PlayerUtilityService:GetPlayersInMapZone(mobData.Defs.MapZone)
                            for _, player in pairs(playersInZone) do
    
                                -- get a table of player within range
                                local inRange = {}
                                if player:DistanceFromCharacter(mobData.Spawner.Position) <= mobData.Defs.SeekRange then
                                    table.insert(inRange, player)
                                end
    
                                if #inRange > 0 then
                                    if mobData.Defs.Aggressive == true then
                                        local rand = math.random(1, #inRange)
                                        mobData.AttackTarget = inRange[rand]
                                    else
                                        if mobData.PlayerDamage ~= nil then
    
                                            -- gat a table of players who have done damage AND are in range
                                            local attackList = {} 
                                            for damagePlayer, damage in pairs(mobData.PlayerDamage) do
                                                for _,inRangePlayer in pairs(inRange) do
                                                    if damagePlayer == inRangePlayer then
                                                        attackList[damagePlayer] = damage
                                                    end
                                                end
                                            end
    
                                            -- attack the player with the highest damage
                                            local highestDamage = 0
                                            for player, damage in pairs(attackList) do
                                                if damage > highestDamage then
                                                    highestDamage = damage
                                                    mobData.AttackTarget = player
                                                end
                                            end
    
                                        end
                                    end
                                end
                            end
                        end


                        -- BRAIN EVENT: Is Mob Dead? -- check if mob is dead, handle death
                        if mobData.Model.Humanoid.Health <= 0 then
                            mobData.BrainState = "Dead"
                            mobData.StateTime = os.clock()
                            mobData.IsDead = true
                            mobData.DeadTime = os.clock()
                            Knit.Services.MobService:KillMob(mobData)
                        end

                        -- BRAIN EVENT: LifeSpan  - check the mobs LifeSpan and kill it if its old
                        if mobData.SpawnTime < os.clock() - mobData.Defs.LifeSpan then
                            mobData.BrainState = "Dead"
                            mobData.StateTime = os.clock()
                            mobData.IsDead = true
                            mobData.DeadTime = os.clock()
                            mobData.PlayerDamage = {} -- delete all player damage
                            Knit.Services.MobService:KillMob(mobData)
                        end

                    end
                end

            end
        end
        wait()
    end

end

--// State_Attack
function MobBrain.State_Attack(mobData)

    if mobData.LastAttack < os.clock() - mobData.Defs.AttackSpeed then

        if not mobData.Model.HumanoidRootPart:FindFirstChild("BlockAttacks") then

            -- run attack function
            mobData.Functions.Attack(mobData)
 
            -- brain settings
            --mobData.AttackTarget = nil
            mobData.LastAttack = os.clock()
            mobData.BrainState = "Chase"
            mobData.StateTime = os.clock()
        end

    else
        mobData.BrainState = "Chase"
        mobData.StateTime = os.clock()
    end

end

--// State_Wait
function MobBrain.State_Wait(mobData)

    -- set move
    mobData.MoveTarget = nil

    -- set chase if we have a target
    if mobData.AttackTarget then
        mobData.BrainState = "Chase"
        mobData.StateTime = os.clock()
        return
    end

    -- if we get too far away or we have not attack target then return to the spawner (overrides the chase set above)
    local spawnerMagnitude = (mobData.Model.HumanoidRootPart.Position - mobData.Spawner.Position).Magnitude
    if spawnerMagnitude > mobData.Defs.ChaseRange then
        mobData.BrainState = "Return"
        mobData.AttackTarget = nil
        mobData.StateTime = os.clock()
        return
    end

    -- if theres no attack target and we are inside the chase range, give 1 second then send the mob back to spawner
    if spawnerMagnitude < mobData.Defs.ChaseRange then
        if mobData.StateTime < os.clock() + 1 then

            mobData.BrainState = "Return"
            mobData.AttackTarget = nil
            mobData.StateTime = os.clock()
            return
        end
    end

    print("WAIT DEAD")

end

--// State_Home
function MobBrain.State_Home(mobData)

    if not mobData.Model.HumanoidRootPart then return end
    mobData.Model.HumanoidRootPart.Anchored = true

    --mobData.Animations.Idle:Play()

    -- set chase if we have a target
    if mobData.AttackTarget then
        mobData.Model.HumanoidRootPart.Anchored = false
        mobData.Model.HumanoidRootPart:SetNetworkOwner(nil)
        mobData.BrainState = "Chase"
        mobData.StateTime = os.clock()
        return
    end

end

--// State_Return
function MobBrain.State_Return(mobData)
    
    -- set move
    mobData.MoveTarget = mobData.Spawner.Position

    -- check if we are too far from Home
    local rangeMagnitude = (mobData.Model.HumanoidRootPart.Position - mobData.Spawner.Position).Magnitude
    if rangeMagnitude < 5 then 
        mobData.BrainState = "Home"
        mobData.AttackTarget = nil
        mobData.MoveTarget = nil
        mobData.StateTime = os.clock()
    end

    -- if we get stuck in the return state too long, kill the mob
    if os.clock() > mobData.StateTime + 10 then
        mobData.PlayerDamage = nil
        mobData.IsDead = true
        mobData.DeadTime = os.clock()
    end

    -- if a player gets back in range, set it back to chase
    if mobData.AttackTarget ~= nil then
        if os.clock() > mobData.StateTime + 1 then
            mobData.BrainState = "Chase"
            mobData.StateTime = os.clock()
        end

    end

end

--// State_Chase
function MobBrain.State_Chase(mobData)

-- if chaseTarget is nil, then return to home
    if mobData.AttackTarget == nil then
        mobData.BrainState = "Return"
    end

    if mobData.BrainState == "Chase" then

        if mobData.AttackTarget:DistanceFromCharacter(mobData.Model.HumanoidRootPart.Position) > mobData.Defs.AttackRange then

            mobData.MoveTarget = mobData.AttackTarget.Character.HumanoidRootPart.Position
        
        else
            --mobData.MoveTarget = nil
            mobData.BrainState = "Attack"
        end

        -- if we get too far away, return to the spawner
        local spawnerMagnitude = (mobData.Model.HumanoidRootPart.Position - mobData.Spawner.Position).Magnitude
        if spawnerMagnitude > mobData.Defs.ChaseRange then
            mobData.BrainState = "Return"
            mobData.AttackTarget = nil
            mobData.StateTime = os.clock()
        end
    end
end


return MobBrain