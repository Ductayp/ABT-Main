-- NPCDialogue
-- PDab
-- 2/11/2021

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local GuiService = Knit.GetService("GuiService")
local InventoryService = Knit.GetService("InventoryService")
local DungeonService = Knit.GetService("DungeonService")
local utils = require(Knit.Shared.Utils)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)

local NPCDialogue = {}

NPCDialogue.Frame = mainGui.Windows:FindFirstChild("NPCDialogue", true)
NPCDialogue.Button_Close = NPCDialogue.Frame:FindFirstChild("Button_Close", true)
NPCDialogue.Button_Choice1 = NPCDialogue.Frame:FindFirstChild("Button_Choice1", true)
NPCDialogue.Button_Choice2 = NPCDialogue.Frame:FindFirstChild("Button_Choice2", true)
NPCDialogue.Button_Choice3 = NPCDialogue.Frame:FindFirstChild("Button_Choice3", true)
NPCDialogue.Frame_Icon = NPCDialogue.Frame:FindFirstChild("Frame_Icon", true)
NPCDialogue.Text_Title = NPCDialogue.Frame:FindFirstChild("Text_Title", true)
NPCDialogue.Text_Body = NPCDialogue.Frame:FindFirstChild("Text_Body", true)

NPCDialogue.AllProximityPrompts = {} -- a table to held them all
NPCDialogue.DialogueModules = {} -- the current active dialogue module, gets set when you open a dialogue

local NPC_Icons = mainGui:FindFirstChild("NPC_Icons", true)

local currentDialogueDef = {}
local currentStageName
local disableChoiceButtons = false
local defaultButtonProperties = {
    Size = UDim2.new(0.3, 0, 0.9, 0),
    BackgroundColor3 = Color3.fromRGB(59,59,59),
    TextColor3 = Color3.fromRGB(255,255,255),
}


--// Setup
function NPCDialogue.Setup()

    -- turn it off on setup
    NPCDialogue.Frame.Visible = false

    -- Close Button
    NPCDialogue.Button_Close.MouseButton1Down:Connect(function()
        NPCDialogue.Close()
    end)

    -- dialogue choice1 button
    NPCDialogue.Button_Choice1.MouseButton1Down:Connect(function()
        if not disableChoiceButtons then
            NPCDialogue.ProcessDialogueChoice("Choice_1", NPCDialogue.Button_Choice1)
        end
    end)

    -- dialogue choice2 button
    NPCDialogue.Button_Choice2.MouseButton1Down:Connect(function()
        if not disableChoiceButtons then
            NPCDialogue.ProcessDialogueChoice("Choice_2", NPCDialogue.Button_Choice2)
        end
    end)

    -- dialogue choice3 button
    NPCDialogue.Button_Choice3.MouseButton1Down:Connect(function()
        if not disableChoiceButtons then
            NPCDialogue.ProcessDialogueChoice("Choice_3", NPCDialogue.Button_Choice3)
        end
    end)

    -- connect proximity prompts
    for _, instance in pairs(Workspace:GetDescendants()) do
        if instance:IsA("StringValue") and instance.Name == "NPCDialogue_Id" then
            local proximityPrompt = instance.Parent:FindFirstChild("ProximityPrompt")
            if proximityPrompt then
                table.insert(NPCDialogue.AllProximityPrompts, proximityPrompt) -- add it to a table for enable/disable and other function
                NPCDialogue.ConnectDialogue(instance, proximityPrompt)
            end
        end
    end

end

--// Open
function NPCDialogue.Open()
    
    Knit.Controllers.GuiController:CloseAllWindows()
    NPCDialogue.Frame.Visible = true

    -- disable all proximity prompts
    for _, proximityPrompt in pairs(NPCDialogue.AllProximityPrompts) do
        proximityPrompt.Enabled = false
    end

    -- toggle InDialogue and do actions there
    Knit.Controllers.GuiController:ToggleDialogue(true)
end

--// Close
function NPCDialogue.Close()

    NPCDialogue.Frame.Visible = false

    -- enable all the proximity prompts
    for _, proximityPrompt in pairs(NPCDialogue.AllProximityPrompts) do
        proximityPrompt.Enabled = true
    end

    -- toggle InDialogue
    Knit.Controllers.GuiController:ToggleDialogue(false)

end

--// ConnectDialogue
function NPCDialogue.ConnectDialogue(idObject, proximityPrompt)

    -- add to table the required module based on the idObject.Value
    local findModule = Knit.DialogueModules:FindFirstChild(idObject.Value)
    if findModule then
        NPCDialogue.DialogueModules[idObject.Value] = require(findModule)
    else
        return
    end

    -- ProximityPrompt.Triggered Event --
    proximityPrompt.Triggered:Connect(function(player)

        -- fire off Start
        NPCDialogue.DialogueModules[idObject.Value].Initialize()

        -- set the variables
        currentDialogueDef = NPCDialogue.DialogueModules[idObject.Value]
        currentStageName = "Start"

        -- all NPCs have a START stage
        NPCDialogue.RenderDialogueWindow()

        -- open the dialogue window
        NPCDialogue.Open()

    end)

end

--// RenderDialogueWindow
function NPCDialogue.RenderDialogueWindow()

    local stageDef = currentDialogueDef.Stage[currentStageName]
    if not stageDef then return end

    for _, object in pairs(NPCDialogue.Frame_Icon:GetChildren()) do
        if object:IsA("Frame") then
            object:Destroy()
        end
    end

    local newIcon
    local findIcon = NPC_Icons:FindFirstChild(stageDef.IconName)
    if findIcon then
        newIcon = findIcon:Clone()
        newIcon.Parent = NPCDialogue.Frame_Icon
        newIcon.Visible = true
    end

    -- fill the title
    NPCDialogue.Text_Title.Text = stageDef.Title

    -- fill the body
    NPCDialogue.Text_Body.Text = stageDef.Body

    -- setup the choice buttons
    if stageDef.Choice_1.Display then
        NPCDialogue.Button_Choice1.Visible = true
        NPCDialogue.Button_Choice1.Active = true
        NPCDialogue.Button_Choice1.Text = stageDef.Choice_1.Text

        for propName, propValue in pairs(defaultButtonProperties) do
            NPCDialogue.Button_Choice1[propName] = propValue
        end

        if stageDef.Choice_1.CustomProperties then
            for propName, propValue in pairs(stageDef.Choice_1.CustomProperties) do
                NPCDialogue.Button_Choice1[propName] = propValue
            end
        end
    else
        NPCDialogue.Button_Choice1.Visible = false
        NPCDialogue.Button_Choice1.Active = false
    end

    if stageDef.Choice_2.Display then
        NPCDialogue.Button_Choice2.Visible = true
        NPCDialogue.Button_Choice2.Active = true
        NPCDialogue.Button_Choice2.Text = stageDef.Choice_2.Text

        for propName, propValue in pairs(defaultButtonProperties) do
            NPCDialogue.Button_Choice2[propName] = propValue
        end

        if stageDef.Choice_2.CustomProperties then
            for propName, propValue in pairs(stageDef.Choice_2.CustomProperties) do
                NPCDialogue.Button_Choice2[propName] = propValue
            end
        end
        
    else
        NPCDialogue.Button_Choice2.Visible = false
        NPCDialogue.Button_Choice2.Active = false
    end

    if stageDef.Choice_3.Display then
        NPCDialogue.Button_Choice3.Visible = true
        NPCDialogue.Button_Choice3.Active = true
        NPCDialogue.Button_Choice3.Text = stageDef.Choice_3.Text

        for propName, propValue in pairs(defaultButtonProperties) do
            NPCDialogue.Button_Choice3[propName] = propValue
        end

        if stageDef.Choice_3.CustomProperties then
            for propName, propValue in pairs(stageDef.Choice_3.CustomProperties) do
                NPCDialogue.Button_Choice3[propName] = propValue
            end
        end
        
    else
        NPCDialogue.Button_Choice3.Visible = false
        NPCDialogue.Button_Choice3.Active = false
    end
end

--// ProcessDialogueChoice
function NPCDialogue.ProcessDialogueChoice(choiceName, button)

    local stageDef = currentDialogueDef.Stage[currentStageName]
    
    if stageDef[choiceName].Action.Type == "ChangeStage" then
        currentStageName = stageDef[choiceName].Action.Stage
        NPCDialogue.RenderDialogueWindow()

    end

    if stageDef[choiceName].Action.Type == "Close" then
        NPCDialogue.Close()
    end

    if stageDef[choiceName].Action.Type == "Shop" then

        local shopParams = {}
        shopParams.ModuleName = stageDef[choiceName].Action.ModuleName
        shopParams.TransactionKey = stageDef[choiceName].Action.TransactionKey

        local shopSuccess = InventoryService:NPCTransaction(shopParams)

        local originalText = button.Text
        local originalTextColor = button.TextColor3
        if shopSuccess then
            spawn(function()
                button.Text = "SUCCESS"
                button.TextColor3 = Color3.fromRGB(0, 255, 0)
                disableChoiceButtons = true
                wait(2)
                button.Text = originalText
                button.TextColor3 = originalTextColor
                disableChoiceButtons = false
            end)
        else
            spawn(function()
                button.Text = "FAILURE"
                button.TextColor3 = Color3.fromRGB(255, 0, 0)
                disableChoiceButtons = true
                wait(2)
                button.Text = originalText
                button.TextColor3 = originalTextColor
                disableChoiceButtons = false
            end)
        end

    end

    if stageDef[choiceName].Action.Type == "DungeonTravel" then
      --[[  
        local originalText = button.Text
        local originalTextColor = button.TextColor3
        local originalBackgroundColor = button.BackgroundColor3

        button.Text = "CHECKING..."

        local travelParams = {}
        travelParams.ModuleName = stageDef[choiceName].Action.ModuleName
        travelParams.TransactionKey = stageDef[choiceName].Action.TransactionKey
        local travelSuccess = DungeonService:BuyAccess(travelParams)

        if travelSuccess then
            button.Text = "SUCCESS"
            button.TextColor3 = Color3.fromRGB(0, 255, 0)
            button.BackgroundColor3 = Color3.fromRGB(59, 59, 59)
            Knit.Controllers.GuiController:ToggleDialogue(false)
            wait(1)
            disableChoiceButtons = true
            NPCDialogue.Frame.Visible = false
            button.Text = originalText
            button.TextColor3 = originalTextColor
            button.BackgroundColor3 = originalBackgroundColor
            disableChoiceButtons = false
        else
            button.Text = "NOT ENOUGH"
            button.TextColor3 = Color3.fromRGB(255, 0, 0)
            button.BackgroundColor3 = Color3.fromRGB(59, 59, 59)
            disableChoiceButtons = true
            wait(2)
            button.Text = originalText
            button.TextColor3 = originalTextColor
            button.BackgroundColor3 = originalBackgroundColor
            disableChoiceButtons = false
        end

        NPCDialogue.Close()
]]--
    end

    if stageDef[choiceName].Action.Type == "LeaveDungeon" then
--[[
        local originalText = button.Text
        local originalTextColor = button.TextColor3
        local originalBackgroundColor = button.BackgroundColor3

        button.Text = "SUCCESS"
        button.BackgroundColor3 = Color3.fromRGB(59, 59, 59)
        button.TextColor3 = Color3.fromRGB(0, 255, 0)
        Knit.Controllers.GuiController:ToggleDialogue(false)
        wait(1)
        disableChoiceButtons = true
        NPCDialogue.Frame.Visible = false
        button.Text = originalText
        button.TextColor3 = originalTextColor
        button.BackgroundColor3 = originalBackgroundColor
        disableChoiceButtons = false

        DungeonService:LeaveDungeon(Players.LocalPlayer)
        NPCDialogue.Close()

        ]]--
    end

end


return NPCDialogue