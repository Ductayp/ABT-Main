-- Ability Toggle
-- PDab
-- 12-4-2020

-- applies both pracitcal effects and visual effects if needed

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)


local AbilityToggle = {}

--// SetToggle
function AbilityToggle.SetToggle(player,toggleName,toggleValue)

    -- get the Toggle folder inside the players PowerStatus folder, make it if it doesnt exist
    local toggleFolder = ReplicatedStorage.PowerStatus[player.UserId]:FindFirstChild("Toggles")
    if not toggleFolder then
        toggleFolder = utils.EasyInstance("Folder", {Name = "Toggles", Parent = ReplicatedStorage.PowerStatus[player.userId]})
    end

    -- find if a BoolValue already exists, make it if not
    thisToggle = toggleFolder:FindFirstChild(toggleName)
    if not thisToggle then
        thisToggle = Instance.new("BoolValue")
        thisToggle.Name = toggleName
        thisToggle.Parent = toggleFolder
    end

    thisToggle.Value = toggleValue

end

--// GetToggleValue
--// check if a toggle exists. Only returns true if it exists and is true, otherwise returns false.
function AbilityToggle.GetToggleValue(player,toggleName)

    local returnValue = false

    local toggleFolder = ReplicatedStorage.PowerStatus[player.UserId]:FindFirstChild("Toggles")
    if toggleFolder then
        thisToggle = toggleFolder:FindFirstChild(toggleName)
        if thisToggle then
            returnValue = thisToggle.Value
        end
    end

    return returnValue

end

--// GetToggleObject -- gets the toggle object, crates it if it doesnt exists and sets to false, then returns it
function AbilityToggle.GetToggleObject(player,toggleName)

    toggleFolder = ReplicatedStorage.PowerStatus[player.UserId]:FindFirstChild("Toggles")
    if toggleFolder then
        local thisToggle = toggleFolder:FindFirstChild(toggleName)
        if not thisToggle then
            thisToggle = Instance.new("BoolValue")
            thisToggle.Name = toggleName
            thisToggle.Value = false
            thisToggle.Parent = toggleFolder
        end
        return thisToggle
    end
end

--// RequireFalse
function AbilityToggle.RequireFalse(player,toggleNamesArray)

    local returnValue = true
    toggleFolder = ReplicatedStorage.PowerStatus[player.UserId]:FindFirstChild("Toggles")
    if toggleFolder then
        for _,toggleName in pairs(toggleNamesArray) do
            for _,toggleObject in pairs(toggleFolder:GetChildren()) do
                if toggleName == toggleObject.Name then
                    if toggleObject.Value == true then
                        returnValue = false
                        return returnValue
                    end
                end
            end
        end
    else
        returnValue = false -- this happens if there is no toggles folder yet
    end

    return returnValue
end

--// RequireTrue
function AbilityToggle.RequireTrue(player,toggleNamesArray)

    local returnValue = true
    toggleFolder = ReplicatedStorage.PowerStatus[player.UserId]:FindFirstChild("Toggles")
    if toggleFolder then
        for _,toggleName in pairs(toggleNamesArray) do
            for _,toggleObject in pairs(toggleFolder:GetChildren()) do
                if toggleName == toggleObject.Name then
                    if toggleObject.Value == false then
                        returnValue = false
                        return returnValue
                    end
                end
            end
        end
    else
        returnValue = false -- this happens if there is no toggles folder yet
    end

    return returnValue
end

return AbilityToggle