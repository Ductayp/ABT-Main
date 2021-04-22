-- GoldExperience

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

local GoldExperience = {}

GoldExperience.Defs = {
    PowerName = "Gold Experience",
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
            AbilityName = "7 Page Muda"
        },
        T = {
            AbilityName = "Tree Cage"
        },
        R = {
            AbilityName = "Destabilizing Punch"
        },
        X = {
            AbilityName = "Life Heal"
        },
        Z = {
            AbilityName = "Stand Jump"
        },
        C = {
            AbilityName = "Bug Barrage"
        }
    }
}

--// SETUP - run this once when the stand is equipped
function GoldExperience.SetupPower(initPlayer,params)
    Knit.Services.StateService:AddEntryToState(initPlayer, "WalkSpeed", "GoldExperience_Setup", 2, nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Health", "GoldExperience_Setup", GoldExperience.Defs.HealthModifier[params.Rank], nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Multiplier_Damage", "GoldExperience_Setup", GoldExperience.Defs.DamageMultiplier[params.Rank], nil)
end

--// REMOVE - run this once when the stand is un-equipped
function GoldExperience.RemovePower(initPlayer,params)
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "WalkSpeed", "GoldExperience_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Health", "GoldExperience_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Multiplier_Damage", "GoldExperience_Setup")
end

--// MANAGER - this is the single point of entry from PowersService and PowersController.
function GoldExperience.Manager(params)

    -- call the function
    if params.InputId == "Q" then
        GoldExperience.EquipStand(params)
    elseif params.InputId == "E" then
        GoldExperience.Barrage(params)
    elseif params.InputId == "R" then
        GoldExperience.DestabilizingPunch(params)
    elseif params.InputId == "T" then
        GoldExperience.TreeCage(params)
    elseif params.InputId == "F" then
        GoldExperience.SevenPageMuda(params)
    elseif params.InputId == "X" then
        GoldExperience.LifeHeal(params)
    elseif params.InputId == "Z" then
        GoldExperience.StandJump(params)
    elseif params.InputId == "C" then
        GoldExperience.BugBarrage(params)
    elseif params.InputId == "Mouse1" then
        GoldExperience.Punch(params)
    end

    return params
end


--------------------------------------------------------------------------------------------------
--// EQUIP STAND - Q //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
GoldExperience.Defs.Abilities.EquipStand = {
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

function GoldExperience.EquipStand(params)
    params = require(Knit.Abilities.ManageStand)[params.SystemStage](params, GoldExperience.Defs.Abilities.EquipStand)
end

--------------------------------------------------------------------------------------------------
--// BARRAGE - E //----------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
GoldExperience.Defs.Abilities.Barrage = {
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

function GoldExperience.Barrage(params)
    params = require(Knit.Abilities.Barrage)[params.SystemStage](params, GoldExperience.Defs.Abilities.Barrage)
end

--------------------------------------------------------------------------------------------------
--// DestabilizingPunch - R//------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

--defs
GoldExperience.Defs.Abilities.DestabilizingPunch = {
    Name = "Destabilizing Punch",
    Id = "DestabilizingPunch",
    Cooldown = 10,
    RequireToggle_On = {"Q"},
    HitEffects = {Damage = {Damage = 30}, PinCharacter = {Duration = 5.5}, AngeloRock = {Duration = 5}},
    Sounds = {
        Punch = ReplicatedStorage.Audio.StandSpecific.TheWorld.HeavyPunch,
    }
}

function GoldExperience.DestabilizingPunch(params)
    --params = require(Knit.Abilities.HeavyPunch)[params.SystemStage](params, GoldExperience.Defs.Abilities.StonePunch)
end

--------------------------------------------------------------------------------------------------
--// TreeCage - T //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
GoldExperience.Defs.Abilities.TreeCage = {
    Name = "Tree Cage",
    Id = "TreeCage",
    Cooldown = 6,
    RequireToggle_On = {"Q"},
    HitEffects = {Damage = {Damage = 8}},
}

function GoldExperience.TreeCage(params)
    --params = require(Knit.Abilities.BulletBarrage)[params.SystemStage](params, GoldExperience.Defs.Abilities.BulletBarrage)
end


--------------------------------------------------------------------------------------------------
--// SevenPageMuda - F //---------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
GoldExperience.Defs.Abilities.SevenPageMuda = {
    Name = " 7 Page Muda",
    Id = "SevenPageMuda",
    RequireToggle_On = {"Q"},
    Cooldown = 6,
    Duration = 5,
    HitEffects = {Damage = {Damage = 20}, Blast = {}, KnockBack = {Force = 70, ForceY = 50}},
}

function GoldExperience.SevenPageMuda(params)
    --params = require(Knit.Abilities.WallBlast)[params.SystemStage](params, GoldExperience.Defs.Abilities.WallBlast)
end

--------------------------------------------------------------------------------------------------
--// LifeHeal - X //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
GoldExperience.Defs.Abilities.LifeHeal = {
    Name = "Life Heal",
    Id = "LifeHeal",
    RequireToggle_On = {"Q"},
    Cooldown = 90,
    Duration = 20,
    Multiplier = 2
}

function GoldExperience.LifeHeal(params)
    --params = require(Knit.Abilities.RageBoost)[params.SystemStage](params, GoldExperience.Defs.Abilities.RageBoost)
end

--------------------------------------------------------------------------------------------------
--// STAND JUMP - Z //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
GoldExperience.Defs.Abilities.StandJump = {
    Name = "Stand Jump",
    Id = "StandJump",
    Cooldown = 3,
    RequireToggle_On = {"Q"},
}

function GoldExperience.StandJump(params)
    params = require(Knit.Abilities.StandJump)[params.SystemStage](params, GoldExperience.Defs.Abilities.StandJump)
end

--------------------------------------------------------------------------------------------------
--// BugBarrage - C //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
GoldExperience.Defs.Abilities.BugBarrage = {
    Name = "Bug Barrage",
    Id = "BugBarrage",
    Cooldown = 3,
    RequireToggle_On = {"Q"},
}

function GoldExperience.BugBarrage(params)
    --params = require(Knit.Abilities.StandJump)[params.SystemStage](params, GoldExperience.Defs.Abilities.StandJump)
end

--------------------------------------------------------------------------------------------------
--// PUNCH - Mouse1 //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
GoldExperience.Defs.Abilities.Punch = {
    Name = "Punch",
    Id = "Punch",
    HitEffects = {Damage = {Damage = 5}}
}

function GoldExperience.Punch(params)
    params = require(Knit.Abilities.Punch)[params.SystemStage](params, GoldExperience.Defs.Abilities.Punch)
end

return GoldExperience