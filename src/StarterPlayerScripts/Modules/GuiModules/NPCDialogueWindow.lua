-- NPCDialogue
-- PDab
-- 2/11/2021

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local GuiService = Knit.GetService("GuiService")
local utils = require(Knit.Shared.Utils)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)

local NPCDialogue = {}

NPCDialogue.Frame = mainGui.Windows:FindFirstChild("NPCDialogue", true)
NPCDialogue.Close_Button = NPCDialogue.Frame:FindFirstChild("Close_Button", true)
NPCDialogue.Button_Choice1 = NPCDialogue.Frame:FindFirstChild("Button_Choice1", true)
NPCDialogue.Button_Choice2 = NPCDialogue.Frame:FindFirstChild("Button_Choice2", true)
NPCDialogue.Button_Choice3 = NPCDialogue.Frame:FindFirstChild("Button_Choice3", true)
NPCDialogue.Frame_Icons = NPCDialogue.Frame:FindFirstChild("Frame_Icons", true)
NPCDialogue.Text_Title = NPCDialogue.Frame:FindFirstChild("Text_Title", true)
NPCDialogue.Text_Body = NPCDialogue.Frame:FindFirstChild("Text_Body", true)

NPCDialogue.AllProximityPrompts = {} -- a table to held them all
NPCDialogue.DialogueModules = {}

local currentDialogueDef = {}
local currentStageName
local defaultChoiceButtonSize = UDim2.new(0.3, 0, 0.9, 0)


--// Setup
function NPCDialogue.Setup()

    -- turn it off on setup
    NPCDialogue.Frame.Visible = false

    -- Close Button
    NPCDialogue.Close_Button.MouseButton1Down:Connect(function()
        NPCDialogue.Close()
    end)

    -- dialogue choice1 button
    NPCDialogue.Button_Choice1.MouseButton1Down:Connect(function()
        NPCDialogue.ProcessDialogueChoice("Choice_1")
    end)

    -- dialogue choice2 button
    NPCDialogue.Button_Choice2.MouseButton1Down:Connect(function()
        NPCDialogue.ProcessDialogueChoice("Choice_2")
    end)

    -- dialogue choice3 button
    NPCDialogue.Button_Choice3.MouseButton1Down:Connect(function()
        NPCDialogue.ProcessDialogueChoice("Choice_3")
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
        print("No NPC Dialgue Module Found: ", idObject.Value )
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

    -- render the icon
    for _, icon in pairs(NPCDialogue.Frame_Icons:GetChildren()) do
        if icon:IsA("Frame") then
            if icon.Name == stageDef.IconName then
                icon.Visible = true
            else
                icon.Visible = false
            end
        end
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
        if stageDef.Choice_1.CustomSize then
            NPCDialogue.Button_Choice1.Size = stageDef.Choice_1.CustomSize
        else
            NPCDialogue.Button_Choice1.Size = defaultChoiceButtonSize
        end
    else
        NPCDialogue.Button_Choice1.Visible = false
        NPCDialogue.Button_Choice1.Active = false
    end

    if stageDef.Choice_2.Display then
        NPCDialogue.Button_Choice2.Visible = true
        NPCDialogue.Button_Choice2.Active = true
        NPCDialogue.Button_Choice2.Text = stageDef.Choice_2.Text
        if stageDef.Choice_2.CustomSize then
            NPCDialogue.Button_Choice2.Size = stageDef.Choice_2.CustomSize
        else
            NPCDialogue.Button_Choice2.Size = defaultChoiceButtonSize
        end
    else
        NPCDialogue.Button_Choice2.Visible = false
        NPCDialogue.Button_Choice2.Active = false
    end

    if stageDef.Choice_3.Display then
        NPCDialogue.Button_Choice3.Visible = true
        NPCDialogue.Button_Choice3.Active = true
        NPCDialogue.Button_Choice3.Text = stageDef.Choice_3.Text
        if stageDef.Choice_3.CustomSize then
            NPCDialogue.Button_Choice3.Size = stageDef.Choice_3.CustomSize
        else
            NPCDialogue.Button_Choice3.Size = defaultChoiceButtonSize
        end
    else
        NPCDialogue.Button_Choice3.Visible = false
        NPCDialogue.Button_Choice3.Active = false
    end
end

--// ProcessDialogueChoice
function NPCDialogue.ProcessDialogueChoice(choiceName)

    local stageDef = currentDialogueDef.Stage[currentStageName]
    
    if stageDef[choiceName].Action.Type == "ChangeStage" then
        currentStageName = stageDef[choiceName].Action.Stage
        NPCDialogue.RenderDialogueWindow()

    end

    if stageDef[choiceName].Action.Type == "Close" then
        NPCDialogue.Close()
    end

end


return NPCDialogue