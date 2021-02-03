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

local ColorShift = {}

function ColorShift.Server_ApplyEffect(initPlayer, hitCharacter, params)

    print("do it YUP! 1")

    -- only apply this effect to players
    local player = utils.GetPlayerFromCharacter(hitCharacter)
    if player then
        Knit.Services.PowersService:RenderEffect_SinglePlayer(player, "ColorShift", params)
    end
end

function ColorShift.Client_RenderEffect(params)

    print("do it YUP! 2")

    spawn(function()
        local colorCorrection = Lighting:FindFirstChild("ColorCorrection")
        local originalContrast = colorCorrection.Contrast
        local newColorCorrection = originalColorCorrection:Clone()
        newColorCorrection.Name = "newColorCorrection"
        newColorCorrection.Parent = Lighting

        local colorTween1 = TweenService:Create(newColorCorrection,TweenInfo.new(.5),{Contrast = -3})
        colorTween1:Play()

        originalColorCorrection.Enabled = false

        wait(params.Duration)

        local colorTween2 = TweenService:Create(newColorCorrection,TweenInfo.new(.5),{Contrast = originalContrast})
        colorTween2:Play()
        wait(params.Duration)
        originalColorCorrection.Enabled = true
        newColorCorrection:Destroy()
    end)
end


return ColorShift