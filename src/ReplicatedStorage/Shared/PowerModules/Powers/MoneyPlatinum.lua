-- MoneyPlatinum

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

local MoneyPlatinum = {}

MoneyPlatinum.Defs = {
    PowerName = "Money Platinum",
    MaxXp = 10000,
    DamageMultiplier = {
        [1] = 1,
        [2] = 1.5,
        [3] = 2,
    },
    HealthModifier = {
        [1] = 999,
        [2] = 999,
        [3] = 999,
    },
    Abilities = {}, -- ability defs are inside each ability function area
    KeyMap = {
        [1] = {
            Q = {AbilityName = "Summon Stand"},
            E = {AbilityName = "Barrage"},
            F = {AbilityName = "YEET"},
            T = {AbilityName = "Sub 2 Planet Milo"},
            R = {AbilityName = "TROLL"},
            X = {AbilityName = "ABT"},
            Z = {AbilityName = "Stand Jump"},
            C = {AbilityName = "<3"}
        },
        [2] = {
            Q = {AbilityName = "Summon Stand"},
            E = {AbilityName = "Barrage"},
            F = {AbilityName = "YEET"},
            T = {AbilityName = "Sub 2 Planet Milo"},
            R = {AbilityName = "TROLL"},
            X = {AbilityName = "ABT"},
            Z = {AbilityName = "Stand Jump"},
            C = {AbilityName = "<3"}
        },
        [3] = {
            Q = {AbilityName = "Summon Stand"},
            E = {AbilityName = "Barrage"},
            F = {AbilityName = "YEET"},
            T = {AbilityName = "Sub 2 Planet Milo"},
            R = {AbilityName = "TROLL"},
            X = {AbilityName = "ABT"},
            Z = {AbilityName = "Stand Jump"},
            C = {AbilityName = "<3"}
        },
    }
}

--// SETUP - run this once when the stand is equipped
function MoneyPlatinum.SetupPower(initPlayer,params)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Immunity", "MoneyPlatinum_Setup", 2, {TimeStop = true})
    Knit.Services.StateService:AddEntryToState(initPlayer, "WalkSpeed", "MoneyPlatinum_Setup", 15, nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Health", "MoneyPlatinum_Setup", MoneyPlatinum.Defs.HealthModifier[params.Rank], nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Multiplier_Damage", "MoneyPlatinum_Setup", MoneyPlatinum.Defs.DamageMultiplier[params.Rank], nil)
end

--// REMOVE - run this once when the stand is un-equipped
function MoneyPlatinum.RemovePower(initPlayer,params)
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Immunity", "MoneyPlatinum_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "WalkSpeed", "MoneyPlatinum_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Health", "MoneyPlatinum_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Multiplier_Damage", "MoneyPlatinum_Setup")
end

--// MANAGER - this is the single point of entry from PowersService and PowersController.
function MoneyPlatinum.Manager(params)

    -- call the function
    if params.InputId == "Q" then
        MoneyPlatinum.EquipStand(params)
    elseif params.InputId == "E" then
        MoneyPlatinum.Barrage(params)
    elseif params.InputId == "R" then
        MoneyPlatinum.DestabilizingPunch(params)
    elseif params.InputId == "T" then
        MoneyPlatinum.TreeCage(params)
    elseif params.InputId == "F" then
        MoneyPlatinum.SevenPageMuda(params)
    elseif params.InputId == "X" then
        MoneyPlatinum.LifeHeal(params)
    elseif params.InputId == "Z" then
        MoneyPlatinum.StandJump(params)
    elseif params.InputId == "C" then
        MoneyPlatinum.BugBarrage(params)
    elseif params.InputId == "Mouse1" then
        MoneyPlatinum.Punch(params)
    end

    return params
end


--------------------------------------------------------------------------------------------------
--// EQUIP STAND - Q //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
MoneyPlatinum.Defs.Abilities.EquipStand = {
    Name = "Equip Stand",
    Id = "EquipStand",
    Cooldown = 5,
    StandModels = {
        [1] = ReplicatedStorage.EffectParts.StandModels.MoneyPlatinum_1,
        [2] = ReplicatedStorage.EffectParts.StandModels.MoneyPlatinum_1,
        [3] = ReplicatedStorage.EffectParts.StandModels.MoneyPlatinum_1,
    },
    Sounds = {
        Equip = ReplicatedStorage.Audio.Abilities.StandSummon,
        Remove =  ReplicatedStorage.Audio.Abilities.StandSummon,
    }
}

function MoneyPlatinum.EquipStand(params)
    params = require(Knit.Abilities.ManageStand)[params.SystemStage](params, MoneyPlatinum.Defs.Abilities.EquipStand)
end

--------------------------------------------------------------------------------------------------
--// BARRAGE - E //----------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
MoneyPlatinum.Defs.Abilities.Barrage = {
    Name = "Barrage",
    Id = "Barrage",
    Duration = 999,
    Cooldown = 1,
    RequireToggle_On = {"Q"},
    HitEffects = {Damage = {Damage = 999999}},
    Sounds = {
        Barrage = ReplicatedStorage.Audio.Abilities.GenericBarrage,
    }
}

function MoneyPlatinum.Barrage(params)
    params = require(Knit.Abilities.Barrage)[params.SystemStage](params, MoneyPlatinum.Defs.Abilities.Barrage)
end

--------------------------------------------------------------------------------------------------
--// DestabilizingPunch - R//------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

--defs
MoneyPlatinum.Defs.Abilities.DestabilizingPunch = {
    Name = "Destabilizing Punch",
    Id = "DestabilizingPunch",
    Cooldown = 10,
    RequireToggle_On = {"Q"},
    HitEffects = {Damage = {Damage = 5}, Burn = {TickTime = 1, TickCount = 15, Damage = 10, Color = "Orange"}},
    Sounds = {
        Punch = ReplicatedStorage.Audio.StandSpecific.TheWorld.HeavyPunch,
    }
}

function MoneyPlatinum.DestabilizingPunch(params)
    params = require(Knit.Abilities.HeavyPunch)[params.SystemStage](params, MoneyPlatinum.Defs.Abilities.DestabilizingPunch)
end

--------------------------------------------------------------------------------------------------
--// TreeCage - T //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
MoneyPlatinum.Defs.Abilities.TreeCage = {
    Name = "Tree Cage",
    Id = "TreeCage",
    Cooldown = 6,
    RequireToggle_On = {"Q"},
    HitEffects = {Damage = {Damage = 8}},
}

function MoneyPlatinum.TreeCage(params)
    --params = require(Knit.Abilities.BulletBarrage)[params.SystemStage](params, MoneyPlatinum.Defs.Abilities.BulletBarrage)
end


--------------------------------------------------------------------------------------------------
--// SevenPageMuda - F //---------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
MoneyPlatinum.Defs.Abilities.SevenPageMuda = {
    Name = " 7 Page Muda",
    Id = "SevenPageMuda",
    RequireToggle_On = {"Q"},
    Cooldown = 6,
    Duration = 5,
    HitEffects = {Damage = {Damage = 20}, Blast = {}, KnockBack = {Force = 70, ForceY = 50}},
}

function MoneyPlatinum.SevenPageMuda(params)
    --params = require(Knit.Abilities.WallBlast)[params.SystemStage](params, MoneyPlatinum.Defs.Abilities.WallBlast)
end

--------------------------------------------------------------------------------------------------
--// LifeHeal - X //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
MoneyPlatinum.Defs.Abilities.LifeHeal = {
    Name = "Life Heal",
    Id = "LifeHeal",
    RequireToggle_On = {"Q"},
    Cooldown = 90,
    Duration = 20,
    Multiplier = 2
}

function MoneyPlatinum.LifeHeal(params)
    --params = require(Knit.Abilities.RageBoost)[params.SystemStage](params, MoneyPlatinum.Defs.Abilities.RageBoost)
end

--------------------------------------------------------------------------------------------------
--// STAND JUMP - Z //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
MoneyPlatinum.Defs.Abilities.StandJump = {
    Name = "Stand Jump",
    Id = "StandJump",
    Cooldown = 3,
    RequireToggle_On = {"Q"},
}

function MoneyPlatinum.StandJump(params)
    params = require(Knit.Abilities.StandJump)[params.SystemStage](params, MoneyPlatinum.Defs.Abilities.StandJump)
end

--------------------------------------------------------------------------------------------------
--// BugBarrage - C //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
MoneyPlatinum.Defs.Abilities.BugBarrage = {
    Name = "Bug Barrage",
    Id = "BugBarrage",
    Cooldown = 3,
    RequireToggle_On = {"Q"},
}

function MoneyPlatinum.BugBarrage(params)
    --params = require(Knit.Abilities.StandJump)[params.SystemStage](params, MoneyPlatinum.Defs.Abilities.StandJump)
end

--------------------------------------------------------------------------------------------------
--// PUNCH - Mouse1 //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
MoneyPlatinum.Defs.Abilities.Punch = {
    Name = "Punch",
    Id = "Punch",
    HitEffects = {Damage = {Damage = 9999}}
}

function MoneyPlatinum.Punch(params)
    params = require(Knit.Abilities.Punch)[params.SystemStage](params, MoneyPlatinum.Defs.Abilities.Punch)
end

return MoneyPlatinum