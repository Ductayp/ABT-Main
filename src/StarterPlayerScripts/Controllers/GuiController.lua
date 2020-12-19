-- GUI controller
-- PDab
-- 12 / 15/ 2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")


-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local GuiController = Knit.CreateController { Name = "GuiController" }

-- Knit modules
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)

--// ActivateWindow
function GuiController:ActivateWindow(windowName,panelName)

    local mainGui = Players.LocalPlayer.PlayerGui:WaitForChild("MainGui")
    local window = mainGui.Windows:FindFirstChild(windowName, true)
    print("window",window)
    local panelFrame = window:FindFirstChild("Panels", true)
    local panel = panelFrame:FindFirstChild(panelName, true)

    if window.Enabled then
        for _,thisWindow in pairs(mainGui.Windows:GetChildren()) do
            thisWindow.Enabled = false
        end
    else
        for _,thisWindow in pairs(mainGui.Windows:GetChildren()) do
            thisWindow.Enabled = false
        end
        window.Enabled = true
    end
end


--// PowerButtonSetup
function GuiController:PowerButtonSetup()

    local mainGui = Players.LocalPlayer.PlayerGui:WaitForChild("MainGui")
    local powerButtonFrame = mainGui:FindFirstChild("PowerButtons",true)

    for _,button in pairs(powerButtonFrame:GetDescendants()) do
        if button:IsA("TextButton") then
            button.Activated:Connect(function()
                Knit.Controllers.InputController:SendToPowersService({InputId = button.Name, KeyState = "InputBegan"})
            end)
        end
    end
end

--// LeftGuiSetup()
function GuiController:LeftGuiSetup()

    -- define some buttons
    local mainGui = Players.LocalPlayer.PlayerGui:WaitForChild("MainGui")
    local mainMenuButton = mainGui:FindFirstChild("MainMenu_Button", true)
    local arrowButton = mainGui:FindFirstChild("Arrow_Button", true)
    local storageButton = mainGui:FindFirstChild("Storage_Button", true)

    print(mainMenuButton.Parent)

    -- connect the clickies
    mainMenuButton.Activated:Connect(function()
        self:ActivateWindow("Main_Window","Items")
    end)

    arrowButton.Activated:Connect(function()
        self:ActivateWindow("Main_Window","Arrows")
    end)

    storageButton.Activated:Connect(function()
        self:ActivateWindow("Main_Window","Storage")
    end)
end

--// WindowGuiSetup
function GuiController:WindowGuiSetup()

    local mainGui = Players.LocalPlayer.PlayerGui:WaitForChild("MainGui")
    local closeButton = mainGui.Windows.Main_Window:FindFirstChild("Close", true)
    
    closeButton.Activated:Connect(function()
        print("Boop")
        mainGui.Windows.Main_Window.Enabled = false
    end)

end


function GuiController:KnitStart()
    self:PowerButtonSetup()
    self:LeftGuiSetup()
    self:WindowGuiSetup()
end

function GuiController:KnitInit()

end


return GuiController