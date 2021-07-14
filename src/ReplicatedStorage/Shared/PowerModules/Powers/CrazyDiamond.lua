-- CrazyDiamond

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

local CrazyDiamond = {}

CrazyDiamond.Defs = {
    PowerName = "Crazy Diamond",
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
            F = {AbilityName = "Wall Blast"},
            T = {AbilityName = "Bullet Barrage"},
            R = {AbilityName = "Stone Punch"},
            X = {AbilityName = "Rage Boost"},
            Z = {AbilityName = "Stand Jump"},
            C = {AbilityName = "-"}
        },
        [2] = {
            Q = {AbilityName = "Summon Stand"},
            E = {AbilityName = "Barrage"},
            F = {AbilityName = "Wall Blast"},
            T = {AbilityName = "Bullet Barrage"},
            R = {AbilityName = "Stone Punch"},
            X = {AbilityName = "Rage Boost"},
            Z = {AbilityName = "Stand Jump"},
            C = {AbilityName = "-"}
        },
        [3] = {
            Q = {AbilityName = "Summon Stand"},
            E = {AbilityName = "Barrage"},
            F = {AbilityName = "Wall Blast"},
            T = {AbilityName = "Bullet Barrage"},
            R = {AbilityName = "Stone Punch"},
            X = {AbilityName = "Rage Boost"},
            Z = {AbilityName = "Stand Jump"},
            C = {AbilityName = "-"}
        },
    }
}

--// SETUP - run this once when the stand is equipped
function CrazyDiamond.SetupPower(initPlayer,params)
    Knit.Services.StateService:AddEntryToState(initPlayer, "WalkSpeed", "CrazyDiamond_Setup", 2, nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Health", "CrazyDiamond_Setup", CrazyDiamond.Defs.HealthModifier[params.Rank], nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Multiplier_Damage", "CrazyDiamond_Setup", CrazyDiamond.Defs.DamageMultiplier[params.Rank], nil)

    -- force cooldown on all abilities
    --local cooldownKeys = {"Q", "E", "R", "T", "F", "Z", "X", "C"}
    local cooldownKeys = {"E", "R", "T", "F", "Z", "X", "C"}
    for _, key in pairs(cooldownKeys) do
        require(Knit.PowerUtils.Cooldown).Server_SetCooldown(initPlayer.UserId, key, 15)
    end

end

--// REMOVE - run this once when the stand is un-equipped
function CrazyDiamond.RemovePower(initPlayer,params)
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "WalkSpeed", "CrazyDiamond_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Health", "CrazyDiamond_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Multiplier_Damage", "CrazyDiamond_Setup")
end

--// MANAGER - this is the single point of entry from PowersService and PowersController.
function CrazyDiamond.Manager(params)

    -- call the function
    if params.InputId == "Q" then
        CrazyDiamond.EquipStand(params)
    elseif params.InputId == "E" then
        CrazyDiamond.Barrage(params)
    elseif params.InputId == "R" then
        CrazyDiamond.StonePunch(params)
    elseif params.InputId == "T" then
        CrazyDiamond.BulletBarrage(params)
    elseif params.InputId == "F" then
        CrazyDiamond.WallBlast(params)
    elseif params.InputId == "X" then
        CrazyDiamond.RageBoost(params)
    elseif params.InputId == "Z" then
        CrazyDiamond.StandJump(params)
    elseif params.InputId == "Mouse1" then
        CrazyDiamond.Punch(params)
    end

    return params
end

--------------------------------------------------------------------------------------------------
--// EQUIP STAND - Q //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
CrazyDiamond.Defs.Abilities.EquipStand = {
    Name = "Equip Stand",
    Id = "EquipStand",
    Cooldown = 5,
    StandModels = {
        [1] = ReplicatedStorage.EffectParts.StandModels.CrazyDiamond_1,
        [2] = ReplicatedStorage.EffectParts.StandModels.CrazyDiamond_2,
        [3] = ReplicatedStorage.EffectParts.StandModels.CrazyDiamond_3,
    },
    Sounds = {
        Equip = ReplicatedStorage.Audio.Abilities.StandSummon,
        Remove =  ReplicatedStorage.Audio.Abilities.StandSummon,
    }
}

function CrazyDiamond.EquipStand(params)
    params = require(Knit.Abilities.ManageStand)[params.SystemStage](params, CrazyDiamond.Defs.Abilities.EquipStand)
end

--------------------------------------------------------------------------------------------------
--// BARRAGE - E //----------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
CrazyDiamond.Defs.Abilities.Barrage = {
    Name = "Barrage",
    Id = "Barrage",
    Duration = 4,
    Cooldown = 7,
    RequireToggle_On = {"Q"},
    HitEffects = {Damage = {Damage = 3, KnockBack = 10}},
    Sounds = {
        --Barrage = ReplicatedStorage.Audio.Abilities.GenericBarrage,
        Barrage = ReplicatedStorage.Audio.StandSpecific.CrazyDiamond.DoraBarrage

    }
}

function CrazyDiamond.Barrage(params)
    params = require(Knit.Abilities.Barrage)[params.SystemStage](params, CrazyDiamond.Defs.Abilities.Barrage)
end

--------------------------------------------------------------------------------------------------
--// Stone Punch - R//------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

--defs
CrazyDiamond.Defs.Abilities.StonePunch = {
    Id = "StonePunch",
    Cooldown = 10,
    RequireToggle_On = {"Q"},
    AbilityMod = Knit.Abilities.MeleeAttack:FindFirstChild("StonePunch", true),
}

function CrazyDiamond.StonePunch(params)
    params = require(Knit.Abilities.MeleeAttack)[params.SystemStage](params, CrazyDiamond.Defs.Abilities.StonePunch)
end

--------------------------------------------------------------------------------------------------
--// Bullet Launch - T //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
CrazyDiamond.Defs.Abilities.BulletBarrage = {
    Name = "Bullet Barrage",
    Id = "BulletBarrage",
    Cooldown = 4,
    RequireToggle_On = {"Q"},
    HitEffects = {Damage = {Damage = 10}},
    --AbilityMod = Knit.Abilities.BasicProjectile.BulletBarrage,
}

function CrazyDiamond.BulletBarrage(params)
    params = require(Knit.Abilities.BulletBarrage)[params.SystemStage](params, CrazyDiamond.Defs.Abilities.BulletBarrage)
end


--------------------------------------------------------------------------------------------------
--// Wall Blast - F //---------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
CrazyDiamond.Defs.Abilities.WallBlast = {
    Name = "Wall Blast",
    Id = "WallBlast",
    RequireToggle_On = {"Q"},
    Cooldown = 6,
    Duration = 3,
    HitEffects = {Damage = {Damage = 30}, Blast = {}, KnockBack = {Force = 70, ForceY = 50}},
}

function CrazyDiamond.WallBlast(params)
    params = require(Knit.Abilities.WallBlast)[params.SystemStage](params, CrazyDiamond.Defs.Abilities.WallBlast)
end


--------------------------------------------------------------------------------------------------
--// Rage Boost - X //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
CrazyDiamond.Defs.Abilities.RageBoost = {
    Name = "Rage Boost",
    Id = "RageBoost",
    RequireToggle_On = {"Q"},
    Cooldown = 90,
    Duration = 20,
    Multiplier = 2
}

function CrazyDiamond.RageBoost(params)
    params = require(Knit.Abilities.RageBoost)[params.SystemStage](params, CrazyDiamond.Defs.Abilities.RageBoost)
end

--------------------------------------------------------------------------------------------------
--// STAND JUMP - Z //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
CrazyDiamond.Defs.Abilities.StandJump = {
    Name = "Stand Jump",
    Id = "StandJump",
    Cooldown = 3,
    RequireToggle_On = {"Q"},
}

function CrazyDiamond.StandJump(params)
    params = require(Knit.Abilities.StandJump)[params.SystemStage](params, CrazyDiamond.Defs.Abilities.StandJump)
end

--------------------------------------------------------------------------------------------------
--// PUNCH - Mouse1 //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
CrazyDiamond.Defs.Abilities.Punch = {
    Name = "Punch",
    Id = "Punch",
    HitEffects = {Damage = {Damage = 5, KnockBack = 10}}
}

function CrazyDiamond.Punch(params)
    params = require(Knit.Abilities.Punch)[params.SystemStage](params, CrazyDiamond.Defs.Abilities.Punch)
end

return CrazyDiamond