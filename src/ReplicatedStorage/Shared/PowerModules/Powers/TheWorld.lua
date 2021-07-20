-- TheWorld

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

local TheWorld = {}

TheWorld.Defs = {
    PowerName = "The World",
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
            F = {AbilityName = "Knife Throw"},
            T = {AbilityName = "Time Stop"},
            R = {AbilityName = "Time Punch"},
            X = {AbilityName = "Bullet Kick"},
            Z = {AbilityName = "Stand Jump"},
            C = {AbilityName = "-"}
        },
        [2] = {
            Q = {AbilityName = "Summon Stand"},
            E = {AbilityName = "Barrage"},
            F = {AbilityName = "Knife Throw"},
            T = {AbilityName = "Time Stop"},
            R = {AbilityName = "Time Punch"},
            X = {AbilityName = "Bullet Kick"},
            Z = {AbilityName = "Stand Jump"},
            C = {AbilityName = "-"}
        },
        [3] = {
            Q = {AbilityName = "Summon Stand"},
            E = {AbilityName = "Barrage"},
            F = {AbilityName = "Knife Throw"},
            T = {AbilityName = "Time Stop"},
            R = {AbilityName = "Time Punch"},
            X = {AbilityName = "Bullet Kick"},
            Z = {AbilityName = "Stand Jump"},
            C = {AbilityName = "-"}
        },

    }
}

--// SETUP - run this once when the stand is equipped
function TheWorld.SetupPower(initPlayer,params)
    Knit.Services.StateService:AddEntryToState(initPlayer, "WalkSpeed", "TheWorld_Setup", 2, nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Immunity", "TheWorld_Setup", 2, {TimeStop = true})
    Knit.Services.StateService:AddEntryToState(initPlayer, "Health", "TheWorld_Setup", TheWorld.Defs.HealthModifier[params.Rank], nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Multiplier_Damage", "TheWorld_Setup", TheWorld.Defs.DamageMultiplier[params.Rank], nil)

    -- force cooldown on all abilities
    --local cooldownKeys = {"Q", "E", "R", "T", "F", "Z", "X", "C"}
    local cooldownKeys = {"E", "R", "T", "F", "Z", "X", "C"}
    for _, key in pairs(cooldownKeys) do
        require(Knit.PowerUtils.Cooldown).Server_SetCooldown(initPlayer.UserId, key, 15)
    end
end

--// REMOVE - run this once when the stand is un-equipped
function TheWorld.RemovePower(initPlayer,params)
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "WalkSpeed", "TheWorld_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Immunity", "TheWorld_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Health", "TheWorld_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Multiplier_Damage", "TheWorld_Setup")
end

--// MANAGER - this is the single point of entry from PowersService and PowersController.
function TheWorld.Manager(params)

    --print("TheWorld.Manager(params)", params)

    -- call the function
    if params.InputId == "Q" then
        TheWorld.EquipStand(params)
    elseif params.InputId == "E" then
        TheWorld.Barrage(params)
    elseif params.InputId == "F" then
        TheWorld.KnifeThrow(params)
    elseif params.InputId == "T" then
            TheWorld.TimeStop(params)
    elseif params.InputId == "R" then
        TheWorld.HeavyPunch(params)
    elseif params.InputId == "X" then
        TheWorld.BulletKick(params)
    elseif params.InputId == "Z" then
        TheWorld.StandJump(params)
    elseif params.InputId == "Mouse1" then
        TheWorld.Punch(params)
    end

    return params
end

--------------------------------------------------------------------------------------------------
--// EQUIP STAND //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
TheWorld.Defs.Abilities.EquipStand = {
    Name = "Equip Stand",
    Id = "EquipStand",
    Cooldown = 5,
    StandModels = {
        [1] = ReplicatedStorage.EffectParts.StandModels.TheWorld_1,
        [2] = ReplicatedStorage.EffectParts.StandModels.TheWorld_2,
        [3] = ReplicatedStorage.EffectParts.StandModels.TheWorld_3,
    },
    Sounds = {
        Equip = ReplicatedStorage.Audio.StandSpecific.TheWorld.Summon,
        Remove =  ReplicatedStorage.Audio.Abilities.StandSummon,
    }
}

function TheWorld.EquipStand(params)
    params = require(Knit.Abilities.ManageStand)[params.SystemStage](params, TheWorld.Defs.Abilities.EquipStand)
end

--------------------------------------------------------------------------------------------------
--// BARRAGE //----------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
TheWorld.Defs.Abilities.Barrage = {
    Name = "Barrage",
    Id = "Barrage",
    Duration = 5,
    Cooldown = 7,
    RequireToggle_On = {"Q"},
    HitEffects = {Damage = {Damage = 5, KnockBack = 10}},
    Sounds = {
        Barrage = ReplicatedStorage.Audio.StandSpecific.TheWorld.Barrage,
    }
}

function TheWorld.Barrage(params)
    params = require(Knit.Abilities.Barrage)[params.SystemStage](params, TheWorld.Defs.Abilities.Barrage)
end

--------------------------------------------------------------------------------------------------
--// TIME STOP //---------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
TheWorld.Defs.Abilities.TimeStop = {
    Name = "Time Stop",
    Id = "TimeStop",
    Duration = 8,
    Cooldown = 70,
    Range = 80,
    RequireToggle_On = {"Q"},
    HitEffects = {Damage = {Damage = 1}, PinCharacter = {Duration = 8}, ColorShift = {Duration = 8}}, 
    Sounds = {
        TimeStop = ReplicatedStorage.Audio.StandSpecific.TheWorld.TimeStop,
    }
}

function TheWorld.TimeStop(params)
    params = require(Knit.Abilities.TimeStop)[params.SystemStage](params, TheWorld.Defs.Abilities.TimeStop)
end

--------------------------------------------------------------------------------------------------
--// KNIFE THROW //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
TheWorld.Defs.Abilities.KnifeThrow = {
    Id = "KnifeThrow",
    RequireToggle_On = {"Q"},
    Cooldown = 3,
    AbilityMod = Knit.Abilities.BasicProjectile.KnifeThrow
}

function TheWorld.KnifeThrow(params)
    params = require(Knit.Abilities.BasicProjectile)[params.SystemStage](params, TheWorld.Defs.Abilities.KnifeThrow)
end

--------------------------------------------------------------------------------------------------
--// HEAVY PUNCH //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

--defs
TheWorld.Defs.Abilities.HeavyPunch = {
    Id = "TimePunch",
    Cooldown = 7,
    RequireToggle_On = {"Q"},
    AbilityMod = Knit.Abilities.HeavyPunch:FindFirstChild("TimePunch", true),
}

function TheWorld.HeavyPunch(params)
    params = require(Knit.Abilities.HeavyPunch)[params.SystemStage](params, TheWorld.Defs.Abilities.HeavyPunch)
end

--------------------------------------------------------------------------------------------------
--// BULLET KICK //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
TheWorld.Defs.Abilities.BulletKick = {
    Name = "Bullet Kick",
    Id = "BulletKick",
    Cooldown = 5,
    RequireToggle_On = {"Q"},
    AbilityMod = Knit.AbilityMods.TripleKick_BulletKick,
}

function TheWorld.BulletKick(params)
    params = require(Knit.Abilities.TripleKick)[params.SystemStage](params, TheWorld.Defs.Abilities.BulletKick)
end

--------------------------------------------------------------------------------------------------
--// STAND JUMP //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
TheWorld.Defs.Abilities.StandJump = {
    Name = "Stand Jump",
    Id = "StandJump",
    Cooldown = 3,
    RequireToggle_On = {"Q"},
}

function TheWorld.StandJump(params)
    params = require(Knit.Abilities.StandJump)[params.SystemStage](params, TheWorld.Defs.Abilities.StandJump)
end

--------------------------------------------------------------------------------------------------
--// PUNCH //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
TheWorld.Defs.Abilities.Punch = {
    Name = "Punch",
    Id = "Punch",
    Cooldown = 0.5,
    HitEffects = {Damage = {Damage = 5, KnockBack = 20}},
    --RequireToggle_On = {},
    --RequireToggle_Off = {"Mouse1"},
}

function TheWorld.Punch(params)
    params = require(Knit.Abilities.Punch)[params.SystemStage](params, TheWorld.Defs.Abilities.Punch)
end

return TheWorld