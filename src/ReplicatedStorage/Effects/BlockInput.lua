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
local powerUtils = require(Knit.Shared.PowerUtils)


local BlockInput = {}

function BlockInput.Server_ApplyEffect(hitCharacter,params)

    local player = utils.GetPlayerFromCharacter(hitCharacter)
    if player then
        -- get folder
        local inputBlockFolder = ReplicatedStorage.PowerStatus[player.UserId]:FindFirstChild("InputBlocks")
        if not inputBlockFolder then
            inputBlockFolder = utils.EasyInstance("Folder",{Name = "InputBlocks", Parent = ReplicatedStorage.PowerStatus[player.UserId]})
        end

        -- if a block already exists of this same name, dont create a new one
        if params.Name then
            for name,_ in pairs (inputBlockFolder:GetChildren()) do
                if name == params.Name then
                    print("BlockInput Name: ",name," already exists, cant create a block fo the same name")
                    return
                end
            end
        end
        
        -- setup block value
        local inputBlockedBool = Instance.new("BoolValue")
        inputBlockedBool.Value = true
        inputBlockedBool.Parent = inputBlockFolder
        if params.Name then
            inputBlockedBool.Name = params.Name
        end

        if params.Duration then
            --print("beep",params.Duration)
            Debris:AddItem(inputBlockedBool, params.Duration)
        end

        --return inputBlockedBool
    end
end

function BlockInput.Client_RenderEffect(params)
    -- nothign right now
end


return BlockInput