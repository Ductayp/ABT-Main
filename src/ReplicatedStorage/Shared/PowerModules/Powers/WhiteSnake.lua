-- WhiteSnake

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

local WhiteSnake = {}

WhiteSnake.Defs = {
    PowerName = "White Snake",
    MaxXp = {
        [1] = 10000,
        [2] = 15000,
        [3] = 20000
    },
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
        Q = {
            AbilityName = "Summon Stand"
        },
        E = {
            AbilityName = "Barrage"
        },
        F = {
            AbilityName = "Acid Shot"
        },
        T = {
            AbilityName = "Stand Steal"
        },
        R = {
            AbilityName = "Burn Punch"
        },
        X = {
            AbilityName = "-"
        },
        Z = {
            AbilityName = "Stand Jump"
        },
        C = {
            AbilityName = "-"
        }
    }
}

--// SETUP - run this once when the stand is equipped
function WhiteSnake.SetupPower(initPlayer,params)
    Knit.Services.StateService:AddEntryToState(initPlayer, "WalkSpeed", "WhiteSnake_Setup", 2, nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Health", "WhiteSnake_Setup", WhiteSnake.Defs.HealthModifier[params.Rank], nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Multiplier_Damage", "WhiteSnake_Setup", WhiteSnake.Defs.DamageMultiplier[params.Rank], nil)
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
        Equip = ReplicatedStorage.Audio.Abilities.StandSummon,
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
    Duration = 10,
    Cooldown = 7,
    RequireToggle_On = {"Q"},
    HitEffects = {Damage = {Damage = 6}},
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
    Name = "Burn Punch",
    Id = "BurnPunch",
    Cooldown = 10,
    RequireToggle_On = {"Q"},
    HitEffects = {Damage = {Damage = 30}, PinCharacter = {Duration = 5.5}, AngeloRock = {Duration = 5}},
    Sounds = {
        Punch = ReplicatedStorage.Audio.StandSpecific.TheWorld.HeavyPunch,
    }
}

function WhiteSnake.BurnPunch(params)
    --params = require(Knit.Abilities.HeavyPunch)[params.SystemStage](params, WhiteSnake.Defs.Abilities.StonePunch)
end

--------------------------------------------------------------------------------------------------
--// Bullet Launch - T //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
WhiteSnake.Defs.Abilities.StandSteal = {
    Name = "Stand Steal",
    Id = "StandSteal",
    Cooldown = 6,
    RequireToggle_On = {"Q"},
    HitEffects = {Damage = {Damage = 8}},
}

function WhiteSnake.StandSteal(params)
    --params = require(Knit.Abilities.BulletBarrage)[params.SystemStage](params, WhiteSnake.Defs.Abilities.BulletBarrage)
end


--------------------------------------------------------------------------------------------------
--// Wall Blast - F //---------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
WhiteSnake.Defs.Abilities.AcidShot = {
    Name = "Acid Shot",
    Id = "AcidShot",
    RequireToggle_On = {"Q"},
    Cooldown = 6,
    Duration = 5,
    HitEffects = {Damage = {Damage = 20}, Blast = {}, KnockBack = {Force = 70, ForceY = 50}},
    RequireToggle_On = {"Q"},
}

function WhiteSnake.AcidShot(params)
    --params = require(Knit.Abilities.WallBlast)[params.SystemStage](params, WhiteSnake.Defs.Abilities.WallBlast)
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
    HitEffects = {Damage = {Damage = 5}}
}

function WhiteSnake.Punch(params)
    params = require(Knit.Abilities.Punch)[params.SystemStage](params, WhiteSnake.Defs.Abilities.Punch)
end

return WhiteSnake