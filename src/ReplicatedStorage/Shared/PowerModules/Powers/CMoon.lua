-- CMoon

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

local utils = require(Knit.Shared.Utils)

local CMoon = {}

CMoon.Defs = {
    PowerName = "C-Moon",
    MaxXp = 50000,
    DamageMultiplier = {
        [1] = 1,
        [2] = 1.5,
        [3] = 2,
    },
    HealthModifier = {
        [1] = 30,
        [2] = 50,
        [3] = 90
    },
    KeyMap = {
        [1] = {
            Q = {AbilityName = "Summon Stand"},
            E = {AbilityName = "Barrage"},
            F = {AbilityName = "Organ Inversion"},
            T = {AbilityName = "Gravity Slam" },
            R = {AbilityName = "Gravity Punch"},
            X = {AbilityName = "Gravity Shift"},
            Z = {AbilityName = "Stand Jump"},
            C = {AbilityName = "-"}
        },
        [2] = {
            Q = {AbilityName = "Summon Stand"},
            E = {AbilityName = "Barrage"},
            F = {AbilityName = "Organ Inversion"},
            T = {AbilityName = "Gravity Slam" },
            R = {AbilityName = "Gravity Punch"},
            X = {AbilityName = "Gravity Shift"},
            Z = {AbilityName = "Stand Jump"},
            C = {AbilityName = "-"}
        },
        [3] = {
            Q = {AbilityName = "Summon Stand"},
            E = {AbilityName = "Barrage"},
            F = {AbilityName = "Organ Inversion"},
            T = {AbilityName = "Gravity Slam" },
            R = {AbilityName = "Gravity Punch"},
            X = {AbilityName = "Gravity Shift"},
            Z = {AbilityName = "Stand Jump"},
            C = {AbilityName = "-"}
        },

    },
    Abilities = {}, -- ability defs are inside each ability function area
}

--// SETUP - run this once when the stand is equipped
function CMoon.SetupPower(initPlayer, params)
    Knit.Services.StateService:AddEntryToState(initPlayer, "WalkSpeed", "CMoon_Setup", 6, nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Health", "CMoon_Setup", CMoon.Defs.HealthModifier[params.Rank], nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Multiplier_Damage", "CMoon_Setup", CMoon.Defs.DamageMultiplier[params.Rank], nil)

end

--// REMOVE - run this once when the stand is un-equipped
function CMoon.RemovePower(initPlayer, params)
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "WalkSpeed", "CMoon_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Health", "CMoon_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Multiplier_Damage", "CMoon_Setup")

end

--// MANAGER - this is the single point of entry from PowersService and PowersController.
function CMoon.Manager(params)

    if params.InputId == "Mouse1" then
        CMoon.Punch(params)
    else
        CMoon[params.InputId](params)
    end

    return params
end

--------------------------------------------------------------------------------------------------
--// Q //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
CMoon.Defs.Abilities.Q = {
    Name = "Equip Stand",
    Id = "EquipStand",
    Cooldown = 5,
    StandModels = {
        [1] = ReplicatedStorage.EffectParts.StandModels.CMoon_1,
        [2] = ReplicatedStorage.EffectParts.StandModels.CMoon_2,
        [3] = ReplicatedStorage.EffectParts.StandModels.CMoon_3,
    },
    Sounds = {
        Equip = ReplicatedStorage.Audio.Abilities.StandSummon,
        Remove =  ReplicatedStorage.Audio.Abilities.StandSummon,
    }
}

function CMoon.Q(params)
    params = require(Knit.Abilities.ManageStand)[params.SystemStage](params, CMoon.Defs.Abilities.Q)
end

--------------------------------------------------------------------------------------------------
--// E //----------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
CMoon.Defs.Abilities.E = {
    Id = "Barrage",
    Duration = 4,
    Cooldown = 4,
    RequireToggle_On = {"Q"},
    HitEffects = {Damage = {Damage = 7, KnockBack = 15}},
    Sounds = {
        Barrage = ReplicatedStorage.Audio.StandSpecific.TheWorld.Barrage,
    }
}

function CMoon.E(params)
    params = require(Knit.Abilities.Barrage)[params.SystemStage](params, CMoon.Defs.Abilities.E)
end

--------------------------------------------------------------------------------------------------
--// R //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

--defs
CMoon.Defs.Abilities.R = {
    Id = "GravityPunch",
    Cooldown = 1,
    RequireToggle_On = {"Q"},
    AbilityMod = Knit.Abilities.HeavyPunch:FindFirstChild("GravityPunch", true),
}

function CMoon.R(params)
    params = require(Knit.Abilities.HeavyPunch)[params.SystemStage](params, CMoon.Defs.Abilities.R)
end

--------------------------------------------------------------------------------------------------
--// T //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
CMoon.Defs.Abilities.T = {
    Id = "GravitySlam",
    Cooldown = 1,
    RequireToggle_On = {"Q"},
    AbilityMod = Knit.Abilities.BasicAbility:FindFirstChild("GravitySlam", true),
}

function CMoon.T(params)
    params = require(Knit.Abilities.BasicAbility)[params.SystemStage](params, CMoon.Defs.Abilities.T)
end


--------------------------------------------------------------------------------------------------
--// F //---------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
CMoon.Defs.Abilities.F = {
    Id = "OrganInversion",
    Cooldown = 1,
    RequireToggle_On = {"Q"},
    AbilityMod = Knit.Abilities.BasicAbility:FindFirstChild("OrganInversion", true),
}

function CMoon.F(params)
    params = require(Knit.Abilities.BasicAbility)[params.SystemStage](params, CMoon.Defs.Abilities.F)
end


--------------------------------------------------------------------------------------------------
--// X //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
CMoon.Defs.Abilities.X = {
    Id = "GravityShift",
    Cooldown = 1,
    RequireToggle_On = {"Q"},
    AbilityMod = Knit.Abilities.BasicAbility:FindFirstChild("GravityShift", true),
}

function CMoon.X(params)
    params = require(Knit.Abilities.BasicAbility)[params.SystemStage](params, CMoon.Defs.Abilities.X)
end

--------------------------------------------------------------------------------------------------
--// C //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

--[[
-- defs
CMoon.Defs.Abilities.C = {
    Id = "VoidPull",
    Cooldown = 8,
    RequireToggle_On = {"Q"},
    AbilityMod = Knit.Abilities.MeleeAttack:FindFirstChild("VoidPull", true),
}
]]--

function CMoon.C(params)
    params.CanRun = false
    --params = require(Knit.Abilities.MeleeAttack)[params.SystemStage](params, CMoon.Defs.Abilities.C)
end

--------------------------------------------------------------------------------------------------
--// Z //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
CMoon.Defs.Abilities.Z = {
    Id = "StandJump",
    Cooldown = 6,
    RequireToggle_On = {"Q"},
}

function CMoon.Z(params)
    params = require(Knit.Abilities.StandJump)[params.SystemStage](params, CMoon.Defs.Abilities.Z)
end

--------------------------------------------------------------------------------------------------
--// Mouse1 //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
CMoon.Defs.Abilities.Punch = {
    Name = "Punch",
    Id = "Punch",
    HitEffects = {Damage = {Damage = 15, KnockBack = 10,}}
}

function CMoon.Punch(params)

    local initPlayer = utils.GetPlayerByUserId(params.InitUserId)

    local organPunch = false
    local organToggle = initPlayer.Character:FindFirstChild("OrganInversion_Active", true)
    if organToggle then
        if organToggle.Value == true then
            organPunch = true
        end
    end

    if organPunch then
        params = require(Knit.Abilities.Punch_OrganInversion)[params.SystemStage](params, CMoon.Defs.Abilities.Punch)
    else
        params = require(Knit.Abilities.Punch)[params.SystemStage](params, CMoon.Defs.Abilities.Punch)
    end

end

return CMoon