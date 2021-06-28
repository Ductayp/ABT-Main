-- EnvironmentService
-- PDab
-- 2/12/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local EnvironmentService = Knit.CreateService { Name = "EnvironmentService", Client = {}}
local BlockInput = require(Knit.PowerUtils.BlockInput)

-- modules
local utils = require(Knit.Shared.Utils)

-- Lighting variables
EnvironmentService.CurrentCycle = "Day"
EnvironmentService.CurrentCycleSetTime = os.time() -- this gets updated whenever the cycyle is changed
EnvironmentService.DayCycleTime = 600
EnvironmentService.TransitionTime = 20
EnvironmentService.DayTime = 14.6
EnvironmentService.NightTime = 19.6
local managedLights = {}
local managedWindows = {}
local managedNeonParts = {}
local managedFireflys = {}
local manageWindow_On_Color = Color3.fromRGB(156, 144, 92)
local manageWindow_On_Material = "Neon"
local manageWindow_Off_Color = Color3.fromRGB(48, 48, 49)
local manageWindow_Off_Material = "Glass"

-- Swim variables
EnvironmentService.PlayerSwimToggle = {}
local SWIM_CHECK_TIME = .5
local SWIM_DAMAGE = 5

-- Load all zone:
local EnvironmentZones = {}
for _, module in ipairs(script.EnvironmentZones:GetDescendants()) do
    if (module:IsA("ModuleScript")) then
        EnvironmentZones[module.Name] = require(module)
    end
end

function EnvironmentService:EnvironmentClock()

    local last_DayCycleTime = os.clock() + EnvironmentService.DayCycleTime
    local last_SwimCheckTime = os.clock() + SWIM_CHECK_TIME

    spawn(function()
        while game:GetService("RunService").Heartbeat:Wait() do

            -- swim checks
            if os.clock() > last_SwimCheckTime then
                last_SwimCheckTime = os.clock() + SWIM_CHECK_TIME
                self:SwimCheck()
            end

            -- day/night cycle
            if os.clock() > last_DayCycleTime then
                last_DayCycleTime = os.clock() + EnvironmentService.DayCycleTime
                self:DayNightCycle()
            end

            -- environment modules
            for moduleName, requiredModule in pairs(EnvironmentZones) do
                requiredModule.Tick()
            end

        end
    end)

end

function EnvironmentService:TogglePlayerInZone(player, zoneName, toggle)

    if not player then return end

    local zoneModule = require(script.EnvironmentZones[zoneName])
    if not zoneModule then return end

    if toggle == true then
        zoneModule.EnterZone(player)
    else
        zoneModule.LeaveZone(player)
    end
    
end


--// TweenClockTime
function EnvironmentService:TweenClockTime(time)

    local timeTween = TweenService:Create(Lighting, TweenInfo.new(EnvironmentService.TransitionTime),{ClockTime = time})
    timeTween:Play()
end

--// DayNightCycle
function EnvironmentService:DayNightCycle()

    if EnvironmentService.CurrentCycle == "Day" then

        spawn(function()
            wait(EnvironmentService.TransitionTime / 2)
            EnvironmentService.CurrentCycle = "Night"
        end)
        
        self:TweenClockTime(EnvironmentService.NightTime)
        self:ManageLights("Night")
    else
        
        spawn(function()
            wait(EnvironmentService.TransitionTime / 2)
            EnvironmentService.CurrentCycle = "Day"
        end)

        self:TweenClockTime(EnvironmentService.DayTime)
        self:ManageLights("Day")
    end

    EnvironmentService.CurrentCycleSetTime = os.time()

end

function EnvironmentService:ManageLights(cycleName)

    if cycleName == "Day" then
        spawn(function()
            wait(EnvironmentService.TransitionTime - 5)

            for _,v in pairs(managedLights) do
                v.Enabled = false
            end

            for _,v in pairs(managedWindows) do
                v.Color = manageWindow_Off_Color
                v.Material = manageWindow_Off_Material
            end

            for _,v in pairs(managedNeonParts) do
                v.Transparency = 1
            end

            for _,v in pairs(managedFireflys) do
                --print(v:GetChildren())
                v.ParticleEmitter.Enabled = false
                v.PointLight.Enabled = false
            end
        end)
    end

    if cycleName == "Night" then
        spawn(function()
            wait(EnvironmentService.TransitionTime - 5)

            for _,v in pairs(managedLights) do
                v.Enabled = true
            end

            for _,v in pairs(managedWindows) do
                v.Color = manageWindow_On_Color
                v.Material = manageWindow_On_Material
            end

            for _,v in pairs(managedNeonParts) do
                v.Transparency = 0
            end

            for _,v in pairs(managedFireflys) do
                v.ParticleEmitter.Enabled = true
                v.PointLight.Enabled = true
            end
        end)
    end
end

--// swim check
function EnvironmentService:SwimToggle(player, boolean)

    if not player then return end
    EnvironmentService.PlayerSwimToggle[player.UserId] = boolean

end


function EnvironmentService:SwimCheck()

    for UserId, toggle in pairs(EnvironmentService.PlayerSwimToggle) do

        if toggle == true then
            local player = utils.GetPlayerByUserId(UserId)
            if player then
                Knit.Services.PowersService:ForceRemoveStand(player)
                BlockInput.AddBlock(UserId, "Swimming", 2)
                player.Character.Humanoid:TakeDamage(SWIM_DAMAGE)
            end
        end
    end


end


--// PlayerAdded
function EnvironmentService:PlayerAdded(player)

    EnvironmentService.PlayerSwimToggle[player.UserId] = false

    for moduleName, requiredModule in pairs(EnvironmentZones) do
        requiredModule.PlayerJoin(player)
    end

end

--// PlayerRemoved
function EnvironmentService:PlayerRemoved(player)

    EnvironmentService.PlayerSwimToggle[player.UserId] = nil

    for moduleName, requiredModule in pairs(EnvironmentZones) do
        requiredModule.PlayerLeave(player)
    end

end

--// KnitStart
function EnvironmentService:KnitStart()
    
    -- build manage light tables
    for _,v in pairs(Workspace:GetDescendants()) do

        -- add lgihts to table
        if v:IsA("Folder") and v.Name == "MANAGED_LIGHTS" then
            for _, light in pairs(v:GetDescendants()) do
                if light:IsA("SpotLight") or light:IsA("PointLight") or light:IsA("SurfaceLight")then
                    table.insert(managedLights, light)
                end
            end
        end

        -- add windows to table
        if v.Name == "MANAGED_WINDOW" then
            table.insert(managedWindows, v)
        end

        -- add neon parts ot table
        if v.Name == "NEON_LIGHT" then
            table.insert(managedNeonParts, v)
        end

        if v.Name == "Fireflies" then
            table.insert(managedFireflys, v)
        end
    end

    self:EnvironmentClock()

    --self:DayNightCycle()
    self:ManageLights(EnvironmentService.CurrentCycle)
end

--// KnitInit
function EnvironmentService:KnitInit()

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
        self:PlayerRemoved(player)
    end)


end


return EnvironmentService