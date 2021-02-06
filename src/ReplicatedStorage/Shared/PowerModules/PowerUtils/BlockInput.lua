-- Pin Character Effect
-- PDab
-- 12-4-2020

-- simply anchors the character in place and removes their key input for powers. Used in timestop or freeze attacks

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)


local BlockInput = {}

function BlockInput.AddBlock(userId, name, duration)

    local inputBlockFolder = ReplicatedStorage.PowerStatus[userId]:FindFirstChild("InputBlocks")
    if not inputBlockFolder then
        inputBlockFolder = utils.EasyInstance("Folder",{Name = "InputBlocks", Parent = ReplicatedStorage.PowerStatus[userId]})
    end

    local inputBlockedBool = utils.EasyInstance("BoolValue", {Name = name, Value = true, Parent = inputBlockFolder})

    if duration ~= nil then
        Debris:AddItem(inputBlockedBool, duration)
    else 
        Debris:AddItem(inputBlockedBool, 1)
    end

    return inputBlockedBool
end

function BlockInput.RemoveBlock(userId, name)

    print("BlockInput.RemoveBlock(userId, name)", userId, name)

    local inputBlockFolder = ReplicatedStorage.PowerStatus[userId]:FindFirstChild("InputBlocks")
    print("inputBlockFolder", inputBlockFolder)
    if inputBlockFolder then
        local inputBlockedBool = inputBlockFolder:FindFirstChild(name, true)
        print("inputBlockedBool", inputBlockedBool)
        if inputBlockedBool then
            print("Destroy it!")
            inputBlockedBool:Destroy()
        end
    end

end

function BlockInput.IsBlocked(userId)

    -- default is false
    local isBlocked = false

    -- if we cant find the players folder, then they havent bee blocked yet
    --if not ReplicatedStorage.PowerStatus:FindFirstChild(userId) then
        --return isBlocked
    --end

    local inputBlockFolder = ReplicatedStorage.PowerStatus[userId]:FindFirstChild("InputBlocks")
    if inputBlockFolder then
        local inputBlockObjects = inputBlockFolder:GetChildren()
        if #inputBlockObjects > 0 then
            for _, object in pairs(inputBlockObjects) do
                if object.Value == true then
                    isBlocked = true
                    return isBlocked
                end
            end
        end
    end

    return isBlocked

end


return BlockInput