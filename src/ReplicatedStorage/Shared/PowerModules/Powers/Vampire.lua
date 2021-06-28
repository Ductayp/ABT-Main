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
            AbilityName = "Vampiric Sacrifice"
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

--// SETUP - run this once when the stand is equipped
function Vampire.SetupPower(initPlayer,params)
    Knit.Services.StateService:AddEntryToState(initPlayer, "WalkSpeed", "Vampire_Setup", 2, nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Health", "Vampire_Setup", Vampire.Defs.HealthModifier[params.Rank], nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Multiplier_Damage", "Vampire_Setup", Vampire.Defs.DamageMultiplier[params.Rank], nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "HealthTick", "Vampire_Setup", true, {Day = -1, Night = 1})

    local newFistAura_1 = ReplicatedStorage.EffectParts.Specs.Vampire.VampireFistAura:Clone()
    local newFistAura_2 = ReplicatedStorage.EffectParts.Specs.Vampire.VampireFistAura:Clone()

    repeat wait() until initPlayer.Character

    newFistAura_1.Parent = initPlayer.Character.RightHand
    newFistAura_2.Parent = initPlayer.Character.LeftHand

end

--// REMOVE - run this once when the stand is un-equipped
function Vampire.RemovePower(initPlayer,params)
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "WalkSpeed", "Vampire_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Health", "Vampire_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Multiplier_Damage", "Vampire_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "HealthTick", "Vampire_Setup")

    repeat wait() until initPlayer.Character

    local rightFist = initPlayer.Character.RightHand:FindFirstChild("VampireFistAura")
    if rightFist then
        rightFist:Destroy()
    end

    local leftFist = initPlayer.Character.LeftHand:FindFirstChild("VampireFistAura")
    if leftFist then
        leftFist:Destroy()
    end
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
--// Q //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
Vampire.Defs.Abilities.Q = {
    Id = "VampiricRage",
    Cooldown = 5,
    AbilityMod = Knit.Abilities.BasicToggle.VampiricRage,
}

function Vampire.Q(params)
    params = require(Knit.Abilities.BasicToggle)[params.SystemStage](params, Vampire.Defs.Abilities.Q)
end

--------------------------------------------------------------------------------------------------
--// E //----------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
Vampire.Defs.Abilities.E = {
    Id = "Barrage",
    Duration = 6,
    Cooldown = 5,
    HitEffects = {Damage = {Damage = 3, KnockBack = 15}, LifeSteal = {Quantity = 1.5}},
}

function Vampire.E(params)
    params = require(Knit.Abilities.Barrage_Spec)[params.SystemStage](params, Vampire.Defs.Abilities.E)
end

--------------------------------------------------------------------------------------------------
--// R //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

--defs
Vampire.Defs.Abilities.R = {
    Id = "FreezePunch",
    Cooldown = 10,
    HitEffects = {Damage = {Damage = 30}, PinCharacter = {Duration = 5.5}, IceBlock = {Duration = 5}},
    Sound = ReplicatedStorage.Audio.General.GenericWhoosh_Slow
}

function Vampire.R(params)
    params = require(Knit.Abilities.HeavyPunch_Spec)[params.SystemStage](params, Vampire.Defs.Abilities.R)
end

--------------------------------------------------------------------------------------------------
--// T //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
Vampire.Defs.Abilities.T = {
    Id = "ZombieSummon",
    Cooldown = 20,
    AbilityMod = Knit.Abilities.SummonMinion.VampireZombies,
}

function Vampire.T(params)
    params = require(Knit.Abilities.SummonMinion)[params.SystemStage](params, Vampire.Defs.Abilities.T)
end


--------------------------------------------------------------------------------------------------
--// F //---------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
Vampire.Defs.Abilities.F = {
    Id = "LaserEyes",
    Cooldown = 2,
    AbilityMod = Knit.Abilities.BasicProjectile.LaserEyes,
}

function Vampire.F(params)
    params = require(Knit.Abilities.BasicProjectile)[params.SystemStage](params, Vampire.Defs.Abilities.F)
end


--------------------------------------------------------------------------------------------------
--// X //------------------------------------------------------------------------------
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
    --params = require(Knit.Abilities.RageBoost)[params.SystemStage](params, Vampire.Defs.Abilities.RageBoost)
end

--------------------------------------------------------------------------------------------------
--// Z //------------------------------------------------------------------------------
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
--// Mouse1 //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
Vampire.Defs.Abilities.Punch = {
    Name = "Punch",
    Id = "Punch",
    HitEffects = {Damage = {Damage = 10, KnockBack = 10,}, LifeSteal = {Quantity = 8}}
}

function Vampire.Punch(params)
    params = require(Knit.Abilities.Punch)[params.SystemStage](params, Vampire.Defs.Abilities.Punch)
end

return Vampire