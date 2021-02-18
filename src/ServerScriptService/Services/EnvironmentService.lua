-- EnvironmentService
-- PDab
-- 2/12/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local EnvironmentService = Knit.CreateService { Name = "EnvironmentService", Client = {}}

-- modules
local utils = require(Knit.Shared.Utils)

-- variables
EnvironmentService.CurrentCycle = "Day"
EnvironmentService.CycleTime = 600 -- 600 = 10 minutes in seconds
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

--// TweenClockTime
function EnvironmentService:TweenClockTime(time)

    local timeTween = TweenService:Create(Lighting, TweenInfo.new(EnvironmentService.TransitionTime),{ClockTime = time})
    timeTween:Play()
end

--// DayNightCycle
function EnvironmentService:DayNightCycle()

    -- start the loop
    spawn(function()
        while true do
            wait(EnvironmentService.CycleTime)
            if EnvironmentService.CurrentCycle == "Day" then
                EnvironmentService.CurrentCycle = "Night"
                self:TweenClockTime(EnvironmentService.NightTime)
                self:ManageLights("Night")
            else
                EnvironmentService.CurrentCycle = "Day"
                self:TweenClockTime(EnvironmentService.DayTime)
                self:ManageLights("Day")
            end
        end
    end)
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

--// PlayerAdded
function EnvironmentService:PlayerAdded(player)

end

--// PlayerRemoved
function EnvironmentService:PlayerRemoved(player)

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

    self:DayNightCycle()
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