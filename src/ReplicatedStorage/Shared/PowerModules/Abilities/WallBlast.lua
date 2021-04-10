-- WallBlast Ability
-- PDab
-- 12-1-2020

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local AbilityToggle = require(Knit.PowerUtils.AbilityToggle)
local ManageStand = require(Knit.Abilities.ManageStand)
local Cooldown = require(Knit.PowerUtils.Cooldown)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)

-- variables
local lastWallBlast = "WallBlast_2"

local WallBlast = {}


--// --------------------------------------------------------------------
--// Handler Functions
--// --------------------------------------------------------------------

--// Initialize
function WallBlast.Initialize(params, abilityDefs)

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
    
end

--// Activate
function WallBlast.Activate(params, abilityDefs)

	-- check KeyState
	if params.KeyState == "InputBegan" then
		params.CanRun = true
	else
		params.CanRun = false
		return params
    end
    
    -- check cooldown
	if not Cooldown.Client_IsCooled(params) then
		params.CanRun = false
		return
    end

	-- set cooldown
    Cooldown.SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)

    -- block input
    require(Knit.PowerUtils.BlockInput).AddBlock(params.InitUserId, "WallBlast", 2)

    WallBlast.Run_Server(params, abilityDefs)
    
end

--// Execute
function WallBlast.Execute(params, abilityDefs)

	WallBlast.Run_Effects(params, abilityDefs)

end


--// --------------------------------------------------------------------
--// Ability Functions
--// --------------------------------------------------------------------

function WallBlast.Run_Server(params, abilityDefs)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

    local newCFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0, 1.5, -10))
    local serverWall = ReplicatedStorage.EffectParts.Abilities.WallBlast.ServerWall:Clone()
    serverWall.CFrame = newCFrame
    serverWall.Parent = Workspace.RenderedEffects_BlockAbility
    params.WallCFrame = newCFrame

    spawn(function()
        wait(abilityDefs.Duration)
        serverWall:Destroy()
    end)

end

function WallBlast.Run_Effects(params, abilityDefs)

    print("params", params)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    if not initPlayer then
        return
    end

    -- setup the stand, if its not there then make it
	local targetStand = Workspace.PlayerStands[params.InitUserId]:FindFirstChildWhichIsA("Model")
	if not targetStand then
		targetStand = ManageStand.QuickRender(params)
    end

    spawn(function()
        ManageStand.PlayAnimation(params, "Rage")
        ManageStand.Aura_On(params)
        wait(4)
        ManageStand.Aura_Off(params)
    end)
    
    -- play the sound when it is fired
	WeldedSound.NewSound(targetStand.HumanoidRootPart, ReplicatedStorage.Audio.General.AgressiveYell)

    local newWall = ReplicatedStorage.EffectParts.Abilities.WallBlast.ClientWall:Clone()
    newWall.CFrame = params.WallCFrame
    newWall.CFrame = params.WallCFrame * CFrame.new(0, -10, 0)
    newWall.Parent = Workspace.RenderedEffects

    local newParticle = ReplicatedStorage.EffectParts.Abilities.WallBlast.BaseParticles:Clone()
    newParticle.CFrame = params.WallCFrame * CFrame.new(0, -4, 0)
    newParticle.Parent = Workspace.RenderedEffects

    local tweenPositionUp = TweenService:Create(newWall, TweenInfo.new(.5), {CFrame = params.WallCFrame})
    tweenPositionUp:Play()

    for i, v in pairs(newWall:GetChildren()) do
        if v.Name == "Part" then

        end
    end

    -- semi-accurate wait
    local blastTime = os.clock() + abilityDefs.Duration
    while os.clock() < blastTime do
        wait()
    end
    
    --newWall:Destroy()
    

end

return WallBlast


