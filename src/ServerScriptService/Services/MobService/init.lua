-- Mob Service
-- PDab
-- 1/8/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local PhysicsService = game:GetService("PhysicsService")
local Debris = game:GetService("Debris")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local MobService = Knit.CreateService { Name = "MobService", Client = {}}
local RemoteEvent = require(Knit.Util.Remote.RemoteEvent)

local config = require(script.Config)
MobService.SpawnedMobs = {} -- table of all spawned mobs

MobService.DebugMode = false

function MobService:GetMobById(sentMobId)

    return MobService.SpawnedMobs[sentMobId]
end

function MobService:GetMobsInMapZone(sentMapZone)

    local mobs = {}
    for mobId, mobData in pairs(MobService.SpawnedMobs) do
        if mobData.Defs.MapZone == sentMapZone then
            mobs[mobId] = mobData
        end
    end

    return mobs
end

--// HitPlayer
function MobService:HitPlayer(player, hitEffects)
    if not player then return end
    if Players:FindFirstChild(player.Name) then
        Knit.Services.PowersService:NPC_RegisterHit(player, hitEffects)
    end
end

--// DamageMob
function MobService:DamageMob(player, mobId, damage)

    if not player then return end
    if not Players:FindFirstChild(player.Name) then return end
        
    local thisMob = MobService.SpawnedMobs[mobId]
    if not thisMob then return end

    -- apply player damage counts only if the mob is not dead
    if thisMob.BrainState ~= "Dead" then
        if thisMob.PlayerDamage[player] == nil then
            thisMob.PlayerDamage[player] = damage
        else
            thisMob.PlayerDamage[player] += damage
        end
    end
end

--// DeSpawnMob
function MobService:DeSpawnMob(mobData)

    spawn(function()
        if mobData.Functions.DeSpawn then
            mobData.Functions.DeSpawn(mobData)
        end
    
        self:KillMob(mobData)
    end)

end

--// KillMob
function MobService:KillMob(mobData)

    -- break the joints, YEET
    mobData.Model:BreakJoints()

    -- run the models death function
    mobData.Functions.Death(mobData)

    -- subtract the mob from its counter
    if mobData.Spawner.SpawnCounter.Value < 1 then
        mobData.Spawner.SpawnCounter.Value = 0
    else
        mobData.Spawner.SpawnCounter.Value = mobData.Spawner.SpawnCounter.Value - 1
    end
    

    spawn(function()
        wait(5)
        mobData.Model:Destroy()
        MobService.SpawnedMobs[mobData.MobId] = nil
    end)

    -- cehck if a player did more than 1/3 of total damage
    for player, damage in pairs(mobData.PlayerDamage) do
        if damage > mobData.Defs.Health / 3 then

            if Players:FindFirstChild(player.Name) then

                -- get drops
                local dropRewards = mobData.Functions.Drop(player, mobData)

                -- get modified values for notifications
                local xp_Multiplier = require(Knit.StateModules.Multiplier_Experience).GetTotalMultiplier(player)
                local orbs_Multiplier = require(Knit.StateModules.Multiplier_Orbs).GetTotalMultiplier(player)
                local xp_Modified = dropRewards.XP * xp_Multiplier
                local orbs_Modified = dropRewards.SoulOrbs * orbs_Multiplier

                -- send notifications for Xp and Soul Orbs
                local notificationParams = {}
                notificationParams.Icon = "MobKill"
                notificationParams.Text = "Killed: " .. mobData.Defs.Name .. "<br/>Stand XP: " .. tostring(xp_Modified) .. "    +   Soul Orbs: " ..  tostring(orbs_Modified)
                Knit.Services.GuiService:Update_Notifications(player, notificationParams)

                -- give unmodified rewardsfor Xp and Soul Orbs
                Knit.Services.InventoryService:Give_Xp(player, dropRewards.XP)
                Knit.Services.InventoryService:Give_Currency(player, "SoulOrbs", dropRewards.SoulOrbs, "MobDrop")

                -- handle item rewards
                local itemDefs = require(Knit.Defs.ItemDefs)
                for itemKey, itemValue in pairs(dropRewards.Items) do

                    local thisItemDef = itemDefs[itemKey]

                    local notificationParams = {}
                    notificationParams.Icon = "Item"
                    notificationParams.Text = mobData.Defs.Name .." Dropped Item:<br/>" .. thisItemDef.Name .. " x" .. tostring(itemValue)
                    Knit.Services.GuiService:Update_Notifications(player, notificationParams)

                    Knit.Services.InventoryService:Give_Item(player, itemKey, itemValue)

                end
            end
        end

    end

end

function MobService:PinMob(mobId, duration)

    local thisMob = MobService.SpawnedMobs[mobId]
    if not thisMob then return end

    if thisMob and thisMob.Model.Humanoid then

        thisMob.Model.Humanoid:MoveTo(thisMob.Model.HumanoidRootPart.Position)

        local newValueObject = Instance.new("BoolValue")
        newValueObject.Name = "IsPinned"
        newValueObject.Value = true
        newValueObject.Parent = thisMob.Model.HumanoidRootPart

        spawn(function()
            wait(duration)
            newValueObject:Destroy()
        end)

        self:PauseAnimations(mobId, duration)

    end



end


--// PauseAnimations
function MobService:PauseAnimations(mobId, duration)

    local thisMob 
    for _, mobData in pairs(MobService.SpawnedMobs) do
        if mobData.MobId == mobId then
            thisMob = mobData
            break
        end
    end

    if thisMob then
        spawn(function()

            for _, animation in pairs(thisMob.Animations) do
                if animation.IsPlaying then
                    animation:Stop()
                end
            end

            thisMob.DisableAnimations = true
            wait(duration)
            thisMob.DisableAnimations = false

        end)
    end

end

--// SetCollisionGroup
function MobService:SetCollisionGroup(model, group)
	if model:IsA("BasePart") then
		PhysicsService:SetPartCollisionGroup(model, group);
	else
		local modelDescendants = model:GetDescendants()
		for i = 1, #modelDescendants do
			local model = modelDescendants[i];
			if model:IsA("BasePart") then
				PhysicsService:SetPartCollisionGroup(model, group);
			end
		end
	end
end

--// PlayerAdded
function MobService:PlayerAdded(player)

    -- set players collision group according to Config
    if config.PlayerCollide == false then

        local character = player.Character or player.CharacterAdded:Wait()
		self:SetCollisionGroup(character, "Mob_NoCollide");

		player.CharacterAdded:Connect(function(character)

			self:SetCollisionGroup(character, "Mob_NoCollide");
		end)
    end

end


--// KnitStart
function MobService:KnitStart()

    spawn(function()
        require(script.SpawnLoop).Run()
    end)

    spawn(function()
        --self:MobBrain() -- this loops and performs actions on each spawned mob
        require(script.MobBrain).Run()
    end)
    
end

--// KnitInit
function MobService:KnitInit()

        -- create a spawned items folder
        local spawnedMobsFolder = Instance.new("Folder")
        spawnedMobsFolder.Name = "SpawnedMobs"
        spawnedMobsFolder.Parent = Workspace
        spawnedMobsFolder:SetAttribute("IgnoreProjectiles", true)

    -- create no-collision group and set it
    PhysicsService:CreateCollisionGroup("Mob_NoCollide")
    PhysicsService:CollisionGroupSetCollidable("Mob_NoCollide", "Mob_NoCollide", false)

    -- Player Added event
    Players.PlayerAdded:Connect(function(player)
        self:PlayerAdded(player)
    end)

    -- Player Added event for studio tesing, catches when a player has joined before the server fully starts
    for _, player in ipairs(Players:GetPlayers()) do
        self:PlayerAdded(player)
    end

    -- Player Removing event
    Players.PlayerRemoving:Connect(function(player)
        --self:PlayerRemoved(player)
    end)

end


return MobService