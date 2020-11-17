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

InputController.KeyMap = {
    Q = "Ability_1",
    E = "Ability_2",
    R = "Ability_3",
    T = "Ability_4",
    F = "Ability_5",
    Z = "Ability_6",
    X = "Ability_7",
    C = "Ability_8"
}


function InputController:KeyboardSetup()

        UserInputService.InputBegan:Connect(function(input, isTyping)
            if isTyping then
                return
            elseif input.KeyCode == Enum.KeyCode.Q then
                Knit.Controllers.PowersController:InitializePower({Key = "Q", KeyState = "InputBegan"})
            elseif input.KeyCode == Enum.KeyCode.E then
                Knit.Controllers.PowersController:InitializePower({AbilityID = InputController.KeyMap.E, KeyState = "InputBegan"})
            elseif input.KeyCode == Enum.KeyCode.R then
                Knit.Controllers.PowersController:InitializePower({AbilityID = InputController.KeyMap.R, KeyState = "InputBegan"})
            elseif input.KeyCode == Enum.KeyCode.T then
                Knit.Controllers.PowersController:InitializePower({AbilityID = InputController.KeyMap.T, KeyState = "InputBegan"})
            elseif input.KeyCode == Enum.KeyCode.F then
                Knit.Controllers.PowersController:InitializePower({AbilityID = InputController.KeyMap.F, KeyState = "InputBegan"})
            elseif input.KeyCode == Enum.KeyCode.Z then
                Knit.Controllers.PowersController:InitializePower({AbilityID = InputController.KeyMap.Z, KeyState = "InputBegan"})
            elseif input.KeyCode == Enum.KeyCode.X then
                Knit.Controllers.PowersController:InitializePower({AbilityID = InputController.KeyMap.X, KeyState = "InputBegan"})
            elseif input.KeyCode == Enum.KeyCode.C then
                Knit.Controllers.PowersController:InitializePower({AbilityID = InputController.KeyMap.C, KeyState = "InputBegan"})
            end
        end)
    
        UserInputService.InputEnded:Connect(function(input, isTyping)
            if isTyping then
                return
            elseif input.KeyCode == Enum.KeyCode.Q then
                Knit.Controllers.PowersController:InitializePower({AbilityID = InputController.KeyMap.Q, KeyState = "InputEnded"})
            elseif input.KeyCode == Enum.KeyCode.E then
                Knit.Controllers.PowersController:InitializePower({AbilityID = InputController.KeyMap.E, KeyState = "InputEnded"})
            elseif input.KeyCode == Enum.KeyCode.R then
                Knit.Controllers.PowersController:InitializePower({AbilityID = InputController.KeyMap.R, KeyState = "InputEnded"})
            elseif input.KeyCode == Enum.KeyCode.T then
                Knit.Controllers.PowersController:InitializePower({AbilityID = InputController.KeyMap.T, KeyState = "InputEnded"})
            elseif input.KeyCode == Enum.KeyCode.F then
                Knit.Controllers.PowersController:InitializePower({AbilityID = InputController.KeyMap.F, KeyState = "InputEnded"})
            elseif input.KeyCode == Enum.KeyCode.Z then
                Knit.Controllers.PowersController:InitializePower({AbilityID = InputController.KeyMap.Z, KeyState = "InputEnded"})
            elseif input.KeyCode == Enum.KeyCode.X then
                Knit.Controllers.PowersController:InitializePower({AbilityID = InputController.KeyMap.X, KeyState = "InputEnded"})
            elseif input.KeyCode == Enum.KeyCode.C then
                Knit.Controllers.PowersController:InitializePower({AbilityID = InputController.KeyMap.C, KeyState = "InputEnded"})
            end
        end)
end

function InputController:KnitStart()
    InputController.KeyboardSetup()
end

function InputController:KnitInit()

end

return InputController