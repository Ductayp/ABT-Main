local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local WeldedSound = require(Knit.PowerUtils.WeldedSound)
local utils = require(Knit.Shared.Utils)

local VampiricRage = {}

-- Server_AbilityOn
function VampiricRage.Server_AbilityOn(params, abilityDefs)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
	if not initPlayer then return end

    --Knit.Services.PlayerUtilityService:SetDamageStatus(initPlayer, {Enabled = true, Profile = "VampiricRage"})
    Knit.Services.StateService:AddEntryToState(initPlayer, "HealthTick", "VampiricRage", true, {Day = -2, Night = -2, RemoveOnDeath = true, RemoveOnPowerChange = true})
    Knit.Services.StateService:AddEntryToState(initPlayer, "Multiplier_Damage", "VampiricRage", 2, {RemoveOnDeath = true, RemoveOnPowerChange = true})

    Knit.Services.PlayerUtilityService.PlayerAnimations[initPlayer.UserId].Rage:Play()

end

-- Server_AbilityOff
function VampiricRage.Server_AbilityOff(params, abilityDefs)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
	if not initPlayer then return end

    --Knit.Services.PlayerUtilityService:SetDamageStatus(initPlayer, {Enabled = true, Profile = "Default"})
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "HealthTick", "VampiricRage")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Multiplier_Damage", "VampiricRage")

end

-- Client_AbilityOn
function VampiricRage.Client_AbilityOn(params, abilityDefs)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
	if not initPlayer then return end

    if initPlayer.Character and initPlayer.Character.Head then
        local newAura = ReplicatedStorage.EffectParts.Specs.Vampire.VampireHeadAura:Clone()
        newAura.Parent = initPlayer.Character.Head
        newAura:SetAttribute("StatusEffect", true)
        spawn(function()
            newAura.Speed = NumberRange.new(1, 1)
            newAura:Emit(200)
            wait(.5)
            newAura.Speed = NumberRange.new(.2, .2)
        end)
        
        local newText = ReplicatedStorage.EffectParts.Specs.Vampire.RageText:Clone()
        newText.Parent = initPlayer.Character.Head
        newText:SetAttribute("StatusEffect", true)

        WeldedSound.NewSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.General.Wry)
    end

end

-- Client_AbilityOff
function VampiricRage.Client_AbilityOff(params, abilityDefs)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
	if not initPlayer then return end

    if initPlayer.Character and initPlayer.Character.HumanoidRootPart then
        local aura = initPlayer.Character.Head:FindFirstChild("VampireHeadAura")
        if aura then
            spawn(function()
                aura.Enabled = false
                wait(3)
                aura:Destroy()
            end)
        end

        local text = initPlayer.Character.Head:FindFirstChild("RageText")
        if text then
            text:Destroy()
        end

    end

end

return VampiricRage