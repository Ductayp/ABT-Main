-- InputController
-- PDab
-- 1/1/2020

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- setup Knit
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local InputController = Knit.CreateController { Name = "InputController" }

function InputController:KeyboardSetup()

        UserInputService.InputBegan:Connect(function(input, isTyping)
            if isTyping then
                return
            elseif input.KeyCode == Enum.KeyCode.Q then
                Knit.Controllers.PowersController:InitializePower({InputId = "Q", KeyState = "InputBegan"})
            elseif input.KeyCode == Enum.KeyCode.E then
                Knit.Controllers.PowersController:InitializePower({InputId = "E", KeyState = "InputBegan"})
            elseif input.KeyCode == Enum.KeyCode.R then
                Knit.Controllers.PowersController:InitializePower({InputId = "R", KeyState = "InputBegan"})
            elseif input.KeyCode == Enum.KeyCode.T then
                Knit.Controllers.PowersController:InitializePower({InputId = "T", KeyState = "InputBegan"})
            elseif input.KeyCode == Enum.KeyCode.F then
                Knit.Controllers.PowersController:InitializePower({InputId = "F", KeyState = "InputBegan"})
            elseif input.KeyCode == Enum.KeyCode.Z then
                Knit.Controllers.PowersController:InitializePower({InputId = "Z", KeyState = "InputBegan"})
            elseif input.KeyCode == Enum.KeyCode.X then
                Knit.Controllers.PowersController:InitializePower({InputId = "X", KeyState = "InputBegan"})
            elseif input.KeyCode == Enum.KeyCode.C then
                Knit.Controllers.PowersController:InitializePower({InputId = "C", KeyState = "InputBegan"})
            end
        end)
    
        UserInputService.InputEnded:Connect(function(input, isTyping)
            if isTyping then
                return
            elseif input.KeyCode == Enum.KeyCode.Q then
                Knit.Controllers.PowersController:InitializePower({InputId = "Q", KeyState = "InputEnded"})
            elseif input.KeyCode == Enum.KeyCode.E then
                Knit.Controllers.PowersController:InitializePower({InputId = "E", KeyState = "InputEnded"})
            elseif input.KeyCode == Enum.KeyCode.R then
                Knit.Controllers.PowersController:InitializePower({InputId = "R", KeyState = "InputEnded"})
            elseif input.KeyCode == Enum.KeyCode.T then
                Knit.Controllers.PowersController:InitializePower({InputId = "T", KeyState = "InputEnded"})
            elseif input.KeyCode == Enum.KeyCode.F then
                Knit.Controllers.PowersController:InitializePower({InputId = "F", KeyState = "InputEnded"})
            elseif input.KeyCode == Enum.KeyCode.Z then
                Knit.Controllers.PowersController:InitializePower({InputId = "Z", KeyState = "InputEnded"})
            elseif input.KeyCode == Enum.KeyCode.X then
                Knit.Controllers.PowersController:InitializePower({InputId = "X", KeyState = "InputEnded"})
            elseif input.KeyCode == Enum.KeyCode.C then
                Knit.Controllers.PowersController:InitializePower({InputId = "Q", KeyState = "InputEnded"})
            end
        end)
end

function InputController:KnitStart()
    InputController.KeyboardSetup()
end

function InputController:KnitInit()

end

return InputController