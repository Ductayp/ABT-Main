-- Walk Speed Effect
-- PDab
-- 12-5-2020

-- tracks player actual walkspeed based on any number of modifiers.
-- Also has function to modify the players walkspeed and restore it, as well as visual effects

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)

-- Constants
local DEFAULT_WALKSPEED = 16

local WalkSpeed = {}

--// AddModifier - fires after AddModifier from ModifierService
function WalkSpeed.AddModifier(player,thisModifier,params)

    local newWalkSpeed = DEFAULT_WALKSPEED -- start with the default and then add the modifers
    for _,valueObject in pairs(thisModifier.Parent:GetChildren()) do
        newWalkSpeed = newWalkSpeed + valueObject.Value
    end

    player.Character.Humanoid.WalkSpeed = newWalkSpeed

end

--// RemoveModifier - fires after RemoveModifier from ModifierService
function WalkSpeed.RemoveModifier(player, thisModifier, params)

    local classFolder = thisModifier.Parent
    thisModifier:Destroy()
    
    local newWalkSpeed = DEFAULT_WALKSPEED -- start with the default and then add the modifers
    for _,valueObject in pairs(classFolder:GetChildren()) do
        newWalkSpeed = newWalkSpeed + valueObject.Value
    end

    player.Character.Humanoid.WalkSpeed = newWalkSpeed
end

--// GetModifiedValue - can be accessed from anywhere, will return DEFUALT_WALKSPEED plus all current modifiers
function WalkSpeed.GetModifiedValue(player, params)

    local totalWalkSpeed = DEFAULT_WALKSPEED -- start with the default and then add the modifers
    for _,valueObject in pairs(ReplicatedStorage.ModifierService[player.UserId].WalkSpeed:GetChildren()) do
        totalWalkSpeed = totalWalkSpeed + valueObject.Value
    end

    return totalWalkSpeed

end

function WalkSpeed.Test()
    print("test BOOPIE!")
end




return WalkSpeed