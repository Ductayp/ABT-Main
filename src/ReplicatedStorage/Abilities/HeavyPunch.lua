-- Heavy Punch Ability
-- PDab
-- 12-1-2020

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)
local ManageStand = require(Knit.Abilities.ManageStand)

local HeavyPunch = {}

function HeavyPunch.Server_DoPunch(initPlayer,params)
    
    wait(1)
    local hitBox = ReplicatedStorage.EffectParts.Abilities.HeavyPunch.HeavyPunch_Hitbox:Clone()
    hitBox.Parent = workspace.RenderedEffects
    hitBox.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-5)) -- positions somewhere good near the stand
    local hitBoxWeld = utils.EasyWeld(hitBox, initPlayer.Character.HumanoidRootPart, hitBox)
    Debris:AddItem(hitBox,1.5)

    
    local excludeCharacter = {initPlayer = true} -- a dictionary of chaacter to exclude, can be added to
    hitBox.Touched:Connect(function(hit) 

        local humanoid = hit.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then

            local isExcluded = false
            for character,boolean in pairs (excludeCharacter) do
                if character == hit.Parent then
                    isExcluded = true
                    break
                end
            end

            if isExcluded == false then
                excludeCharacter[hit.Parent] = true
                Knit.Services.PowersService:RegisterHit(initPlayer,hit.Parent,params.HeavyPunch)
            end
        end
    end)

end

function HeavyPunch.Client_DoPunch(initPlayer,params)

    -- setup the stand, if its not there then dont run return
	local targetStand = workspace.PlayerStands[initPlayer.UserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		return
    end

    --move the stand and do animations
    spawn(function()
        ManageStand.PlayAnimation(initPlayer,params,"HeavyPunch")
        wait(.2)
        targetStand.WeldConstraint.Enabled = false
        targetStand.HumanoidRootPart.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-2)) -- move
        targetStand.WeldConstraint.Enabled = true
        wait(1.5)
        targetStand.WeldConstraint.Enabled = false
        targetStand.HumanoidRootPart.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(2,1,2.5))
        targetStand.WeldConstraint.Enabled = true

    end)
    



end

return HeavyPunch


