-- Vampire

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

local Vampire = {}

Vampire.Defs = {
    PowerName = "Vampire",
    MaxXp = {
        [1] = 10000,
        [2] = 20000,
        [3] = 30000
    },
    DamageMultiplier = {
        [1] = 1,
        [2] = 1.5,
        [3] = 2,
    },
    HealthModifier = {
        [1] = 30,
        [2] = 50,
        [3] = 100
    },
    Abilities = {}, -- ability defs are inside each ability function area
    KeyMap = {
        Q = {
            AbilityName = "Vampiric Rage"
        },
        E = {
            AbilityName = "Barrage"
        },
        F = {
            AbilityName = "Laser Eyes"
        },
        T = {
            AbilityName = "Zombie Summon"
        },
        R = {
            AbilityName = "Freeze Punch"
        },
        X = {
            AbilityName = "-"
        },
        Z = {
            AbilityName = "Power Jump"
        },
        C = {
            AbilityName = "-"
        }
    }
}

--[[
for keyName, table in pairs(Vampire.Defs.Abilities) do
    local abilityName = table.Name
    local thisMap = 
        keyName = {"AbilityName" = abilityName}
 
    table.insert(Vampire.Defs.KeyMap, thisMap)
end
]]--

--// SETUP - run this once when the stand is equipped
function Vampire.SetupPower(initPlayer,params)
    print("SETUP VAMPIRE")
    Knit.Services.StateService:AddEntryToState(initPlayer, "WalkSpeed", "Vampire_Setup", 2, nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Health", "Vampire_Setup", Vampire.Defs.HealthModifier[params.Rank], nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Multiplier_Damage", "Vampire_Setup", Vampire.Defs.DamageMultiplier[params.Rank], nil)
    Knit.Services.PlayerUtilityService:SetHealthStatus(initPlayer, {Enabled = true, RegenDay = 0, RegenNight = 3})
end

--// REMOVE - run this once when the stand is un-equipped
function Vampire.RemovePower(initPlayer,params)
    print("REMOVE VAMPIRE")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "WalkSpeed", "Vampire_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Health", "Vampire_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Multiplier_Damage", "Vampire_Setup")
    Knit.Services.PlayerUtilityService:SetHealthStatus(initPlayer, {DefaultValues = true})
end

--// MANAGER - this is the single point of entry from PowersService and PowersController.
function Vampire.Manager(params)

    if params.InputId == "Mouse1" then
        Vampire.Punch(params)
    else
        Vampire[params.InputId](params)
    end

    return params
end

--------------------------------------------------------------------------------------------------
--// EQUIP STAND - Q //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
Vampire.Defs.Abilities.Q = {
    Id = "VampiricRage",
    Cooldown = 5,
    AbilityMod = Knit.Abilities.BasicToggle.VampiricRage,
}

function Vampire.Q(params)
    print("Vampire Q")
    params = require(Knit.Abilities.BasicToggle)[params.SystemStage](params, Vampire.Defs.Abilities.Q)
end

--------------------------------------------------------------------------------------------------
--// BARRAGE - E //----------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
Vampire.Defs.Abilities.E = {
    Id = "Barrage",
    Duration = 6,
    Cooldown = 5,
    HitEffects = {Damage = {Damage = 3, KnockBack = 10}, LifeSteal = {Quantity = 3}},
}

function Vampire.E(params)
    print("Vampire E", params)
    params = require(Knit.Abilities.Barrage_Spec)[params.SystemStage](params, Vampire.Defs.Abilities.E)
end

--------------------------------------------------------------------------------------------------
--// Stone Punch - R//------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

--defs
Vampire.Defs.Abilities.R = {
    Id = "FreezePunch",
    Cooldown = 10,
    HitEffects = {Damage = {Damage = 30}, PinCharacter = {Duration = 5.5}, IceBlock = {Duration = 5}},
    Sound = ReplicatedStorage.Audio.General.GenericWhoosh_Slow
}

function Vampire.R(params)
    print("Vampire R")
    params = require(Knit.Abilities.HeavyPunch_Spec)[params.SystemStage](params, Vampire.Defs.Abilities.R)
end

--------------------------------------------------------------------------------------------------
--// Bullet Launch - T //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
Vampire.Defs.Abilities.T = {
    Id = "BulletBarrage",
    Cooldown = 4,
    RequireToggle_On = {"Q"},
    HitEffects = {Damage = {Damage = 10}},
    --AbilityMod = Knit.Abilities.BasicProjectile.BulletBarrage,
}

function Vampire.T(params)
    print("Vampire T")
    --params = require(Knit.Abilities.BulletBarrage)[params.SystemStage](params, Vampire.Defs.Abilities.BulletBarrage)
end


--------------------------------------------------------------------------------------------------
--// Wall Blast - F //---------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
Vampire.Defs.Abilities.F = {
    Id = "LaserEyes",
    Cooldown = 2,
    AbilityMod = Knit.Abilities.BasicProjectile.LaserEyes,
}

function Vampire.F(params)
    print("F")
    params = require(Knit.Abilities.BasicProjectile)[params.SystemStage](params, Vampire.Defs.Abilities.F)
end


--------------------------------------------------------------------------------------------------
--// Rage Boost - X //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
Vampire.Defs.Abilities.X = {
    Name = "Rage Boost",
    Id = "RageBoost",
    Cooldown = 90,
    Duration = 20,
    Multiplier = 2
}

function Vampire.X(params)
    print("Vampire X")
    --params = require(Knit.Abilities.RageBoost)[params.SystemStage](params, Vampire.Defs.Abilities.RageBoost)
end

--------------------------------------------------------------------------------------------------
--// STAND JUMP - Z //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
Vampire.Defs.Abilities.Z = {
    Name = "Stand Jump",
    Id = "StandJump",
    Cooldown = 3,
}

function Vampire.Z(params)
    params = require(Knit.Abilities.StandJump_Spec)[params.SystemStage](params, Vampire.Defs.Abilities.Z)
end

--------------------------------------------------------------------------------------------------
--// PUNCH - Mouse1 //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
Vampire.Defs.Abilities.Punch = {
    Name = "Punch",
    Id = "Punch",
    HitEffects = {Damage = {Damage = 10, KnockBack = 10,}, LifeSteal = {Quantity = 15}}
}

function Vampire.Punch(params)
    params = require(Knit.Abilities.Punch)[params.SystemStage](params, Vampire.Defs.Abilities.Punch)
end

return Vampire