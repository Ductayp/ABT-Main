-- HideCharacter

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local HideCharacter = {}

function HideCharacter.Server_ApplyEffect(initPlayer, hitCharacter, params)

    print("BEEP")
    
    local hideCharacterTag = hitCharacter:FindFirstChild("CharacterHidden", true)
    if hideCharacterTag then 
        print("NOPE", hideCharacterTag)
        return
    else
        print("Lets GO!")
        hideCharacterTag = Instance.new("BoolValue")
        hideCharacterTag.Name = "CharacterHidden"
        hideCharacterTag.Value = true
        hideCharacterTag.Parent = hitCharacter

        params.HitCharacter = hitCharacter
        Knit.Services.PowersService:RenderHitEffect_AllPlayers("HideCharacter", params)

        spawn(function()
            wait(params.Duration)
            hideCharacterTag:Destroy()
        end)
    end

end

function HideCharacter.Client_RenderEffect(params)

    print("DUBBLE BEEP", params)

    if not params.HitCharacter then return end

    -- hide/unhide hitCharacrer
    spawn(function()
        for i,v in pairs(params.HitCharacter:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Decal") then
                if v.Name ~= "HumanoidRootPart" then
                    if not v:FindFirstChild("Transparent", true) then
                        v.Transparency = 1
                    end
                end
            end
        end
    
        wait(params.Duration)
    
        for i,v in pairs(params.HitCharacter:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Decal") then
                if v.Name ~= "HumanoidRootPart" then
                    if not v:FindFirstChild("Transparent", true) then
                        v.Transparency = 0
                    end
                end
            end
        end
    

    end)


end


return HideCharacter