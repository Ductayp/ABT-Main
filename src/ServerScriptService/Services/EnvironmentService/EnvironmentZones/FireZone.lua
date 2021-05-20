-- FireZone

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)


local lastUpdate = os.clock()
local tickLength = 1

local playerToggles = {}

local FireZone = {}

function FireZone.Tick()

    if os.clock() < lastUpdate + tickLength then return end

    --print("FIRE TICK")

    for userId, toggle in pairs(playerToggles) do

        if toggle == true then

            local player = utils.GetPlayerByUserId(userId)
            if player and player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid:TakeDamage(5)
                end
            end
        end

    end
    
    lastUpdate = os.clock()

end

function FireZone.EnterZone(player)

    --print("FIRE ZONE - ZoneEnter", player) 

    playerToggles[player.UserId] = true

    if player and player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:TakeDamage(5)
        end
    end

    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local oldFire = hrp:FindFirstChild("Environment_Fire", true)
    if oldFire then oldFire:Destroy() end

    local oldSmoke = hrp:FindFirstChild("Environment_Smoke", true)
    if oldSmoke then oldSmoke:Destroy() end

    local newFire = ReplicatedStorage.EffectParts.EnvironmentService.Fire.Environment_Fire:Clone()
    newFire.Parent = hrp

    local newSmoke = ReplicatedStorage.EffectParts.EnvironmentService.Fire.Environment_Smoke:Clone()
    newSmoke.Parent = hrp

end

function FireZone.LeaveZone(player)

    --print("FIRE ZONE - ZoneLeave", player)

    playerToggles[player.UserId] = false

    if player and player.Character then
        spawn(function()

            for count = 1, 4 do
                wait(1)
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid:TakeDamage(5)
                end
                --print(count)
            end

            local oldFire = player.Character:FindFirstChild("Environment_Fire", true)
            print(oldFire)
            if oldFire then
                oldFire.Enabled = false
                Debris:AddItem(oldFire, 10)
            end

            local oldSmoke = player.Character:FindFirstChild("Environment_Smoke", true)
            print(oldSmoke)
            if oldSmoke then
                oldSmoke.Enabled = false
                Debris:AddItem(oldSmoke, 10)
            end

        end)

    end

end

function FireZone.PlayerJoin(player)

    -- print("FIRE ZONE - PlayerJoin", player)

    playerToggles[player.UserId] = false

end

function FireZone.PlayerLeave(player)

    --print("FIRE ZONE - PlayerLeave", player)

    playerToggles[player.UserId] = nil

end


return FireZone