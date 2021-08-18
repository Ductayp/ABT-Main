-- DamagePreload

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local DamagePreload = {}

--// Server_ApplyEffect
function DamagePreload.Server_ApplyEffect(initPlayer, hitCharacter, effectParams, hitParams)

    --[[
    --print("DamagePreload.Server_ApplyEffect", effectParams, hitParams)

    -- just a final check to be sure were hitting a humanoid
    if hitCharacter:FindFirstChild("Humanoid") then

        local folder = hitCharacter:FindFirstChild("DamagePreload")
        if not folder then
            folder = Instance.new("Folder")
            folder.Name = "DamagePreload"
            folder.Parent = hitCharacter
        end


        local newValue = Instance.new("NumberValue")
        newValue.Value = effectParams.Value
        newValue.Parent = fodler

        spawn(function()
            wait(effectParams.Duration)
            newValue:Destroy()
        end)
        
    end
    ]]--

end

--// Client_RenderEffect
function DamagePreload.Client_RenderEffect(params)

end

return DamagePreload