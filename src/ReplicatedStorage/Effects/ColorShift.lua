-- Color Shift Effect
-- PDab
-- 12-4-2020

-- simply anchors the character in place and removes their key input for powers. Used in timestop or freeze attacks

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)


local ColorShift = {}

function ColorShift.Server_ApplyEffect(hitCharacter,params)
    
    -- only apply this effect to players
    local player = utils.GetPlayerFromCharacter(hitCharacter)
    if player then
        Knit.Services.PowersService:RenderEffect_SinglePlayer(player,"ColorShift",params)
    end
end

function ColorShift.Client_RenderEffect(params)

    spawn(function()
        local originalColorCorrection = Lighting:FindFirstChild("ColorCorrection")
        local newColorCorrection = originalColorCorrection:Clone()  
        newColorCorrection.Parent = Lighting


        local colorTween1 = TweenService:Create(newColorCorrection,TweenInfo.new(.5),{Contrast = -3})
        colorTween1:Play()

        originalColorCorrection.Enabled = false

        wait(params.Duration)
        local colorTween2 = TweenService:Create(newColorCorrection,TweenInfo.new(.5),{Contrast = originalColorCorrection.Contrast})
        colorTween2:Play()
        wait(params.Duration)
        originalColorCorrection.Enabled = true
        newColorCorrection:Destroy()
    end)
end


return ColorShift