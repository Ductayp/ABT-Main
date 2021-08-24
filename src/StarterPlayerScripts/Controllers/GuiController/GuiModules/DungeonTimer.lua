-- DungeonTimer

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local GuiService = Knit.GetService("GuiService")
local DungeonService = Knit.GetService("DungeonService")
local utils = require(Knit.Shared.Utils)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)


local DungeonTimer = {}

DungeonTimer.Frame = mainGui.BottomBar:FindFirstChild("DungeonTimer", true)
DungeonTimer.Text_DungeonName = DungeonTimer.Frame:FindFirstChild("Text_DungeonName", true)
DungeonTimer.Text_Time = DungeonTimer.Frame:FindFirstChild("Text_Time", true)

local dungeonTimes = {}
local timerOpen = false
local currentDungeonId

--// Setup
function DungeonTimer.Setup()

    DungeonTimer.Frame.Visible = false

    local lastUpdate = os.time()
    RunService.Heartbeat:Connect(function(step)
        if timerOpen then
            if lastUpdate < os.time() then
                lastUpdate = os.time()
                DungeonTimer.RenderTime()
            end
        end
    end)

end

--// RenderTime
function DungeonTimer.RenderTime()


    if not dungeonTimes[currentDungeonId] then 
        print("NOPE")
        return
    end

    local thisTime = dungeonTimes[currentDungeonId]

    if  thisTime > os.time() then

        DungeonTimer.Text_Time.Text = tostring(utils.ConvertToHMS(thisTime - os.time()))

    else

        DungeonTimer.Text_Time.Text = tostring(utils.ConvertToHMS(0))

    end

    local difference = thisTime - os.time()
    if difference < 60 then
        DungeonTimer.Text_Time.TextColor3 = Color3.fromRGB(255, 0, 0)
        spawn(function()
            wait(.5)
            DungeonTimer.Text_Time.TextColor3 = Color3.fromRGB(231, 231, 231)
        end)
    else
        DungeonTimer.Text_Time.TextColor3 = Color3.fromRGB(231, 231, 231)
    end
        
end

--// UpdateDungeonTimes
function DungeonTimer.UpdateDungeonTimes(data)

    dungeonTimes = data

    if timerOpen then
        DungeonTimer.RenderTime()
    end

    local blinkRate = .25
    spawn(function()

        for count = 1, 4 do
            DungeonTimer.Text_Time.TextColor3 = Color3.fromRGB(0, 255, 0)
            wait(blinkRate)
            DungeonTimer.Text_Time.TextColor3 = Color3.fromRGB(231, 231, 231)
            wait(blinkRate)
        end

    end)

end

--// RenderPanel
function DungeonTimer.RenderTimerWindow()

    local findModule = Knit.DungeonModules[currentDungeonId]
    if not findModule then return end

    local dungeonModule = require(findModule)

    DungeonTimer.Text_DungeonName.Text = dungeonModule.DungeonName

end

--// ToggleTimer
function DungeonTimer.ToggleTimer(boolean, dungeonId)

    wait(1)

    if boolean then
        currentDungeonId = dungeonId
        DungeonTimer.RenderTimerWindow()
        DungeonTimer.Open()
    else
        DungeonTimer.Close()
    end
end

--// Open
function DungeonTimer.Open()

    DungeonTimer.Frame.Visible = true

    timerOpen = true

end

--// Close
function DungeonTimer.Close()

    DungeonTimer.Frame.Visible = false

    timerOpen = false

end


return DungeonTimer