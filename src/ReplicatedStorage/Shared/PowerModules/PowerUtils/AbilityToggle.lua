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

local AbilityToggle = {}

--// QuickToggle this sets the toggle for a brief time, then it puts it back to original value
function AbilityToggle.QuickToggle(userId, toggleName)

    -- get the Toggle folder inside the players PowerStatus folder, make it if it doesnt exist
    local toggleFolder = ReplicatedStorage.PowerStatus[userId]:FindFirstChild("Toggles")
    if not toggleFolder then
        toggleFolder = utils.EasyInstance("Folder", {Name = "Toggles", Parent = ReplicatedStorage.PowerStatus[userId]})
    end

    --[[
    -- find if a BoolValue already exists, make it if not
    thisToggle = toggleFolder:FindFirstChild(toggleName)
    if not thisToggle then
        thisToggle = Instance.new("BoolValue")
        thisToggle.Name = toggleName
        thisToggle.Parent = toggleFolder
    end
    ]]--

    local thisToggle = utils.EasyInstance("BoolValue", {Name = toggleName, Parent = toggleFolder, Value = true})
    spawn(function()
        wait(2) -- the standard quick toggle wait
        thisToggle:Destroy()
    end)

end

--// SetToggle
function AbilityToggle.SetToggle(userId, toggleName, toggleValue)

    -- get the Toggle folder inside the players PowerStatus folder, make it if it doesnt exist
    local toggleFolder = ReplicatedStorage.PowerStatus[userId]:FindFirstChild("Toggles")
    if not toggleFolder then
        toggleFolder = utils.EasyInstance("Folder", {Name = "Toggles", Parent = ReplicatedStorage.PowerStatus[userId]})
    end

    -- find if a BoolValue already exists, make it if not
    thisToggle = toggleFolder:FindFirstChild(toggleName)
    if not thisToggle then
        thisToggle = Instance.new("BoolValue")
        thisToggle.Name = toggleName
        thisToggle.Parent = toggleFolder
    end

    thisToggle.Value = toggleValue

    return thisToggle

end

--// GetToggleValue
--// check if a toggle exists. Only returns true if it exists and is true, otherwise returns false.
function AbilityToggle.GetToggleValue(userId, toggleName)

    local returnValue = false

    local playerFolder = ReplicatedStorage.PowerStatus:FindFirstChild(userId)
    if playerFolder then
        local toggleFolder = playerFolder:FindFirstChild("Toggles")
        if toggleFolder then
            thisToggle = toggleFolder:FindFirstChild(toggleName)
            if thisToggle then
                returnValue = thisToggle.Value
            end
        end
    end

    return returnValue

end

--// GetToggleObject -- gets the toggle object, crates it if it doesnt exists and sets to false, then returns it
function AbilityToggle.GetToggleObject(userId, toggleName)

    toggleFolder = ReplicatedStorage.PowerStatus[userId]:FindFirstChild("Toggles")
    if not toggleFolder then
        toggleFolder = utils.EasyInstance("Folder", {Name = "Toggles", Parent = ReplicatedStorage.PowerStatus[userId]})
    end

    local thisToggle = toggleFolder:FindFirstChild(toggleName)
    if not thisToggle then
        thisToggle = Instance.new("BoolValue")
        thisToggle.Name = toggleName
        thisToggle.Value = false
        thisToggle.Parent = toggleFolder
    end

    return thisToggle

end


--// RequireOn - this is the one to use
function AbilityToggle.RequireOn(userId, toggleNamesArray)

    local allTogglesOn = true -- start with true, if any in the array fail, it returns false
    toggleFolder = ReplicatedStorage.PowerStatus[userId]:FindFirstChild("Toggles")
    if toggleFolder then
        for _,toggleName in pairs(toggleNamesArray) do
            for _,toggleObject in pairs(toggleFolder:GetChildren()) do
                if toggleName == toggleObject.Name then
                    if toggleObject.Value == false then
                        allTogglesOn = false
                        return allTogglesOn
                    end
                end
            end
        end
    else
        allTogglesOn = false -- this happens if there is no toggles folder yet
    end

    return allTogglesOn

end

--// RequireOff - this is the one to use
function AbilityToggle.RequireOff(userId,toggleNamesArray)

    local allTogglesOn = true -- start with true, if any toggles are on, we set it to false and return
    toggleFolder = ReplicatedStorage.PowerStatus[userId]:FindFirstChild("Toggles")
    if toggleFolder then
        for _,toggleName in pairs(toggleNamesArray) do
            for _,toggleObject in pairs(toggleFolder:GetChildren()) do
                if toggleName == toggleObject.Name then
                    if toggleObject.Value == true then
                        allTogglesOn = false
                        return allTogglesOn
                    end
                end
            end
        end
    else
        returnValue = true -- this happens if there is no toggles folder yet
    end

    return allTogglesOn

end

return AbilityToggle