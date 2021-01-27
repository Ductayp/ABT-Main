-- Punch Ability
-- PDab
-- 12-1-2020

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
--local Players = game:GetService("Players")
--local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

-- modules
local utils = require(Knit.Shared.Utils)
local SimpleHitbox = require(Knit.PowerUtils.SimpleHitbox)

-- variables
local lastPunch = "Punch_2"

local Punch = {}

function Punch.Activate(initPlayer,params)

    --[[

    -- drop the walkspeed
    spawn(function()
        initPlayer.Character.Humanoid.WalkSpeed = 5
        wait(.5)
        initPlayer.Character.Humanoid.WalkSpeed = require(Knit.StateModules.WalkSpeed).GetModifiedValue(initPlayer)
    end)

    ]]--

    -- hotbox
    spawn(function()
        wait(.2) -- delay for animations

        -- make a new hitbox, it stays in place
        local boxParams = {}
        boxParams.Size = Vector3.new(4,3,4)
        boxParams.Transparency = 1
        boxParams.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-3))
        
        
        local newHitbox = SimpleHitbox.NewHitBox(initPlayer,boxParams)
        newHitbox.Anchored = false
        utils.EasyWeld(initPlayer.Character.HumanoidRootPart, newHitbox, newHitbox)
        Debris:AddItem(newHitbox, .25)

        newHitbox.ChildAdded:Connect(function(hit)
            if hit.Name == "CharacterHit" then
                if hit.Value ~= initPlayer.Character then
                    local characterHit = hit.Value
                    Knit.Services.PowersService:RegisterHit(initPlayer, characterHit, params.Punch.HitEffects)
                end
            end
        end)
    end)

    -- animations
    if lastPunch == "Punch_1" then
        Knit.Services.PlayerUtilityService.PlayerAnimations[initPlayer.UserId].Punch_2:Play()
        lastPunch = "Punch_2"
    else
        Knit.Services.PlayerUtilityService.PlayerAnimations[initPlayer.UserId].Punch_1:Play()
        lastPunch = "Punch_1"
    end

end

function Punch.Execute(initPlayer,params)
    -- nothing here yet
end

return Punch


