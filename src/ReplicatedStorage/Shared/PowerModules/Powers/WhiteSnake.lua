-- WhiteSnake

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

local WhiteSnake = {}

WhiteSnake.Defs = {
    PowerName = "White Snake",
    MaxXp = 30000,
    DamageMultiplier = {
        [1] = 1,
        [2] = 1.5,
        [3] = 2,
    },
    HealthModifier = {
        [1] = 10,
        [2] = 30,
        [3] = 70
    },
    Abilities = {}, -- ability defs are inside each ability function area
    KeyMap = {
        [1] = {
            Q = {AbilityName = "Summon Stand"},
            E = {AbilityName = "Barrage"},
            F = {AbilityName = "Acid Shot"},
            T = {AbilityName = "Stand Steal"},
            R = {AbilityName = "Burn Punch"},
            X = {AbilityName = "-"},
            Z = {AbilityName = "Stand Jump"},
            C = {AbilityName = "-"}
        },
        [2] = {
            Q = {AbilityName = "Summon Stand"},
            E = {AbilityName = "Barrage"},
            F = {AbilityName = "Acid Shot"},
            T = {AbilityName = "Stand Steal"},
            R = {AbilityName = "Burn Punch"},
            X = {AbilityName = "-"},
            Z = {AbilityName = "Stand Jump"},
            C = {AbilityName = "-"}
        },
        [3] = {
            Q = {AbilityName = "Summon Stand"},
            E = {AbilityName = "Barrage"},
            F = {AbilityName = "Acid Shot"},
            T = {AbilityName = "Stand Steal"},
            R = {AbilityName = "Burn Punch"},
            X = {AbilityName = "-"},
            Z = {AbilityName = "Stand Jump"},
            C = {AbilityName = "-"}
        },
    }
}

--// SETUP - run this once when the stand is equipped
function WhiteSnake.SetupPower(initPlayer,params)
    Knit.Services.StateService:AddEntryToState(initPlayer, "WalkSpeed", "WhiteSnake_Setup", 2, nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Health", "WhiteSnake_Setup", WhiteSnake.Defs.HealthModifier[params.Rank], nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Multiplier_Damage", "WhiteSnake_Setup", WhiteSnake.Defs.DamageMultiplier[params.Rank], nil)

    -- force cooldown on all abilities
    --local cooldownKeys = {"Q", "E", "R", "T", "F", "Z", "X", "C"}
    local cooldownKeys = {"E", "R", "T", "F", "Z", "X", "C"}
    for _, key in pairs(cooldownKeys) do
        require(Knit.PowerUtils.Cooldown).Server_SetCooldown(initPlayer.UserId, key, 15)
    end
end

--// REMOVE - run this once when the stand is un-equipped
function WhiteSnake.RemovePower(initPlayer,params)
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "WalkSpeed", "WhiteSnake_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Health", "WhiteSnake_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Multiplier_Damage", "WhiteSnake_Setup")
end

--// MANAGER - this is the single point of entry from PowersService and PowersController.
function WhiteSnake.Manager(params)

    -- call the function
    if params.InputId == "Q" then
        WhiteSnake.EquipStand(params)
    elseif params.InputId == "E" then
        WhiteSnake.Barrage(params)
    elseif params.InputId == "R" then
        WhiteSnake.BurnPunch(params)
    elseif params.InputId == "T" then
        WhiteSnake.StandSteal(params)
    elseif params.InputId == "F" then
        WhiteSnake.AcidShot(params)
    elseif params.InputId == "X" then
        -- none
    elseif params.InputId == "Z" then
        WhiteSnake.StandJump(params)
    elseif params.InputId == "Mouse1" then
        WhiteSnake.Punch(params)
    end


    return params
end


--------------------------------------------------------------------------------------------------
--// EQUIP STAND - Q //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
WhiteSnake.Defs.Abilities.EquipStand = {
    Name = "Equip Stand",
    Id = "EquipStand",
    Cooldown = 5,
    StandModels = {
        [1] = ReplicatedStorage.EffectParts.StandModels.WhiteSnake_1,
        [2] = ReplicatedStorage.EffectParts.StandModels.WhiteSnake_2,
        [3] = ReplicatedStorage.EffectParts.StandModels.WhiteSnake_3,
    },
    Sounds = {
        Equip = ReplicatedStorage.Audio.StandSpecific.WhiteSnake.Summon,
        Remove =  ReplicatedStorage.Audio.Abilities.StandSummon,
    }
}

function WhiteSnake.EquipStand(params)
    params = require(Knit.Abilities.ManageStand)[params.SystemStage](params, WhiteSnake.Defs.Abilities.EquipStand)
end

--------------------------------------------------------------------------------------------------
--// BARRAGE - E //----------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
WhiteSnake.Defs.Abilities.Barrage = {
    Name = "Barrage",
    Id = "Barrage",
    Duration = 8,
    Cooldown = 6,
    RequireToggle_On = {"Q"},
    HitEffects = {Damage = {Damage = 3, KnockBack = 10}},
    Sounds = {
        Barrage = ReplicatedStorage.Audio.Abilities.GenericBarrage,
    }
}

function WhiteSnake.Barrage(params)
    params = require(Knit.Abilities.Barrage)[params.SystemStage](params, WhiteSnake.Defs.Abilities.Barrage)
end

--------------------------------------------------------------------------------------------------
--// Burn Punch - R//------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

--defs
WhiteSnake.Defs.Abilities.BurnPunch = {
    Id = "BurnPunch",
    Cooldown = 6,
    RequireToggle_On = {"Q"},
    AbilityMod = Knit.Abilities.MeleeAttack:FindFirstChild("BurnPunch", true),
}

function WhiteSnake.BurnPunch(params)
    params = require(Knit.Abilities.MeleeAttack)[params.SystemStage](params, WhiteSnake.Defs.Abilities.BurnPunch)
end

--------------------------------------------------------------------------------------------------
--// Bullet Launch - T //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
WhiteSnake.Defs.Abilities.StandSteal = {
    Name = "Stand Steal",
    Id = "StandSteal",
    Cooldown = 15,
    RequireToggle_On = {"Q"},
    AbilityMod = Knit.Abilities.RadiusAttack_OLD.StandSteal
}

function WhiteSnake.StandSteal(params)
    params = require(Knit.Abilities.RadiusAttack_OLD)[params.SystemStage](params, WhiteSnake.Defs.Abilities.StandSteal)
end


--------------------------------------------------------------------------------------------------
--// Wall Blast - F //---------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
WhiteSnake.Defs.Abilities.AcidShot = {
    Name = "Acid Shot",
    Id = "AcidShot",
    RequireToggle_On = {"Q"},
    Cooldown = 8,
    AbilityMod = Knit.Abilities.BasicProjectile.AcidShot
}

function WhiteSnake.AcidShot(params)
    params = require(Knit.Abilities.BasicProjectile)[params.SystemStage](params, WhiteSnake.Defs.Abilities.AcidShot)
end

--------------------------------------------------------------------------------------------------
--// STAND JUMP - Z //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
WhiteSnake.Defs.Abilities.StandJump = {
    Name = "Stand Jump",
    Id = "StandJump",
    Cooldown = 3,
    RequireToggle_On = {"Q"},
}

function WhiteSnake.StandJump(params)
    params = require(Knit.Abilities.StandJump)[params.SystemStage](params, WhiteSnake.Defs.Abilities.StandJump)
end

--------------------------------------------------------------------------------------------------
--// PUNCH - Mouse1 //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
WhiteSnake.Defs.Abilities.Punch = {
    Name = "Punch",
    Id = "Punch",
    HitEffects = {Damage = {Damage = 5, KnockBack = 20}}
}

function WhiteSnake.Punch(params)
    params = require(Knit.Abilities.Punch)[params.SystemStage](params, WhiteSnake.Defs.Abilities.Punch)
end

return WhiteSnake