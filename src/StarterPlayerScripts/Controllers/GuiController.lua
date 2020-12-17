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


--// PowerButtonSetup
function GuiController:PowerButtonSetup()

    local mainGui = Players.LocalPlayer.PlayerGui:WaitForChild("MainGui")
    local powerButtonFrame = mainGui:FindFirstChild("PowerButtons",true)

    for _,button in pairs(powerButtonFrame:GetChildren()) do
        button.Activated:Connect(function()
        
            Knit.Controllers.InputController:SendToPowersService({InputId = button.Name, KeyState = "InputBegan"})
        
        end)
    end

end


function GuiController:KnitStart()
    self:PowerButtonSetup()
end

function GuiController:KnitInit()

end


return GuiController