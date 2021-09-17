-- Punch Ability
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
local lastPunch = "Punch_2"

local Punch = {}


--// --------------------------------------------------------------------
--// Handler Functions
--// --------------------------------------------------------------------

--// Initialize
function Punch.Initialize(params, abilityDefs)

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
    
    --[[
    -- tween effects
    spawn(function()
        Punch.Run_Effects(params, abilityDefs)
    end)
    ]]--
	
end

--// Activate
function Punch.Activate(params, abilityDefs)

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

	-- set cooldown
    --Cooldown.Server_SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)

    -- block input
    require(Knit.PowerUtils.BlockInput).AddBlock(params.InitUserId, "Punch", 0.5)

    -- tween hitbox
    spawn(function()
        Punch.Run_Server(params, abilityDefs)
    end)
    
end

--// Execute
function Punch.Execute(params, abilityDefs)

    -- nothign here

end


--// --------------------------------------------------------------------
--// Ability Functions
--// --------------------------------------------------------------------

function Punch.Run_Server(params, abilityDefs)

    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
    if not initPlayer then return end

    local initCharacter = initPlayer.Character
    if not initCharacter then return end

    -- play animations and sounds
    if lastPunch == "Punch_1" then
        Knit.Services.PlayerUtilityService.PlayerAnimations[initPlayer.UserId].Punch_2:Play()
        WeldedSound.NewSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.General.GenericWhoosh_Slow, {SoundProperties = {PlaybackSpeed = 1.7}})
        lastPunch = "Punch_2"
    else
        Knit.Services.PlayerUtilityService.PlayerAnimations[initPlayer.UserId].Punch_1:Play()
        WeldedSound.NewSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.General.GenericWhoosh_Fast)
        lastPunch = "Punch_1"
    end

    -- hitbox
	local hitBox = Instance.new("Part")
    hitBox.CanCollide = false
    hitBox.Massless = true
	hitBox.Size = Vector3.new(4,4,4)
	hitBox.Transparency = 1
	hitBox.Parent = Workspace.ServerHitboxes[params.InitUserId]

    local newWeld = Instance.new("Weld")
	newWeld.C1 =  CFrame.new(0, 0, 2)
	newWeld.Part0 = initPlayer.Character.HumanoidRootPart
	newWeld.Part1 = hitBox
	newWeld.Parent = hitBox

    hitBox.Touched:Connect(function() end)

    spawn(function()

        local hit = hitBox:GetTouchingParts()
        local hitCharacters = {}
        for _, part in pairs(hit) do
            if part.Parent:FindFirstChild("Humanoid") then
                hitCharacters[part.Parent] = true
            end
        end

        for character, _ in pairs(hitCharacters) do
            local thisPlayer = utils.GetPlayerFromCharacter(character)
            if thisPlayer ~= initPlayer then
                Punch.HitCharacter(params, abilityDefs, initPlayer, character)
            end
        end

        hitBox.Touched:Connect(function(part)
            if part.Parent:FindFirstChild("Humanoid") then
                if not hitCharacters[part.Parent] then
                    hitCharacters[part.Parent] = true
                    Punch.HitCharacter(params, abilityDefs, initPlayer, part.Parent)
                end
            end
        end)

        wait(.2)
        hitBox:Destroy()

    end)

end

function Punch.HitCharacter(params, abilityDefs, initPlayer, hitCharacter)

    if hitCharacter:FindFirstChild("OrganInversion_Effect", true) then

        abilityDefs.HitEffects = {
            Damage = {Damage = 15, KnockBack = 10},
        }

        Knit.Services.PowersService:RegisterHit(initPlayer, hitCharacter, abilityDefs)

    else

        local newBool = Instance.new("BoolValue")
        newBool.Name = "OrganInversion_Effect"
        newBool.Parent = hitCharacter

        spawn(function()
            wait(5)
            newBool:Destroy()
        end)

        abilityDefs.HitEffects = {
            Damage = {Damage = 35, KnockBack = 25},
            --DamageOverTime = {Damage = 4, TickCount = 5, TickLength = 1},
            RunFunctions = {
                {RunOn = "Client", Script = script, FunctionName = "Client_OrganEffect", Arguments = {}},
            },
        }
    
        Knit.Services.PowersService:RegisterHit(initPlayer, hitCharacter, abilityDefs)

    end

end


function Punch.Client_OrganEffect(params)

    print("CLIENT - ORGAN PUNCH", params)

    local hitCharacter = params.HitCharacter
    if not hitCharacter then return end

    local upperTorso = hitCharacter:FindFirstChild("UpperTorso")
    if not upperTorso then return end

    local effectFolder = ReplicatedStorage.EffectParts.Abilities.Punch_OrganInversion

    for _, v in pairs(effectFolder:GetChildren()) do

        local newParticle = v:Clone()
        newParticle.Parent = upperTorso

        newParticle:Emit(40)

        spawn(function()

            wait(5)
            newParticle.Enabled = false
            wait(10)
            newParticle:Destroy()
        
        end)

    end

end


return Punch


