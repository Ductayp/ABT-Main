-- BitesTheDust
-- PDab
-- 12-1-2020

--Roblox Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local AbilityToggle = require(Knit.PowerUtils.AbilityToggle)
local ManageStand = require(Knit.Abilities.ManageStand)
local Cooldown = require(Knit.PowerUtils.Cooldown)
local RayHitbox = require(Knit.PowerUtils.RayHitbox)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)

local abilityDuration = 5
local countdownLength = 5
local blastRange = 10

local BitesTheDust = {}

--// --------------------------------------------------------------------
--// Handler Functions
--// --------------------------------------------------------------------

--// Initialize
function BitesTheDust.Initialize(params, abilityDefs)

	-- check KeyState
	if params.KeyState == "InputBegan" then
		params.CanRun = true
	else
		params.CanRun = false
		return
    end
    
    -- check cooldown
    if not Cooldown.Client_IsCooled(params) then
        print("not cooled down", params)
		params.CanRun = false
		return
    end

    if abilityDefs.RequireToggle_On then
        if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
            print("stand wasnt on")
            params.CanRun = false
            return params
        end
    end
    

    -- tween effects
    spawn(function()
        BitesTheDust.Run_Client(params, abilityDefs)
    end)
	
end

--// Activate
function BitesTheDust.Activate(params, abilityDefs)

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
    
    if abilityDefs.RequireToggle_On then
        if not AbilityToggle.RequireOn(params.InitUserId, abilityDefs.RequireToggle_On) then
            params.CanRun = false
            return params
        end
    end

	-- set cooldown
    Cooldown.SetCooldown(params.InitUserId, params.InputId, abilityDefs.Cooldown)

    -- block input
    require(Knit.PowerUtils.BlockInput).AddBlock(params.InitUserId, "BitesTheDust", 2)

    -- tween hitbox
    BitesTheDust.Run_Server(params, abilityDefs)

end

--// Execute
function BitesTheDust.Execute(params, abilityDefs)

	if Players.LocalPlayer.UserId == params.InitUserId then
		print("Players.LocalPlayer == initPlayer: DO NOT RENDER")
		return
	end

    -- tween effects
	BitesTheDust.Run_Client(params, abilityDefs)

end


--// --------------------------------------------------------------------
--// Ability Functions
--// --------------------------------------------------------------------

function BitesTheDust.Run_Server(params, abilityDefs)

    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

    -- clone out a new hitpart
    local hitPart = ReplicatedStorage.EffectParts.Abilities.BitesTheDust  .HitBox:Clone()
    hitPart.Parent = Workspace.ServerHitboxes[params.InitUserId]
    hitPart.CFrame = initPlayer.Character.HumanoidRootPart.CFrame
    Debris:AddItem(hitPart, abilityDuration)
    utils.EasyWeld(initPlayer.Character.HumanoidRootPart, hitPart, hitPart)

    -- make a new hitbox
    local newHitbox = RayHitbox.New(initPlayer, abilityDefs, hitPart, false)
    newHitbox.OnHit:Connect(function(hit, humanoid)
        if humanoid.Parent ~= initPlayer.Character then
            print("hit 1")
            BitesTheDust.HitCharacter(initPlayer, humanoid.Parent, abilityDefs)
        end
    end)
    newHitbox:HitStart()
    --newHitbox:DebugMode(true)

end

function BitesTheDust.Run_Client(params, abilityDefs)

    -- get initPlayer
    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

    local aura_1 = ReplicatedStorage.EffectParts.Abilities.BitesTheDust.Aura_1:Clone()
    local aura_2 = ReplicatedStorage.EffectParts.Abilities.BitesTheDust.Aura_2:Clone()
    aura_1.Parent = initPlayer.Character.HumanoidRootPart
    aura_2.Parent = initPlayer.Character.HumanoidRootPart
    Debris:AddItem(aura_1, abilityDuration)
    Debris:AddItem(aura_2, abilityDuration)

    WeldedSound.NewSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.StandSpecific.KillerQueen.KiraBiteTheDust)

end

function BitesTheDust.HitCharacter(initPlayer, hitCharacter, abilityDefs)

    local aura_1 = ReplicatedStorage.EffectParts.Abilities.BitesTheDust.Aura_1:Clone()
    local aura_2 = ReplicatedStorage.EffectParts.Abilities.BitesTheDust.Aura_2:Clone()
    local newCountdown = ReplicatedStorage.EffectParts.Abilities.BitesTheDust.Countdown:Clone()
    aura_1.Parent = hitCharacter.HumanoidRootPart
    aura_2.Parent = hitCharacter.HumanoidRootPart
    newCountdown.Parent = hitCharacter

    WeldedSound.NewSound(hitCharacter.HumanoidRootPart, ReplicatedStorage.Audio.StandSpecific.KillerQueen.BombClick)

    spawn(function()

        for count = 1, countdownLength do
            newCountdown.TextLabel.Text = (countdownLength - count) + 1
            if count ~= 1 then
                WeldedSound.NewSound(hitCharacter.HumanoidRootPart, ReplicatedStorage.Audio.StandSpecific.KillerQueen.BombClick, {SoundProperties = {Volume = 0.25}})
            end
           
            if count == countdownLength then
                
                wait(.5)
                aura_1:Destroy()
                aura_2:Destroy()
                newCountdown:Destroy()
        
                -- apply hiteffects to the originally it character
                abilityDefs.HitEffects = {Damage = {Damage = 35, HideEffects = true}, Blast = {}, KnockBack = {Force = 70, ForceY = 50, LookVector = hitCharacter.HumanoidRootPart.CFrame.UpVector}}
                Knit.Services.PowersService:RegisterHit(initPlayer, hitCharacter, abilityDefs)
        
                local targetTable = {}
        
                -- put all mobs in targetTable
                for _,mob in pairs(Knit.Services.MobService.SpawnedMobs) do
                    if mob.Model:FindFirstChild("Humanoid") then
                        if mob.Model.Humanoid.Health > 0 then
                            if (hitCharacter.HumanoidRootPart.Position - mob.Model.HumanoidRootPart.Position).Magnitude < blastRange then
                                table.insert(targetTable, mob.Model)
                            end
                        end
                    end
                end
        
                -- put all players in targetTable
                for _, player in pairs(game.Players:GetPlayers()) do
                    if (hitCharacter.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude < blastRange then
                        table.insert(targetTable, player.Character)
                    end
                end
        
                -- setup HitEffects for the secondary targets
                for _,character in pairs(targetTable) do
                    local newLookVector = (hitCharacter.HumanoidRootPart.Position - character.HumanoidRootPart.Position).unit
                    abilityDefs.HitEffects = {Damage = {Damage = 35, HideEffects = true}, Blast = {}, KnockBack = {Force = 70, ForceY = 50, LookVector = newLookVector}}
                    Knit.Services.PowersService:RegisterHit(initPlayer, character, abilityDefs)
                end
            end

            wait(1)
        end
        
        
        

    end)

        

end

return BitesTheDust


