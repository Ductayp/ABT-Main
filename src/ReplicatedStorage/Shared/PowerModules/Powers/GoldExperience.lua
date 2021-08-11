-- GoldExperience

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

local GoldExperience = {}

GoldExperience.Defs = {
    PowerName = "Gold Experience",
    MaxXp = 30000,
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
            E = {AbilityName = "Beatdown Barrage"},
            F = {AbilityName = "Bug Barrage"},
            T = {AbilityName = "7 Page Muda" },
            R = {AbilityName = "Soul Punch"},
            X = {AbilityName = "Life Heal"},
            Z = {AbilityName = "Stand Jump"},
            C = {AbilityName = "-"}
        },
        [2] = {
            Q = {AbilityName = "Summon Stand"},
            E = {AbilityName = "Beatdown Barrage"},
            F = {AbilityName = "Bug Barrage"},
            T = {AbilityName = "7 Page Muda" },
            R = {AbilityName = "Soul Punch"},
            X = {AbilityName = "Life Heal"},
            Z = {AbilityName = "Stand Jump"},
            C = {AbilityName = "-"}
        },
        [3] = {
            Q = {AbilityName = "Summon Stand"},
            E = {AbilityName = "Beatdown Barrage"},
            F = {AbilityName = "Bug Barrage"},
            T = {AbilityName = "7 Page Muda" },
            R = {AbilityName = "Soul Punch"},
            X = {AbilityName = "Life Heal"},
            Z = {AbilityName = "Stand Jump"},
            C = {AbilityName = "-"}
        },

    },
    Abilities = {}, -- ability defs are inside each ability function area
}

--// SETUP - run this once when the stand is equipped
function GoldExperience.SetupPower(initPlayer, params)
    Knit.Services.StateService:AddEntryToState(initPlayer, "WalkSpeed", "GoldExperience_Setup", 6, nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Health", "GoldExperience_Setup", GoldExperience.Defs.HealthModifier[params.Rank], nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Multiplier_Damage", "GoldExperience_Setup", GoldExperience.Defs.DamageMultiplier[params.Rank], nil)
end

--// REMOVE - run this once when the stand is un-equipped
function GoldExperience.RemovePower(initPlayer, params)
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "WalkSpeed", "GoldExperience_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Health", "GoldExperience_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Multiplier_Damage", "GoldExperience_Setup")
end

--// MANAGER - this is the single point of entry from PowersService and PowersController.
function GoldExperience.Manager(params)

    if params.InputId == "Mouse1" then
        GoldExperience.Punch(params)
    else
        GoldExperience[params.InputId](params)
    end

    return params
end

--------------------------------------------------------------------------------------------------
--// Q //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
GoldExperience.Defs.Abilities.Q = {
    Name = "Equip Stand",
    Id = "EquipStand",
    Cooldown = 5,
    StandModels = {
        [1] = ReplicatedStorage.EffectParts.StandModels.GoldExperience_1,
        [2] = ReplicatedStorage.EffectParts.StandModels.GoldExperience_2,
        [3] = ReplicatedStorage.EffectParts.StandModels.GoldExperience_3,
    },
    Sounds = {
        Equip = ReplicatedStorage.Audio.Abilities.StandSummon,
        Remove =  ReplicatedStorage.Audio.Abilities.StandSummon,
    }
}

function GoldExperience.Q(params)
    params = require(Knit.Abilities.ManageStand)[params.SystemStage](params, GoldExperience.Defs.Abilities.Q)
end

--------------------------------------------------------------------------------------------------
--// E //----------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
GoldExperience.Defs.Abilities.E = {
    Id = "Barrage",
    Duration = 7,
    Cooldown = 7,
    RequireToggle_On = {"Q"},
    DamageRamp = .25,
    HitEffects = {Damage = {Damage = 3, KnockBack = 15}},
    Sounds = {
        Barrage = ReplicatedStorage.Audio.StandSpecific.GoldExperience.Barrage,
    }
}

function GoldExperience.E(params)
    params = require(Knit.Abilities.Barrage)[params.SystemStage](params, GoldExperience.Defs.Abilities.E)
end

--------------------------------------------------------------------------------------------------
--// R //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

--defs
GoldExperience.Defs.Abilities.R = {
    Id = "SoulPunch",
    Cooldown = 12,
    RequireToggle_On = {"Q"},
    AbilityMod = Knit.Abilities.HeavyPunch:FindFirstChild("SoulPunch", true),
}

function GoldExperience.R(params)
    params = require(Knit.Abilities.HeavyPunch)[params.SystemStage](params, GoldExperience.Defs.Abilities.R)
end

--------------------------------------------------------------------------------------------------
--// T //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
GoldExperience.Defs.Abilities.T = {
    Id = "SevenPageMuda",
    Cooldown = 30,
    RequireToggle_On = {"Q"},
    AbilityMod = Knit.Abilities.BasicAbility:FindFirstChild("SevenPageMuda", true),
}

function GoldExperience.T(params)
    params = require(Knit.Abilities.BasicAbility)[params.SystemStage](params, GoldExperience.Defs.Abilities.T)
end


--------------------------------------------------------------------------------------------------
--// F //---------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
GoldExperience.Defs.Abilities.F = {
    Id = "BugBarrage",
    Cooldown = 6,
    RequireToggle_On = {"Q"},
    AbilityMod = Knit.Abilities.ProjectileBarrage:FindFirstChild("BugBarrage", true),
}

function GoldExperience.F(params)
    params = require(Knit.Abilities.ProjectileBarrage)[params.SystemStage](params, GoldExperience.Defs.Abilities.F)
end


--------------------------------------------------------------------------------------------------
--// X //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
GoldExperience.Defs.Abilities.X = {
    Id = "LifeHeal",
    Cooldown = 15,
    RequireToggle_On = {"Q"},
    AbilityMod = Knit.Abilities.BasicAbility:FindFirstChild("LifeHeal", true),
}

function GoldExperience.X(params)
    params = require(Knit.Abilities.BasicAbility)[params.SystemStage](params, GoldExperience.Defs.Abilities.X)
end

--------------------------------------------------------------------------------------------------
--// C //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

--[[
-- defs
GoldExperience.Defs.Abilities.C = {
    Id = "VoidPull",
    Cooldown = 8,
    RequireToggle_On = {"Q"},
    AbilityMod = Knit.Abilities.MeleeAttack:FindFirstChild("VoidPull", true),
}
]]--

function GoldExperience.C(params)
    params.CanRun = false
    --params = require(Knit.Abilities.MeleeAttack)[params.SystemStage](params, GoldExperience.Defs.Abilities.C)
end

--------------------------------------------------------------------------------------------------
--// Z //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
GoldExperience.Defs.Abilities.Z = {
    Id = "StandJump",
    Cooldown = 6,
    RequireToggle_On = {"Q"},
}

function GoldExperience.Z(params)
    params = require(Knit.Abilities.StandJump)[params.SystemStage](params, GoldExperience.Defs.Abilities.Z)
end

--------------------------------------------------------------------------------------------------
--// Mouse1 //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
GoldExperience.Defs.Abilities.Punch = {
    Name = "Punch",
    Id = "Punch",
    HitEffects = {Damage = {Damage = 15, KnockBack = 10,}}
}

function GoldExperience.Punch(params)
    params = require(Knit.Abilities.Punch)[params.SystemStage](params, GoldExperience.Defs.Abilities.Punch)
end

return GoldExperience


