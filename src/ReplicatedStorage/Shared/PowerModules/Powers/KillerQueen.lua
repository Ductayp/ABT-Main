-- KillerQueen


-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

local KillerQueen = {}

KillerQueen.Defs = {
    PowerName = "Killer Queen",
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
            F = {AbilityName = "Bomb Touch"},
            T = {AbilityName = "Coin Toss"},
            R = {AbilityName = "Bomb Punch"},
            X = {AbilityName = "Sheer Heart Attack"},
            Z = {AbilityName = "Stand Jump"},
            C = {AbilityName = "-"}
        },
        [2] = {
            Q = {AbilityName = "Summon Stand"},
            E = {AbilityName = "Barrage"},
            F = {AbilityName = "Bomb Touch"},
            T = {AbilityName = "Coin Toss"},
            R = {AbilityName = "Bomb Punch"},
            X = {AbilityName = "Sheer Heart Attack"},
            Z = {AbilityName = "Stand Jump"},
            C = {AbilityName = "-"}
        },
        [3] = {
            Q = {AbilityName = "Summon Stand"},
            E = {AbilityName = "Barrage"},
            F = {AbilityName = "Bomb Touch"},
            T = {AbilityName = "Coin Toss"},
            R = {AbilityName = "Bomb Punch"},
            X = {AbilityName = "Sheer Heart Attack"},
            Z = {AbilityName = "Stand Jump"},
            C = {AbilityName = "-"}
        },

    }
}

--// SETUP - run this once when the stand is equipped
function KillerQueen.SetupPower(initPlayer,params)
    Knit.Services.StateService:AddEntryToState(initPlayer, "WalkSpeed", "KillerQueen_Setup", 2, nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Health", "KillerQueen_Setup", KillerQueen.Defs.HealthModifier[params.Rank], nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Multiplier_Damage", "KillerQueen_Setup", KillerQueen.Defs.DamageMultiplier[params.Rank], nil)

    -- force cooldown on all abilities
    --local cooldownKeys = {"Q", "E", "R", "T", "F", "Z", "X", "C"}
    local cooldownKeys = {"E", "R", "T", "F", "Z", "X", "C"}
    for _, key in pairs(cooldownKeys) do
        require(Knit.PowerUtils.Cooldown).Server_SetCooldown(initPlayer.UserId, key, 15)
    end
end

--// REMOVE - run this once when the stand is un-equipped
function KillerQueen.RemovePower(initPlayer,params)
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "WalkSpeed", "KillerQueen_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Health", "KillerQueen_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Multiplier_Damage", "KillerQueen_Setup")
end

--// MANAGER - this is the single point of entry from PowersService and PowersController.
function KillerQueen.Manager(params)

    -- call the function
    if params.InputId == "Q" then
        KillerQueen.EquipStand(params)
    elseif params.InputId == "E" then
        KillerQueen.Barrage(params)
    elseif params.InputId == "R" then
        KillerQueen.BombPunch(params)
    elseif params.InputId == "T" then
        KillerQueen.ExplosiveCoin(params)
    elseif params.InputId == "F" then
        KillerQueen.BitesTheDust(params)
    elseif params.InputId == "X" then
        KillerQueen.SheerHeartAttack(params)
    elseif params.InputId == "Z" then
        KillerQueen.StandJump(params)
    elseif params.InputId == "Mouse1" then
        KillerQueen.Punch(params)
    end

    return params
end

--------------------------------------------------------------------------------------------------
--// EQUIP STAND - Q //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
KillerQueen.Defs.Abilities.EquipStand = {
    Name = "Equip Stand",
    Id = "EquipStand",
    Cooldown = 5,
    StandModels = {
        [1] = ReplicatedStorage.EffectParts.StandModels.KillerQueen_1,
        [2] = ReplicatedStorage.EffectParts.StandModels.KillerQueen_2,
        [3] = ReplicatedStorage.EffectParts.StandModels.KillerQueen_3,
    },
    Sounds = {
        Equip = ReplicatedStorage.Audio.StandSpecific.KillerQueen.Summon,
        Remove =  ReplicatedStorage.Audio.Abilities.StandSummon,
    }
}

function KillerQueen.EquipStand(params)
    params = require(Knit.Abilities.ManageStand)[params.SystemStage](params, KillerQueen.Defs.Abilities.EquipStand)
end

--------------------------------------------------------------------------------------------------
--// BARRAGE - E //----------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
KillerQueen.Defs.Abilities.Barrage = {
    Name = "Barrage",
    Id = "Barrage",
    Duration = 4,
    Cooldown = 7,
    RequireToggle_On = {"Q"},
    HitEffects = {Damage = {Damage = 3, KnockBack = 10}},
    Sounds = {
        Barrage = ReplicatedStorage.Audio.StandSpecific.KillerQueen.Barrage,
    }
}

function KillerQueen.Barrage(params)
    params = require(Knit.Abilities.Barrage)[params.SystemStage](params, KillerQueen.Defs.Abilities.Barrage)
end

--------------------------------------------------------------------------------------------------
--// BOMB PUNCH - R//------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

--defs
KillerQueen.Defs.Abilities.BombPunch = {
    Id = "BombPunch",
    Cooldown = 5,
    RequireToggle_On = {"Q"},
    AbilityMod = Knit.Abilities.MeleeAttack:FindFirstChild("BombPunch", true),
}

function KillerQueen.BombPunch(params)
    params = require(Knit.Abilities.MeleeAttack)[params.SystemStage](params, KillerQueen.Defs.Abilities.BombPunch)
end

--------------------------------------------------------------------------------------------------
--// EXPLOSIVE COIN - T //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
KillerQueen.Defs.Abilities.ExplosiveCoin = {
    Name = "Explosive Coin",
    Id = "ExplosiveCoin",
    Cooldown = 8,
    --RequireToggle_On = {"Q"},
    AbilityMod = Knit.AbilityMods.BasicGrenade_ExplosiveCoin,
}

function KillerQueen.ExplosiveCoin(params)
    params = require(Knit.Abilities.BasicGrenade)[params.SystemStage](params, KillerQueen.Defs.Abilities.ExplosiveCoin)
end


--------------------------------------------------------------------------------------------------
--// BITES THE DUST - F //---------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
KillerQueen.Defs.Abilities.BitesTheDust = {
    Name = "Bites The Dust",
    Id = "BitesTheDust",
    Cooldown = 20,
    --RequireToggle_On = {"Q"},
}

function KillerQueen.BitesTheDust(params)
    params = require(Knit.Abilities.BitesTheDust)[params.SystemStage](params, KillerQueen.Defs.Abilities.BitesTheDust)
end


--------------------------------------------------------------------------------------------------
--// SHEER HEART ATTACK - X //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
KillerQueen.Defs.Abilities.SheerHeartAttack = {
    Name = "Sheer Heart Attack",
    Id = "SheerHeartAttack",
    Cooldown = 15,
    --RequireToggle_On = {"Q"},
    AbilityMod = Knit.Abilities.BasicSeeker.SheerHeartAttack,
}

function KillerQueen.SheerHeartAttack(params)
    params = require(Knit.Abilities.BasicSeeker)[params.SystemStage](params, KillerQueen.Defs.Abilities.SheerHeartAttack)
end

--------------------------------------------------------------------------------------------------
--// STAND JUMP - Z //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
KillerQueen.Defs.Abilities.StandJump = {
    Name = "Stand Jump",
    Id = "StandJump",
    Cooldown = 3,
    RequireToggle_On = {"Q"},
}

function KillerQueen.StandJump(params)
    params = require(Knit.Abilities.StandJump)[params.SystemStage](params, KillerQueen.Defs.Abilities.StandJump)
end

--------------------------------------------------------------------------------------------------
--// PUNCH - Mouse1 //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
KillerQueen.Defs.Abilities.Punch = {
    Name = "Punch",
    Id = "Punch",
    HitEffects = {Damage = {Damage = 5, KnockBack = 20}}
}

function KillerQueen.Punch(params)
    params = require(Knit.Abilities.Punch)[params.SystemStage](params, KillerQueen.Defs.Abilities.Punch)
end

return KillerQueen