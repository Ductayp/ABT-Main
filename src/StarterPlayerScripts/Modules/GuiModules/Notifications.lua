--Notification GUI
-- PDab
-- 1/4/2021

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

-- Main Gui
local PlayerGui = Players.LocalPlayer.PlayerGui
local mainGui = PlayerGui:WaitForChild("MainGui", 120)

local Notifications = {}

Notifications.NotifyList = {} -- array to hold all un-revealed notifications
Notifications.DelayTime = 5 -- time to show notification in seconds
Notifications.LastUpdate = nil

Notifications.Frame = mainGui.TopGui:FindFirstChild("NotificationFrame", true)
Notifications.Notification_Text = Notifications.Frame:FindFirstChild("Notification_Text", true)
Notifications.Icon_Frame = Notifications.Frame:FindFirstChild("Icon_Frame", true)
Notifications.XP = Notifications.Frame:FindFirstChild("Icon_XP", true)

Notifications.Icons = {}
Notifications.Icons.Arrow = Notifications.Frame:FindFirstChild("Icon_Arrow", true)
Notifications.Icons.Cash = Notifications.Frame:FindFirstChild("Icon_Cash", true)
Notifications.Icons.Item = Notifications.Frame:FindFirstChild("Icon_Item", true)
Notifications.Icons.Orbs = Notifications.Frame:FindFirstChild("Icon_Orbs", true)

--// ShowNotification
function Notifications.ShowNotification(params)

    -- make all icons invisible
    for _,icon in pairs(Notifications.Icons) do
        icon.Visible = false
    end

    -- make the right one visible
    Notifications.Icons[params.Icon].Visible = true

    -- set the text
    Notifications.Notification_Text.Text = params.Text

    -- make it visible
    Notifications.Frame.Visible = true

    -- some tweens
    local moveDown = TweenService:Create(Notifications.Frame, TweenInfo.new(.5), {Position = Notifications.Frame.Position + UDim2.new(0,0,0.2,0)})
    local moveUp = TweenService:Create(Notifications.Frame, TweenInfo.new(.5), {Position = Notifications.Frame.Position + UDim2.new(0,0,0,0)})

    spawn(function()
        moveDown:Play()
        wait(4)
        moveUp:Play()
    end)
end

--// Setup
function Notifications.Update(params)
    table.insert(Notifications.NotifyList, params)
end


--// Setup
function Notifications.Setup()

    -- move it up
    Notifications.Frame.Position = Notifications.Frame.Position + UDim2.new(0,0,-.2,0)

    -- besic stuff
    Notifications.Frame.Visible = false
    Notifications.LastUpdate = os.clock()

    spawn(function()

         -- main loop, checks the NotifyList table and will display notifications as needed
        while true do
            if #Notifications.NotifyList > 0 and Notifications.LastUpdate < os.clock() - Notifications.DelayTime then
                Notifications.ShowNotification(Notifications.NotifyList[1])
                Notifications.LastUpdate = os.clock()
                table.remove(Notifications.NotifyList, 1)
                print(Notifications.NotifyList)
            end
            wait(1)
        end
    
    end)

   

end

return Notifications