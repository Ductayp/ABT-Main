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

    -- only apply this effect to players
    local player = utils.GetPlayerFromCharacter(hitCharacter)
    if player then

        params.DayCycle = Knit.Services.EnvironmentService.CurrentCycle
        Knit.Services.PowersService:RenderHitEffect_SinglePlayer(player, "ColorShift", params)

    end

end

function ColorShift.Client_RenderEffect(params)

    spawn(function()

        if Lighting:FindFirstChild("New_ColorCorrection") then return end

        local originalColorCorrection = Lighting:FindFirstChild("ColorCorrection_Main")
        local originalContrast = originalColorCorrection.Contrast
        local newColorCorrection = originalColorCorrection:Clone()
        newColorCorrection.Name = "New_ColorCorrection"
        newColorCorrection.Parent = Lighting

        local targetBrightness
        if params.DayCycle == "Day" then
            targetBrightness = 0
        else
            targetBrightness = -0.5
        end

        local colorTween1 = TweenService:Create(newColorCorrection,TweenInfo.new(.5),{Contrast = -3, Brightness = targetBrightness})
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