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


local PinCharacter = {}

function PinCharacter.Server_ApplyEffect(hitCharacter,params)
    print("pin character")
    for i,v in pairs(params) do
        print(i,v)
    end
    
    spawn(function()

        -- anchor the hitCharacter
        for _,part in pairs(hitCharacter:GetChildren()) do
            if part:IsA("BasePart") then
                part.Anchored = true
            end
        end

         -- wait and then restore the targetPlayer
        wait(params.Duration)

        -- un-anchor the targetPlayer
        for _,part in pairs(hitCharacter:GetChildren()) do
            if part:IsA("BasePart") then
                part.Anchored = false
            end
        end

    end) 
end

function PinCharacter.Client_RenderEffect(params)
    -- nothign right now
end


return PinCharacter