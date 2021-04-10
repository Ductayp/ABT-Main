-- Lock Character


-- used to lock the players control while using powers

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")


-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)


local MobilityLock = {}


function MobilityLock.Client_AddLock(params)

    if params.LockCamera then
        Workspace.Camera.CameraType = Enum.CameraType.Fixed
    end

    if params.ShiftLock_NoSpin then
        if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
            Workspace.Camera.CameraType = Enum.CameraType.Fixed
            UserInputService.MouseIconEnabled = false
        end
    end

    if params.AnchorCharacter then
        Players.LocalPlayer.Character.HumanoidRootPart.Anchored = true
    end

    if params.HideMouseIcon then
        UserInputService.MouseIconEnabled = false
    end

    spawn(function()
    
        wait(params.Duration)
    
        if params.LockCamera then
            Workspace.Camera.CameraType = Enum.CameraType.Custom
        end
        
        if params.ShiftLock_NoSpin then
            Workspace.Camera.CameraType = Enum.CameraType.Custom
            UserInputService.MouseIconEnabled = true
        end
    
        if params.AnchorCharacter then
            Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false
        end
    
        if params.HideMouseIcon then
            UserInputService.MouseIconEnabled = true
        end
    end)

end


return MobilityLock