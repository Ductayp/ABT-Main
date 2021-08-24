-- NPCDungeon
-- PDab
-- 2/11/2021

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
local NPC_Icons = mainGui:FindFirstChild("NPC_Icons", true)

local NPCDungeon = {}

NPCDungeon.Frame = mainGui.Windows:FindFirstChild("NPCDungeon", true)

NPCDungeon.Button_Close = NPCDungeon.Frame:FindFirstChild("Button_Close", true)
NPCDungeon.Frame_Icon = NPCDungeon.Frame:FindFirstChild("Frame_Icon", true)
NPCDungeon.Text_Title = NPCDungeon.Frame:FindFirstChild("Text_Title", true)
NPCDungeon.Text_NPCText = NPCDungeon.Frame:FindFirstChild("Text_NPCText", true)
NPCDungeon.Text_DungeonName = NPCDungeon.Frame:FindFirstChild("Text_DungeonName", true)
NPCDungeon.Text_Timer = NPCDungeon.Frame:FindFirstChild("Text_Timer", true)
NPCDungeon.Text_DungeonKeys = NPCDungeon.Frame:FindFirstChild("Text_DungeonKeys", true)

NPCDungeon.Section_A_Header = NPCDungeon.Frame:FindFirstChild("Section_A_Header", true)
NPCDungeon.Section_A_Body = NPCDungeon.Frame:FindFirstChild("Section_A_Body", true)

NPCDungeon.Section_B_Header = NPCDungeon.Frame:FindFirstChild("Section_B_Header", true)
NPCDungeon.Section_B_Body = NPCDungeon.Frame:FindFirstChild("Section_B_Body", true)

NPCDungeon.Section_C_Header = NPCDungeon.Frame:FindFirstChild("Section_C_Header", true)
NPCDungeon.Section_C_Body = NPCDungeon.Frame:FindFirstChild("Section_C_Body", true)

NPCDungeon.Button_UseKey = NPCDungeon.Frame:FindFirstChild("Button_UseKey", true)
NPCDungeon.Button_Enter = NPCDungeon.Frame:FindFirstChild("Button_Enter", true)

local allProximityPrompts = {}
local currentDungeonDefs
local keysOwned = 0
local dungeonTimes = {}
local buttonsEnabled = true
local windowOpen = false
local travelContext -- holds either "Enter" or "Leave" for the button on the gui

--// Setup
function NPCDungeon.Setup()

    NPCDungeon.Frame.Visible = false

    GuiService:Request_GuiUpdate("ItemsWindow")
    GuiService:Request_GuiUpdate("DungeonTimes")

    -- Close Button
    NPCDungeon.Button_Close.MouseButton1Down:Connect(function()
        NPCDungeon.Close()
    end)

    -- connect proximity prompts
    for _, module in pairs(Knit.DungeonModules:GetChildren()) do

        local enterPrompt = require(module).EnterPrompt
        local leavePrompt = require(module).LeavePrompt

        table.insert(allProximityPrompts, proximityPrompt)

        enterPrompt.Triggered:Connect(function(player)

            travelContext = "ENTER"

            currentDungeonDefs = require(module)
            NPCDungeon.RenderWindow(module)
            NPCDungeon.Open()

            Knit.Controllers.GuiController:ToggleDialogue(true)
    
        end)

        leavePrompt.Triggered:Connect(function(player)

            travelContext = "LEAVE"

            currentDungeonDefs = require(module)
            NPCDungeon.RenderWindow(module)
            NPCDungeon.Open()

            Knit.Controllers.GuiController:ToggleDialogue(true)
    
        end)
    end

    NPCDungeon.Button_UseKey.MouseButton1Down:Connect(function()
        if buttonsEnabled then
            buttonsEnabled = false
            NPCDungeon.UseKey()
        end
    end)

    NPCDungeon.Button_Enter.MouseButton1Down:Connect(function()
        if buttonsEnabled then
            buttonsEnabled = false
            if travelContext == "ENTER" then
                NPCDungeon.RequestEnter()
            else
                NPCDungeon.RequestLeave()
            end
        end
    end)



    local lastUpdate = os.time()
    RunService.Heartbeat:Connect(function(step)
        if windowOpen then
            if lastUpdate < os.time() then
                lastUpdate = os.time()
                NPCDungeon.RenderTime()
            end
        end
    end)



end

function NPCDungeon.RenderTime()

    if not dungeonTimes then
        NPCDungeon.Text_Timer.Text = "TIME REMAINING - " .. tostring(utils.ConvertToHMS(0))
        return
    end

    if not dungeonTimes[currentDungeonDefs.DungeonId] then 
        NPCDungeon.Text_Timer.Text = "TIME REMAINING - " .. tostring(utils.ConvertToHMS(0))
        return
    end

    local thisTime = dungeonTimes[currentDungeonDefs.DungeonId]

    if  thisTime > os.time() then

        NPCDungeon.Text_Timer.Text = "TIME REMAINING - " .. tostring(utils.ConvertToHMS(thisTime - os.time()))

    else

        NPCDungeon.Text_Timer.Text = "TIME REMAINING - " .. tostring(utils.ConvertToHMS(0))

    end

end

function NPCDungeon.UpdateKeys(data)

    if not data.DungeonKey then
        keysOwned = 0
    else
        keysOwned = data.DungeonKey
    end

    NPCDungeon.RenderWindow()

end

function NPCDungeon.UpdateDungeonTimes(data)

    dungeonTimes = data

    print("NPCDungeon.UpdateDungeonTimes", dungeonTimes, os.time())

    if windowOpen then
        NPCDungeon.RenderTime()
    end

    local blinkRate = .25
    spawn(function()

        for count = 1, 4 do
            NPCDungeon.Text_Timer.TextColor3 = Color3.fromRGB(0, 255, 0)
            wait(blinkRate)
            NPCDungeon.Text_Timer.TextColor3 = Color3.fromRGB(231, 231, 231)
            wait(blinkRate)
        end

    end)

end

--// RenderWindow
function NPCDungeon.RenderWindow()

    if not currentDungeonDefs then return end

    for _, object in pairs(NPCDungeon.Frame_Icon:GetChildren()) do
        if object:IsA("Frame") then
            object:Destroy()
        end
    end

    local newIcon
    local findIcon = NPC_Icons:FindFirstChild(currentDungeonDefs.IconName, true)
    if findIcon then
        newIcon = findIcon:Clone()
        newIcon.Parent = NPCDungeon.Frame_Icon
        newIcon.Visible = true
    end

    -- fill the title
    NPCDungeon.Text_Title.Text = currentDungeonDefs.Title

    -- fill the NPC text
    NPCDungeon.Text_NPCText.Text = currentDungeonDefs.NPCText

    NPCDungeon.Text_DungeonName.Text = currentDungeonDefs.DungeonName
    NPCDungeon.Text_DungeonKeys.Text = "Dungeon Keys: " .. keysOwned

    NPCDungeon.Section_A_Header.Text = currentDungeonDefs.Section_A_Header
    NPCDungeon.Section_A_Body.Text = currentDungeonDefs.Section_A_Body
    
    NPCDungeon.Section_B_Header.Text = currentDungeonDefs.Section_B_Header
    NPCDungeon.Section_B_Body.Text = currentDungeonDefs.Section_B_Body
    
    NPCDungeon.Section_C_Header.Text = currentDungeonDefs.Section_C_Header
    NPCDungeon.Section_C_Body.Text = currentDungeonDefs.Section_C_Body

    NPCDungeon.Button_Enter.Text = travelContext

end

--// NPCDungeon.RequestEnter
function NPCDungeon.RequestEnter()

    local button = NPCDungeon.Button_Enter
    local originalTextColor = Color3.fromRGB(238, 238, 238) 
    local originalBackgroundColor = Color3.fromRGB(0, 137, 206) 

    local enterSuccess = DungeonService:RequestEnter(currentDungeonDefs.DungeonId)

    if enterSuccess then

        button.Text = "SUCCESS"
        button.TextColor3 = Color3.fromRGB(0, 255, 0)
        button.BackgroundColor3 = Color3.fromRGB(59, 59, 59)

        wait(1)

        Knit.Controllers.GuiController:ToggleDialogue(false)
        NPCDungeon.Close()
        button.Text = travelContext
        button.TextColor3 = originalTextColor
        button.BackgroundColor3 = originalBackgroundColor
        buttonsEnabled = true

    else

        button.Text = "NO TIME"
        button.TextColor3 = Color3.fromRGB(255, 0, 0)
        button.BackgroundColor3 = Color3.fromRGB(59, 59, 59)

        wait(2)

        button.Text = travelContext
        button.TextColor3 = originalTextColor
        button.BackgroundColor3 = originalBackgroundColor
        buttonsEnabled = true

    end

end

--// NPCDungeon.RequestLeave
function NPCDungeon.RequestLeave()

    local leaveSuccess = DungeonService:LeaveDungeon()
    wait(1)
    NPCDungeon.Close()

end

--// NPCDungeon.UseKey
function NPCDungeon.UseKey()

    local button = NPCDungeon.Button_UseKey
    local originalText = button.Text
    local originalTextColor = Color3.fromRGB(238, 238, 238) 
    local originalBackgroundColor = Color3.fromRGB(200, 0, 255) 

    local buySuccess = DungeonService:BuyTime(currentDungeonDefs.DungeonId)

    if buySuccess then
        button.Text = "SUCCESS"
        button.TextColor3 = Color3.fromRGB(0, 255, 0)
        button.BackgroundColor3 = Color3.fromRGB(59, 59, 59)
        wait(1)
        button.Text = originalText
        button.TextColor3 = originalTextColor
        button.BackgroundColor3 = originalBackgroundColor
        buttonsEnabled = true
    else
        button.Text = "NO KEYS"
        button.TextColor3 = Color3.fromRGB(255, 0, 0)
        button.BackgroundColor3 = Color3.fromRGB(59, 59, 59)
        wait(2)
        button.Text = originalText
        button.TextColor3 = originalTextColor
        button.BackgroundColor3 = originalBackgroundColor
        buttonsEnabled = true
    end

end


--// Open
function NPCDungeon.Open()
    
    Knit.Controllers.GuiController:CloseAllWindows()
    NPCDungeon.Frame.Visible = true

    windowOpen = true

    buttonsEnabled = true

    -- disable all proximity prompts
    for _, proximityPrompt in pairs(allProximityPrompts) do
        proximityPrompt.Enabled = false
    end

    -- toggle InDialogue and do actions there
    Knit.Controllers.GuiController:ToggleDialogue(true)
end

--// Close
function NPCDungeon.Close()

    NPCDungeon.Frame.Visible = false

    windowOpen = false

    buttonsEnabled = false

    -- enable all the proximity prompts
    for _, proximityPrompt in pairs(allProximityPrompts) do
        proximityPrompt.Enabled = true
    end

    -- toggle InDialogue
    Knit.Controllers.GuiController:ToggleDialogue(false)

end


return NPCDungeon