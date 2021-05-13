-- RageBoost Ability
-- PDab
-- 12-1-2020

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
--local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local AbilityToggle = require(Knit.PowerUtils.AbilityToggle)
local ManageStand = require(Knit.Abilities.ManageStand)
local Cooldown = require(Knit.PowerUtils.Cooldown)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)

-- variables
local lastRageBoost = "RageBoost_2"

local RageBoost = {}


--// --------------------------------------------------------------------
--// Handler Functions
--// --------------------------------------------------------------------

--// Initialize
function RageBoost.Initialize(params, abilityDefs)

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
    
end

--// Activate
function RageBoost.Activate(params, abilityDefs)

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
    require(Knit.PowerUtils.BlockInput).AddBlock(params.InitUserId, "RageBoost", 2)


    RageBoost.Run_Server(params, abilityDefs)

end

--// Execute
function RageBoost.Execute(params, abilityDefs)

	RageBoost.Run_Effects(params, abilityDefs)

end


--// --------------------------------------------------------------------
--// Ability Functions
--// --------------------------------------------------------------------

function RageBoost.Run_Server(params, abilityDefs)

    spawn(function()
        local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
        Knit.Services.StateService:AddEntryToState(initPlayer, "Multiplier_Damage", "CrazyDiamond_RageBoost", abilityDefs.Multiplier,  {RemoveOnDeath = true})
        wait(abilityDefs.Duration)
        Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Multiplier_Damage", "CrazyDiamond_RageBoost")
    end)

end

function RageBoost.Run_Effects(params, abilityDefs)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    if not initPlayer then
        return
    end
    local character = initPlayer.Character or initPlayer.CharacterAdded:Wait()

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
	--WeldedSound.NewSound(targetStand.HumanoidRootPart, ReplicatedStorage.Audio.General.AgressiveYell)
    WeldedSound.NewSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.StandSpecific.CrazyDiamond.JosukeScream)
    
    local rageText = ReplicatedStorage.EffectParts.Abilities.RageBoost.RageText:Clone()
    rageText.Parent = character.Head

    local rageParticle = ReplicatedStorage.EffectParts.Abilities.RageBoost.RageParticle:Clone()
    rageParticle.Parent = character.Head

    --wait(abilityDefs.Duration)
    --[[
    local originalStudsOffest = rageText.StudsOffset
    local endTime = os.clock() + abilityDefs.Duration
    local offset = 5
    while os.clock() < endTime do
        local newOffset = Vector3.new(math.random(-offset , offset) / 100, math.random(-offset, offset) / 100, math.random(-offset, offset) / 100)
        rageText.StudsOffset = originalStudsOffest + newOffset
        wait()
    end
    ]]--

    rageText:Destroy()
    rageParticle:Destroy()

end

return RageBoost


