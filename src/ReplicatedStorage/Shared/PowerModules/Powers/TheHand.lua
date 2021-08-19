-- TheHand

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

local TheHand = {}

TheHand.Defs = {
    PowerName = "TheHand",
    MaxXp = 15000,
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
            F = {AbilityName = "Flower Pot Barrage"},
            T = {AbilityName = "Black Hole"},
            R = {AbilityName = "Scrape Punch"},
            X = {AbilityName = "Scrape Away"},
            Z = {AbilityName = "Stand Jump"},
            C = {AbilityName = "Void Pull"}
        },
        [2] = {
            Q = {AbilityName = "Summon Stand"},
            E = {AbilityName = "Barrage"},
            F = {AbilityName = "Flower Pot Barrage"},
            T = {AbilityName = "Black Hole"},
            R = {AbilityName = "Scrape Punch"},
            X = {AbilityName = "Scrape Away"},
            Z = {AbilityName = "Stand Jump"},
            C = {AbilityName = "Void Pull"}
        },
        [3] = {
            Q = {AbilityName = "Summon Stand"},
            E = {AbilityName = "Barrage"},
            F = {AbilityName = "Flower Pot Barrage"},
            T = {AbilityName = "Black Hole"},
            R = {AbilityName = "Scrape Punch"},
            X = {AbilityName = "Scrape Away"},
            Z = {AbilityName = "Stand Jump"},
            C = {AbilityName = "Void Pull"}
        },
    }
}

--// SETUP - run this once when the stand is equipped
function TheHand.SetupPower(initPlayer,params)
    Knit.Services.StateService:AddEntryToState(initPlayer, "WalkSpeed", "TheHand_Setup", 2, nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Health", "TheHand_Setup", TheHand.Defs.HealthModifier[params.Rank], nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Multiplier_Damage", "TheHand_Setup", TheHand.Defs.DamageMultiplier[params.Rank], nil)

    -- force cooldown on all abilities
    --local cooldownKeys = {"Q", "E", "R", "T", "F", "Z", "X", "C"}
    local cooldownKeys = {"E", "R", "T", "F", "Z", "X", "C"}
    for _, key in pairs(cooldownKeys) do
        require(Knit.PowerUtils.Cooldown).Server_SetCooldown(initPlayer.UserId, key, 15)
    end
end

--// REMOVE - run this once when the stand is un-equipped
function TheHand.RemovePower(initPlayer,params)
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "WalkSpeed", "TheHand_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Health", "TheHand_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Multiplier_Damage", "TheHand_Setup")
end

--// MANAGER - this is the single point of entry from PowersService and PowersController.
function TheHand.Manager(params)

    if params.InputId == "Mouse1" then
        TheHand.Punch(params)
    else
        TheHand[params.InputId](params)
    end

    return params
end

--------------------------------------------------------------------------------------------------
--// Q //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
TheHand.Defs.Abilities.Q = {
    Name = "Equip Stand",
    Id = "EquipStand",
    Cooldown = 5,
    StandModels = {
        [1] = ReplicatedStorage.EffectParts.StandModels.TheHand_1,
        [2] = ReplicatedStorage.EffectParts.StandModels.TheHand_2,
        [3] = ReplicatedStorage.EffectParts.StandModels.TheHand_3,
    },
    Sounds = {
        Equip = ReplicatedStorage.Audio.Abilities.StandSummon,
        Remove =  ReplicatedStorage.Audio.Abilities.StandSummon,
    }
}

function TheHand.Q(params)
    params = require(Knit.Abilities.ManageStand)[params.SystemStage](params, TheHand.Defs.Abilities.Q)
end

--------------------------------------------------------------------------------------------------
--// E //----------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
TheHand.Defs.Abilities.E = {
    Id = "Barrage",
    Duration = 4,
    Cooldown = 4,
    RequireToggle_On = {"Q"},
    HitEffects = {Damage = {Damage = 6, KnockBack = 15}},
    Sounds = {
        Barrage = ReplicatedStorage.Audio.Abilities.GenericBarrage,
    }
}

function TheHand.E(params)
    params = require(Knit.Abilities.Barrage)[params.SystemStage](params, TheHand.Defs.Abilities.E)
end

--------------------------------------------------------------------------------------------------
--// R //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

--defs
TheHand.Defs.Abilities.R = {
    Id = "ScrapePunch",
    Cooldown = 10,
    RequireToggle_On = {"Q"},
    AbilityMod = Knit.Abilities.HeavyPunch:FindFirstChild("ScrapePunch", true),
}

function TheHand.R(params)
    params = require(Knit.Abilities.HeavyPunch)[params.SystemStage](params, TheHand.Defs.Abilities.R)
end

--------------------------------------------------------------------------------------------------
--// T //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
TheHand.Defs.Abilities.T = {
    Id = "BlackHole",
    Cooldown = 60,
    RequireToggle_On = {"Q"},
    AbilityMod = Knit.Abilities.BasicAbility:FindFirstChild("BlackHole", true),
}

function TheHand.T(params)
    params = require(Knit.Abilities.BasicAbility)[params.SystemStage](params, TheHand.Defs.Abilities.T)
end


--------------------------------------------------------------------------------------------------
--// F //---------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
TheHand.Defs.Abilities.F = {
    Id = "FlowerPotBarrage",
    Cooldown = 6,
    RequireToggle_On = {"Q"},
    AbilityMod = Knit.Abilities.ProjectileBarrage:FindFirstChild("FlowerPotBarrage", true),
}

function TheHand.F(params)
    params = require(Knit.Abilities.ProjectileBarrage)[params.SystemStage](params, TheHand.Defs.Abilities.F)
end


--------------------------------------------------------------------------------------------------
--// X //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
TheHand.Defs.Abilities.X = {
    Id = "ScrapeAway",
    Cooldown = 8,
    RequireToggle_On = {"Q"},
    AbilityMod = Knit.Abilities.BasicProjectile:FindFirstChild("ScrapeAway", true),
}

function TheHand.X(params)
    params = require(Knit.Abilities.BasicProjectile)[params.SystemStage](params, TheHand.Defs.Abilities.X)
end

--------------------------------------------------------------------------------------------------
--// C //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
TheHand.Defs.Abilities.C = {
    Id = "VoidPull",
    Cooldown = 8,
    RequireToggle_On = {"Q"},
    AbilityMod = Knit.Abilities.MeleeAttack:FindFirstChild("VoidPull", true),
}

function TheHand.C(params)
    params = require(Knit.Abilities.MeleeAttack)[params.SystemStage](params, TheHand.Defs.Abilities.C)
end

--------------------------------------------------------------------------------------------------
--// Z //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
TheHand.Defs.Abilities.Z = {
    Id = "StandJump",
    Cooldown = 6,
    RequireToggle_On = {"Q"},
}

function TheHand.Z(params)
    params = require(Knit.Abilities.StandJump)[params.SystemStage](params, TheHand.Defs.Abilities.Z)
end

--------------------------------------------------------------------------------------------------
--// Mouse1 //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
TheHand.Defs.Abilities.Punch = {
    Name = "Punch",
    Id = "Punch",
    HitEffects = {Damage = {Damage = 10, KnockBack = 10,}}
}

function TheHand.Punch(params)
    params = require(Knit.Abilities.Punch)[params.SystemStage](params, TheHand.Defs.Abilities.Punch)
end

return TheHand