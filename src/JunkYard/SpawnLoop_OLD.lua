-- MobService SpawnLoop

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

local utils = require(Knit.Shared.Utils)
local config = require(script.Parent.Config)
local serialNumber = 1 -- this starts at one and goes up for every mob spawned, used as a unique ID for each mob

local SpawnLoop = {}

function SpawnLoop.Run()

    local allSpawners = {}

    -- find all spawner, build a data table for each, also make the spawners invis
    for _,instance in pairs(Workspace:GetDescendants()) do
        if instance.Name == "MobService_Spawners" then
            for _,folder in pairs(instance:GetChildren()) do

                -- make a spawn group table
                local thisGroup = {}
                thisGroup.Name = folder.Name
                --thisGroup.Defs = require(Knit.MobModules.MobDefs[folder.Name])
                thisGroup.Defs = require(script.Parent.MobModules[folder.Name])
                thisGroup.RespawnClock = os.clock()
                thisGroup.Spawners = folder:GetChildren()

                -- make spawner part transparent
                for _,spawnerPart in pairs(thisGroup.Spawners) do
                    spawnerPart.Transparency = 1
                end

                -- insert the spawner group into the 
                table.insert(allSpawners, thisGroup)
            end
        end
    end

    wait(5) -- initial wait

    while wait(1) do -- basic spawn loop time

        for _, spawnGroup in pairs(allSpawners) do

            -- only spawn if the respawn cooldown is up
            if spawnGroup.RespawnClock < os.clock() - spawnGroup.Defs.RespawnTime then
                spawnGroup.RespawnClock = os.clock()

                -- count all mobs spawned in this group, across all spawners
                local spawnCount = 0
                for _,spawner in pairs(spawnGroup.Spawners) do
                    local thisCount = 0
                    for _,mob in pairs(spawner:GetChildren()) do
                        thisCount += 1
                    end
                    spawnCount += thisCount
                end

                -- if we are less than Max_Spawned across the whole spawner group
                if spawnCount < spawnGroup.Defs.Max_Spawned then

                    -- build a table of open spawners
                    local openSpawners = {}
                    for _, spawner in pairs(spawnGroup.Spawners) do
                        if #spawner:GetChildren() == 0 then
                            table.insert(openSpawners, spawner)
                        end
                    end

                    -- pick a spawner randomly from the open spawners
                    local rand = math.random(1, #openSpawners)
                    local pickedSpawner = openSpawners[rand]

                    -- create a new mobData object
                    local mobData = require(script.Parent.NewMob).Create(spawnGroup.Defs)

                    -- set the spawner this mob is owned by
                    mobData.Spawner = pickedSpawner

                    -- assign serialNumber to mob model and also add the mobData table to MobService.SpawnedMobs table
                    utils.NewValueObject("MobId", serialNumber, mobData.Model)
                    mobData.MobId = serialNumber
                    serialNumber += 1
                    

                    -- spawn it out
                    local offsetX
                    local offsetZ
                    if spawnGroup.Defs.RandomPlacement then
                        offsetX = math.random(-pickedSpawner.Size.X / 2, pickedSpawner.Size.X / 2)
                        offsetX = math.random(-pickedSpawner.Size.Z / 2, pickedSpawner.Size.Z / 2)
                    else
                        offsetX = 0
                        offsetX = 0
                    end

                    -- insert the mob in the MobService.SpawnedMobs table, will be actively running from here unless Pre_Spawn_Setup as has its Active value to false
                    table.insert(Knit.Services.MobService.SpawnedMobs, mobData)

                    -- set the mobs SpawnCFrame to the spawner part CFrame (we can change this in the Pre_Spawn function before spawn)
                    mobData.SpawnCFrame = pickedSpawner.CFrame * CFrame.new(offsetX, spawnGroup.Defs.Spawn_Z_Offset, offsetZ)

                    -- run the pre-spawn setup
                    spawnGroup.Defs.Pre_Spawn(mobData)

                    -- spawn the mob into the world
                    mobData.Model.PrimaryPart.CFrame = mobData.SpawnCFrame
                    mobData.Model.Parent = pickedSpawner

                    for _,object in pairs(mobData.Model:GetDescendants()) do
                        if object:IsA("BasePart") then
                            object.Anchored = false
                        end
                    end

                    if config.NetworkOwner_Server then
                        for _,object in pairs(mobData.Model:GetDescendants()) do
                            if object:IsA("BasePart") then
                                object:SetNetworkOwner(nil)
                            end
                        end
                    end

                    -- run the post-spawn setup
                    spawnGroup.Defs.Post_Spawn(mobData)

                    -- setup functions
                    spawnGroup.Defs.Setup_Animations(mobData)
                    spawnGroup.Defs.Setup_Attack(mobData)
                    spawnGroup.Defs.Setup_Death(mobData)
                    spawnGroup.Defs.Setup_Drop(mobData)
                    
                end
            end
        end
    end 

end


return SpawnLoop