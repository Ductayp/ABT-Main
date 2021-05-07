local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

local VampiricRage = {}

-- Server_AbilityOn
function VampiricRage.Server_AbilityOn(params, abilityDefs)

    print("VR - ON")

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
	if not initPlayer then return end

    Knit.Services.PlayerUtilityService:SetDamageStatus(initPlayer, {Enabled = true, Profile = "VampiricRage"})
    Knit.Services.StateService:AddEntryToState(initPlayer, "Multiplier_Damage", "VampiricRage", 2, nil)

end

-- Server_AbilityOff
function VampiricRage.Server_AbilityOff(params, abilityDefs)

    print("VR - OFF")

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
	if not initPlayer then return end

    Knit.Services.PlayerUtilityService:SetDamageStatus(initPlayer, {Enabled = true, Profile = "Default"})
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Multiplier_Damage", "VampiricRage")

end

-- Client_AbilityOn
function VampiricRage.Client_AbilityOn(params, abilityDefs)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
	if not initPlayer then return end

    if initPlayer.Character and initPlayer.Character.Head then
        local newAura = ReplicatedStorage.EffectParts.Specs.Vampire.VampireHeadAura:Clone()
        newAura.Parent = initPlayer.Character.Head
        spawn(function()
            newAura.Speed = NumberRange.new(1, 1)
            newAura:Emit(200)
            wait(.5)
            newAura.Speed = NumberRange.new(.2, .2)
        end)
        

        local newText = ReplicatedStorage.EffectParts.Specs.Vampire.RageText:Clone()
        newText.Parent = initPlayer.Character.Head
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