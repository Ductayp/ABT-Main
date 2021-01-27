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

-- Knit modules
local utils = require(Knit.Shared.Utils)

--// SendToPowersService
function InputController:SendToPowersService(params)

    Knit.Controllers.PowersController:InitializePower(params)

end

function InputController:MouseSetup()

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if not Knit.Controllers.GuiController.ButtonHover then
                InputController:SendToPowersService({InputId = "Mouse1", KeyState = "InputBegan"})
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if not Knit.Controllers.GuiController.ButtonHover then
                InputController:SendToPowersService({InputId = "Mouse1", KeyState = "InputEnded"})
            end
        end
    end)

end

function InputController:KeyboardSetup()

        UserInputService.InputBegan:Connect(function(input, isTyping)
            if isTyping then
                return
            elseif input.KeyCode == Enum.KeyCode.Q then
                InputController:SendToPowersService({InputId = "Q", KeyState = "InputBegan"})
            elseif input.KeyCode == Enum.KeyCode.E then
                InputController:SendToPowersService({InputId = "E", KeyState = "InputBegan"})
            elseif input.KeyCode == Enum.KeyCode.R then
                InputController:SendToPowersService({InputId = "R", KeyState = "InputBegan"})
            elseif input.KeyCode == Enum.KeyCode.T then
                InputController:SendToPowersService({InputId = "T", KeyState = "InputBegan"})
            elseif input.KeyCode == Enum.KeyCode.F then
                InputController:SendToPowersService({InputId = "F", KeyState = "InputBegan"})
            elseif input.KeyCode == Enum.KeyCode.Z then
                InputController:SendToPowersService({InputId = "Z", KeyState = "InputBegan"})
            elseif input.KeyCode == Enum.KeyCode.X then
                InputController:SendToPowersService({InputId = "X", KeyState = "InputBegan"})
            elseif input.KeyCode == Enum.KeyCode.C then
                InputController:SendToPowersService({InputId = "C", KeyState = "InputBegan"})
            end
        end)
    
        UserInputService.InputEnded:Connect(function(input, isTyping)
            if isTyping then
                return
            elseif input.KeyCode == Enum.KeyCode.Q then
                InputController:SendToPowersService({InputId = "Q", KeyState = "InputEnded"})
            elseif input.KeyCode == Enum.KeyCode.E then
                InputController:SendToPowersService({InputId = "E", KeyState = "InputEnded"})
            elseif input.KeyCode == Enum.KeyCode.R then
                InputController:SendToPowersService({InputId = "R", KeyState = "InputEnded"})
            elseif input.KeyCode == Enum.KeyCode.T then
                InputController:SendToPowersService({InputId = "T", KeyState = "InputEnded"})
            elseif input.KeyCode == Enum.KeyCode.F then
                InputController:SendToPowersService({InputId = "F", KeyState = "InputEnded"})
            elseif input.KeyCode == Enum.KeyCode.Z then
                InputController:SendToPowersService({InputId = "Z", KeyState = "InputEnded"})
            elseif input.KeyCode == Enum.KeyCode.X then
                InputController:SendToPowersService({InputId = "X", KeyState = "InputEnded"})
            elseif input.KeyCode == Enum.KeyCode.C then
                InputController:SendToPowersService({InputId = "Q", KeyState = "InputEnded"})
            end
        end)
end

function InputController:KnitStart()
    self:KeyboardSetup()
    self:MouseSetup()
end

function InputController:KnitInit()

end

return InputController