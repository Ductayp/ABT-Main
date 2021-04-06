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

-- modules
local utils = require(Knit.Shared.Utils)

-- local variables
local localPlayer = game.Players.LocalPlayer
local character
local humanoid
local canDoubleJump = false
local hasDoubleJumped = false
local oldPower
local TIME_BETWEEN_JUMPS = 0.2
local DOUBLE_JUMP_POWER_MULTIPLIER = 2

--// SendToPowersService
function InputController:SendToPowersService(params)

    if not Knit.Controllers.GuiController.InDialogue then
        Knit.Controllers.PowersController:InitializePower(params)
    end

end

function InputController:MouseSetup()

    UserInputService.InputBegan:Connect(function(input, gameProcessed)

        if gameProcessed then return end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            InputController:SendToPowersService({InputId = "Mouse1", KeyState = "InputBegan"})
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gameProcessed)

        if gameProcessed then return end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            InputController:SendToPowersService({InputId = "Mouse1", KeyState = "InputEnded"})
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

function InputController:DoubleJumpSetup()

    UserInputService.JumpRequest:connect(function()

        if not character or not humanoid or not character:IsDescendantOf(workspace) or humanoid:GetState() == Enum.HumanoidStateType.Dead then
            return
            print("YEET")
        end
	
        print("canDoubleJump", canDoubleJump)
        print("hasDoubleJumped", hasDoubleJumped)

        if canDoubleJump and not hasDoubleJumped then
            oldPower = humanoid.JumpPower
            hasDoubleJumped = true
            humanoid.JumpPower = oldPower * DOUBLE_JUMP_POWER_MULTIPLIER
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

function InputController:CharacterAdded(newCharacter)
    character = newCharacter
    humanoid = newCharacter:WaitForChild("Humanoid")

    humanoid.StateChanged:connect(function(old, new)
        if new == Enum.HumanoidStateType.Freefall then
            wait(TIME_BETWEEN_JUMPS)
            canDoubleJump = true
        elseif new == Enum.HumanoidStateType.Landed then
			canDoubleJump = false
			hasDoubleJumped = false
            humanoid.JumpPower = oldPower
        end
    end)
end

function InputController:KnitStart()

    self:KeyboardSetup()
    self:MouseSetup()
    --self:DoubleJumpSetup()

    if localPlayer.Character then
        --self:CharacterAdded(localPlayer.Character)
    end

    localPlayer.CharacterAdded:connect(function(newCharacter)
        --self:CharacterAdded(newCharacter)
    end)

end

function InputController:KnitInit()

end

return InputController