
local VampiricRage = {}

-- Server_AbilityOn
function VampiricRage.Server_AbilityOn(params, abilityDefs)

    print("VR - ON")

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
	if not initPlayer then return end

    Knit.Services.PlayerUtilityService:ToggleRegen(initPlayer, false)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Multiplier_Damage", "VampiricRage", 2, nil)

end

-- Server_AbilityOff
function VampiricRage.Server_AbilityOff(params, abilityDefs)

    print("VR - OFF")

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
	if not initPlayer then return end

    Knit.Services.PlayerUtilityService:ToggleRegen(initPlayer, true)
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Multiplier_Damage", "VampiricRage")

end

-- Client_AbilityOn
function VampiricRage.Client_AbilityOn(params, abilityDefs)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
	if not initPlayer then return end

end

-- Client_AbilityOff
function VampiricRage.Client_AbilityOff(params, abilityDefs)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)
	if not initPlayer then return end

end

return VampiricRage