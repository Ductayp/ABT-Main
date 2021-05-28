-- MobilePunch

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Player = game.Players.LocalPlayer

local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

-- detect if mobile or console
local IsMobile = UserInputService.TouchEnabled --Is true if on mobile.

-- Main Gui
local mainGui = Player.PlayerGui:WaitForChild("MainGui", 120)

local MobilePunch = {}

MobilePunch.Button_Punch = mainGui:FindFirstChild("Button_Punch", true)


MobilePunch.Enabled = false

function MobilePunch.Setup()

    if IsMobile  then
        MobilePunch.Button_Punch.Visible = true

        MobilePunch.Button_Punch.MouseButton1Down:Connect(function()
            Knit.Controllers.InputController:SendToPowersService({InputId = "Mouse1", KeyState = "InputBegan"})
        end)
    end

end


return MobilePunch
