-- MobService SpawnLoop

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

local utils = require(Knit.Shared.Utils)
local config = require(script.Parent.Config)

local spawnLoopCycleTime = 1
local serialNumber = 1 -- this starts at one and goes up for every mob spawned, used as a unique ID for each mob

local activeMob_Modules = {
    script.Parent.MobModules.Santana,
    script.Parent.MobModules.RedHot,
    script.Parent.MobModules.Wamuu,
}

local SpawnLoop = {}

--// SpawnLoop
function SpawnLoop.Run()

    wait(5) -- initial wait

    while game:GetService("RunService").Heartbeat:Wait() do -- basic spawn loop time

        for _, mobModule in pairs(activeMob_Modules) do

            local thisModule = require(mobModule)
            if thisModule.RespawnClock < os.clock() - thisModule.RespawnTime then
                thisModule.RespawnClock = os.clock()

                -- count all mobs spawned across all spawners. allows for multiple mobs per spawner
                local spawnCount = 0
                local spawners = thisModule.SpawnersFolder:GetChildren()
                for _, spawner in pairs(spawners) do
                    local thisCount = 0
                    for _,mob in pairs(spawner:GetChildren()) do
                        thisCount += 1
                    end
                    spawnCount += thisCount
                end

                -- if we are less than Max_Spawned across the whole spawner group
                if spawnCount < thisModule.Max_Spawned then

                    -- build a table of open spawners
                    local openSpawners = {}
                    for _, spawner in pairs(spawners) do
                        if #spawner:GetChildren() == 0 then
                            table.insert(openSpawners, spawner)
                        end
                    end

                    -- pick a spawner randomly from the open spawners
                    local rand = math.random(1, #openSpawners)
                    local pickedSpawner = openSpawners[rand]

                        -- create a new mobData object
                    local mobData = require(script.Parent.NewMob).Create(thisModule)

                    -- set the spawner this mob is owned by
                    mobData.Spawner = pickedSpawner

                    -- assign serialNumber to mob model and also add the mobData table to MobService.SpawnedMobs table
                    utils.NewValueObject("MobId", serialNumber, mobData.Model)
                    mobData.MobId = serialNumber
                    serialNumber += 1

                    -- Set spawn CFrame
                    local offsetX
                    local offsetZ
                    if thisModule.RandomPlacement then
                        offsetX = math.random(-mobData.Spawner.Size.X / 2, mobData.Spawner.Size.X / 2)
                        offsetX = math.random(-mobData.Spawner.Size.Z / 2, mobData.Spawner.Size.Z / 2)
                    else
                        offsetX = 0
                        offsetX = 0
                    end
                    mobData.SpawnCFrame = pickedSpawner.CFrame * CFrame.new(offsetX, thisModule.Spawn_Y_Offset, offsetZ)

                    -- run the pre-spawn setup
                    thisModule.Pre_Spawn(mobData)

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

                    Knit.Services.MobService.SpawnedMobs[mobData.MobId] = mobData

                    -- run the post-spawn setup
                    thisModule.Post_Spawn(mobData)

                    -- setup functions
                    thisModule.Setup_Animations(mobData)
                    thisModule.Setup_Attack(mobData)
                    thisModule.Setup_Death(mobData)
                    thisModule.Setup_Drop(mobData)

                end
            end
        end

        wait(spawnLoopCycleTime)
    end

end

return SpawnLoop