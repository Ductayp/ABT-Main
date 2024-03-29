-- VampiricTheWorld

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

local VampiricTheWorld = {}

VampiricTheWorld.Defs = {
    PowerName = "Vampiric The World",
    MaxXp = 15000,
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
    Abilities = {}, -- ability defs are inside each ability function area
        KeyMap = {
            [1] = {
                Q = {AbilityName = "Summon Stand"},
                E = {AbilityName = "Barrage"},
                F = {AbilityName = "Blood Knives"},
                T = {AbilityName = "Time Freeze"},
                R = {AbilityName = "Wither Punch"},
                X = {AbilityName = "Perfect Lasers"},
                Z = {AbilityName = "Stand Jump"},
                C = {AbilityName = "-"}
            },
            [2] = {
                Q = {AbilityName = "Summon Stand"},
                E = {AbilityName = "Barrage"},
                F = {AbilityName = "Blood Knives"},
                T = {AbilityName = "Time Freeze"},
                R = {AbilityName = "Wither Punch"},
                X = {AbilityName = "Perfect Lasers"},
                Z = {AbilityName = "Stand Jump"},
                C = {AbilityName = "-"}
            },
            [3] = {
                Q = {AbilityName = "Summon Stand"},
                E = {AbilityName = "Barrage"},
                F = {AbilityName = "Blood Knives"},
                T = {AbilityName = "Time Freeze"},
                R = {AbilityName = "Wither Punch"},
                X = {AbilityName = "Perfect Lasers"},
                Z = {AbilityName = "Stand Jump"},
                C = {AbilityName = "-"}
            },

        }
}

--// SETUP - run this once when the stand is equipped
function VampiricTheWorld.SetupPower(initPlayer,params)
    Knit.Services.StateService:AddEntryToState(initPlayer, "WalkSpeed", "VampiricTheWorld_Setup", 2, nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Immunity", "VampiricTheWorld_Setup", 2, {TimeStop = true})
    Knit.Services.StateService:AddEntryToState(initPlayer, "Health", "VampiricTheWorld_Setup", VampiricTheWorld.Defs.HealthModifier[params.Rank], nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Multiplier_Damage", "VampiricTheWorld_Setup", VampiricTheWorld.Defs.DamageMultiplier[params.Rank], nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "HealthTick", "VampiricTheWorld_Setup", true, {Day = -1, Night = 1})

    -- force cooldown on all abilities
    --local cooldownKeys = {"Q", "E", "R", "T", "F", "Z", "X", "C"}
    local cooldownKeys = {"E", "R", "T", "F", "Z", "X", "C"}
    for _, key in pairs(cooldownKeys) do
        require(Knit.PowerUtils.Cooldown).Server_SetCooldown(initPlayer.UserId, key, 15)
    end

end

--// REMOVE - run this once when the stand is un-equipped
function VampiricTheWorld.RemovePower(initPlayer,params)
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "WalkSpeed", "VampiricTheWorld_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Immunity", "VampiricTheWorld_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Health", "VampiricTheWorld_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Multiplier_Damage", "VampiricTheWorld_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "HealthTick", "VampiricTheWorld_Setup")
end

--// MANAGER - this is the single point of entry from PowersService and PowersController.
function VampiricTheWorld.Manager(params)

    if params.InputId == "Mouse1" then
        VampiricTheWorld.Punch(params)
    else
        VampiricTheWorld[params.InputId](params)
    end

    return params
end

--------------------------------------------------------------------------------------------------
--// Q //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
VampiricTheWorld.Defs.Abilities.Q = {
    Name = "Equip Stand",
    Id = "EquipStand",
    Cooldown = 5,
    StandModels = {
        [1] = ReplicatedStorage.EffectParts.StandModels.VampiricTheWorld_1,
        [2] = ReplicatedStorage.EffectParts.StandModels.VampiricTheWorld_2,
        [3] = ReplicatedStorage.EffectParts.StandModels.VampiricTheWorld_3,
    },
    Sounds = {
        Equip = ReplicatedStorage.Audio.StandSpecific.TheWorld.Summon,
        Remove =  ReplicatedStorage.Audio.Abilities.StandSummon,
    }
}

function VampiricTheWorld.Q(params)
    params = require(Knit.Abilities.ManageStand)[params.SystemStage](params, VampiricTheWorld.Defs.Abilities.Q)
end

--------------------------------------------------------------------------------------------------
--// E //----------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
VampiricTheWorld.Defs.Abilities.E = {
    Id = "Barrage",
    Duration = 4,
    Cooldown = 4,
    RequireToggle_On = {"Q"},
    HitEffects = {Damage = {Damage = 7, KnockBack = 15}},
    Sounds = {
        Barrage = ReplicatedStorage.Audio.StandSpecific.TheWorld.Barrage,
    }
}

function VampiricTheWorld.E(params)
    params = require(Knit.Abilities.Barrage)[params.SystemStage](params, VampiricTheWorld.Defs.Abilities.E)
end

--------------------------------------------------------------------------------------------------
--// R //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

--defs
VampiricTheWorld.Defs.Abilities.R = {
    Id = "WitherPunch",
    Cooldown = 12,
    RequireToggle_On = {"Q"},
    AbilityMod = Knit.Abilities.HeavyPunch:FindFirstChild("WitherPunch", true),
}

function VampiricTheWorld.R(params)
    params = require(Knit.Abilities.HeavyPunch)[params.SystemStage](params, VampiricTheWorld.Defs.Abilities.R)
end

--------------------------------------------------------------------------------------------------
--// T //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
VampiricTheWorld.Defs.Abilities.T = {
    Id = "TimeFreeze",
    Cooldown = 60,
    RequireToggle_On = {"Q"},
    AbilityMod = Knit.Abilities.BasicAbility:FindFirstChild("TimeFreeze", true),
}

function VampiricTheWorld.T(params)
    params = require(Knit.Abilities.BasicAbility)[params.SystemStage](params, VampiricTheWorld.Defs.Abilities.T)
end


--------------------------------------------------------------------------------------------------
--// F //---------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
VampiricTheWorld.Defs.Abilities.F = {
    Id = "BloodKnives",
    Cooldown = 6,
    RequireToggle_On = {"Q"},
    AbilityMod = Knit.Abilities.ProjectileBarrage:FindFirstChild("BloodKnives", true),
}

function VampiricTheWorld.F(params)
    params = require(Knit.Abilities.ProjectileBarrage)[params.SystemStage](params, VampiricTheWorld.Defs.Abilities.F)
end


--------------------------------------------------------------------------------------------------
--// X //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
VampiricTheWorld.Defs.Abilities.X = {
    Id = "PerfecLasers",
    Cooldown = 20,
    RequireToggle_On = {"Q"},
    AbilityMod = Knit.Abilities.BasicAbility:FindFirstChild("PerfectLasers", true),
}

function VampiricTheWorld.X(params)
    params = require(Knit.Abilities.BasicAbility)[params.SystemStage](params, VampiricTheWorld.Defs.Abilities.X)
end

--------------------------------------------------------------------------------------------------
--// C //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

--[[
-- defs
VampiricTheWorld.Defs.Abilities.C = {
    Id = "VoidPull",
    Cooldown = 8,
    RequireToggle_On = {"Q"},
    AbilityMod = Knit.Abilities.HeavyPunch:FindFirstChild("VoidPull", true),
}
]]--

function VampiricTheWorld.C(params)
    params.CanRun = false
    --params = require(Knit.Abilities.HeavyPunch)[params.SystemStage](params, VampiricTheWorld.Defs.Abilities.C)
end


--------------------------------------------------------------------------------------------------
--// Z //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
VampiricTheWorld.Defs.Abilities.Z = {
    Id = "StandJump",
    Cooldown = 6,
    RequireToggle_On = {"Q"},
}

function VampiricTheWorld.Z(params)
    params = require(Knit.Abilities.StandJump)[params.SystemStage](params, VampiricTheWorld.Defs.Abilities.Z)
end

--------------------------------------------------------------------------------------------------
--// Mouse1 //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
VampiricTheWorld.Defs.Abilities.Punch = {
    Name = "Punch",
    Id = "Punch",
    HitEffects = {Damage = {Damage = 10, KnockBack = 10,}, LifeSteal = {Quantity = 8}}
}

function VampiricTheWorld.Punch(params)
    params = require(Knit.Abilities.Punch)[params.SystemStage](params, VampiricTheWorld.Defs.Abilities.Punch)
end

return VampiricTheWorld