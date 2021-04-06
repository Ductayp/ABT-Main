-- Bullet Kick Ability
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
local AbilityToggle = require(Knit.PowerUtils.AbilityToggle)
--local ManageStand = require(Knit.Abilities.ManageStand)
local Cooldown = require(Knit.PowerUtils.Cooldown)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)

local StandJump = {}


--// --------------------------------------------------------------------
--// Handler Functions
--// --------------------------------------------------------------------

--// Initialize
function StandJump.Initialize(params, abilityDefs)

	-- check KeyState
	if params.KeyState == "InputBegan" then
		params.CanRun = true
	else
		params.CanRun = false
		return params
    end

    if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
        params.CanRun = false
        return params
    end
    
    -- check cooldown
	if not Cooldown.Client_IsCooled(params) then
		params.CanRun = false
		return params
    end
    
end

--// Activate
function StandJump.Activate(params, abilityDefs)

	-- check KeyState
	if params.KeyState == "InputBegan" then
		params.CanRun = true
	else
		params.CanRun = false
		return
    end
    
    -- check cooldown
	if not Cooldown.Client_IsCooled(params) then
		params.CanRun = false
		return
    end
    

    if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
        params.CanRun = false
        return params
    end

	-- set cooldown
    Cooldown.SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)

    -- block input
    require(Knit.PowerUtils.BlockInput).AddBlock(params.InitUserId, "StandJump", 2)

end

--// Execute
function StandJump.Execute(params, abilityDefs)

    -- run effects
	StandJump.Run_Effects(params, abilityDefs)

end


--// --------------------------------------------------------------------
--// Ability Functions
--// --------------------------------------------------------------------

function StandJump.Run_Effects(params, abilityDefs)

    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

 

    -- apply effects to the initPlayer
    if initPlayer == Players.LocalPlayer then

        local root =  initPlayer.Character.HumanoidRootPart

        -- do the body mover
        local bodyPosition = Instance.new("BodyPosition")
        bodyPosition.MaxForce = Vector3.new(1000000,0,1000000)
        bodyPosition.P = 100000
        bodyPosition.D = 2000
        bodyPosition.Position = (root.CFrame * CFrame.new(0, 2, -100)).Position
        bodyPosition.Parent = root
        spawn(function()
            wait(.8)
            bodyPosition:Destroy()
        end)
        
        -- depth of field effect
        local newDepthOfField = ReplicatedStorage.EffectParts.Effects.DepthOfField.Default:Clone()
        newDepthOfField.Name = "newDepthOfField"
        newDepthOfField.Parent = game:GetService("Lighting")
        Debris:AddItem(newDepthOfField, 1)
    end

    -- add some trails
    local locations = {"Head","UpperTorso","LeftLowerLeg","RightLowerLeg","LeftHand","RightHand"}
    for count = 1, 6 do
        local newTrail = ReplicatedStorage.EffectParts.Abilities.StandJump.StandJumpTrail:Clone()
        local thisLocation = locations[count]
        newTrail.CFrame = initPlayer.Character[thisLocation].CFrame
        newTrail.Parent = initPlayer.Character[thisLocation]
        utils.EasyWeld(newTrail,initPlayer.Character[thisLocation],newTrail)
        spawn(function()
            wait(.7)
            --newTrail.Trail.MaxLength = 0
            --wait(1)
            newTrail:Destroy()
        end)
    end

end

return StandJump


