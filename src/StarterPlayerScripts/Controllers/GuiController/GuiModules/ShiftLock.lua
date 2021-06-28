--Services.
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

local Player = game.Players.LocalPlayer
local UserGameSettings = UserSettings():GetService("UserGameSettings") --Used for setting the player to rotate.

-- settings
local MOBILE_ENABLED = true
local CONSOLE_ENABLED = true
local SHOW_CENTER_CURSOR = true
local CONSOLE_BUTTON = Enum.KeyCode.ButtonR2
local offset = CFrame.new(1.75, 0, 0) --The offset when using the shiftlock.

-- detect if mobile or console
local IsMobile = UserInputService.TouchEnabled --Is true if on mobile.
local IsConsole = GuiService:IsTenFootInterface() --Is true if on console

-- images
local SHIFT_LOCK_OFF = 'rbxasset://textures/ui/mouseLock_off.png'
local SHIFT_LOCK_ON = 'rbxasset://textures/ui/mouseLock_on.png'
local SHIFT_LOCK_CURSOR = 'rbxasset://textures/MouseLockedCursor.png'

-- Main Gui
local mainGui = Player.PlayerGui:WaitForChild("MainGui", 120)

local ShiftLock = {}

ShiftLock.Button_ShiftLock = mainGui:FindFirstChild("Button_ShiftLock", true)
ShiftLock.Cursor_ShiftLock = mainGui:FindFirstChild("Cursor_ShiftLock", true)

ShiftLock.Enabled = false

function ShiftLock.Setup()


    if IsMobile and MOBILE_ENABLED then

        ShiftLock.Button_ShiftLock.Visible = true
        
        ShiftLock.Button_ShiftLock.MouseButton1Down:connect(function()
            ShiftLock.Toggle()
        end)

        RunService:BindToRenderStep("Mobile/ConsoleShiftLock", Enum.RenderPriority.Camera.Value+1, ShiftLock.OnStep)
    end

    if IsConsole and CONSOLE_ENABLED then
		UserInputService.InputBegan:Connect(function(input)
			if input.KeyCode == CONSOLE_BUTTON then
                ShiftLock.Toggle()
			end
		end)

        RunService:BindToRenderStep("Mobile/ConsoleShiftLock", Enum.RenderPriority.Camera.Value+1, ShiftLock.OnStep)
	end

end

function ShiftLock.SetOff()

    if IsMobile and MOBILE_ENABLED then
        ShiftLock.Enabled = false
        ShiftLock.Button_ShiftLock.Image = SHIFT_LOCK_OFF
        ShiftLock.Cursor_ShiftLock.Visible = false

        --local Camera = workspace.CurrentCamera
        --Camera.CameraType = Enum.CameraType.Custom 
    end

end

function ShiftLock.SetOn()

    if IsMobile and MOBILE_ENABLED then
        ShiftLock.Enabled = true
        ShiftLock.Button_ShiftLock.Image = SHIFT_LOCK_ON
        ShiftLock.Cursor_ShiftLock.Visible = true
    end

end

function ShiftLock.Toggle()

    ShiftLock.Enabled = not ShiftLock.Enabled

    if ShiftLock.Enabled then
        ShiftLock.Button_ShiftLock.Image = SHIFT_LOCK_ON
        ShiftLock.Cursor_ShiftLock.Visible = true
    else 
        ShiftLock.Button_ShiftLock.Image = SHIFT_LOCK_OFF
        ShiftLock.Cursor_ShiftLock.Visible = false
    end
        
end


function ShiftLock.OnStep()

    if ShiftLock.Enabled then

        UserGameSettings.RotationType = Enum.RotationType.CameraRelative

        local Camera = workspace.CurrentCamera
        if Camera then
            --Offsets the player if they aren't in first person.
            if (Camera.Focus.Position - Camera.CFrame.Position).Magnitude >= 0.99 then
                Camera.CFrame = Camera.CFrame * offset
                Camera.Focus = CFrame.fromMatrix(Camera.Focus.Position, Camera.CFrame.RightVector, Camera.CFrame.UpVector) * offset
            end
        end
    else
        
        UserGameSettings.RotationType = Enum.RotationType.MovementRelative
    end
    

end




return ShiftLock
