-- GoldExperienceRequiem

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

local GoldExperienceRequiem = {}

GoldExperienceRequiem.Defs = {
    PowerName = "Gold Experience Requiem",
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
            AbilityName = "Return to Zero"
        },
        T = {
            AbilityName = "Scorpion Beam"
        },
        R = {
            AbilityName = "Destabilizing Punch"
        },
        X = {
            AbilityName = "Requiem Life Heal"
        },
        Z = {
            AbilityName = "Levitate"
        },
        C = {
            AbilityName = "Bug Barrage"
        }
    }
}

--// SETUP - run this once when the stand is equipped
function GoldExperienceRequiem.SetupPower(initPlayer,params)
    Knit.Services.StateService:AddEntryToState(initPlayer, "WalkSpeed", "GoldExperienceRequiem_Setup", 2, nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Health", "GoldExperienceRequiem_Setup", GoldExperienceRequiem.Defs.HealthModifier[params.Rank], nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Multiplier_Damage", "GoldExperienceRequiem_Setup", GoldExperienceRequiem.Defs.DamageMultiplier[params.Rank], nil)
end

--// REMOVE - run this once when the stand is un-equipped
function GoldExperienceRequiem.RemovePower(initPlayer,params)
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "WalkSpeed", "GoldExperienceRequiem_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Health", "GoldExperienceRequiem_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Multiplier_Damage", "GoldExperienceRequiem_Setup")
end

--// MANAGER - this is the single point of entry from PowersService and PowersController.
function GoldExperienceRequiem.Manager(params)

    -- call the function
    if params.InputId == "Q" then
        GoldExperienceRequiem.EquipStand(params)
    elseif params.InputId == "E" then
        GoldExperienceRequiem.Barrage(params)
    elseif params.InputId == "R" then
        GoldExperienceRequiem.DestabilizingPunch(params)
    elseif params.InputId == "T" then
        GoldExperienceRequiem.TreeCage(params)
    elseif params.InputId == "F" then
        GoldExperienceRequiem.SevenPageMuda(params)
    elseif params.InputId == "X" then
        GoldExperienceRequiem.LifeHeal(params)
    elseif params.InputId == "Z" then
        GoldExperienceRequiem.StandJump(params)
    elseif params.InputId == "C" then
        GoldExperienceRequiem.BugBarrage(params)
    elseif params.InputId == "Mouse1" then
        GoldExperienceRequiem.Punch(params)
    end

    return params
end


--------------------------------------------------------------------------------------------------
--// EQUIP STAND - Q //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
GoldExperienceRequiem.Defs.Abilities.EquipStand = {
    Name = "Equip Stand",
    Id = "EquipStand",
    Cooldown = 5,
    StandModels = {
        [1] = ReplicatedStorage.EffectParts.StandModels.GoldExperienceRequiem_1,
        [2] = ReplicatedStorage.EffectParts.StandModels.GoldExperienceRequiem_2,
        [3] = ReplicatedStorage.EffectParts.StandModels.GoldExperienceRequiem_3,
    },
    Sounds = {
        Equip = ReplicatedStorage.Audio.Abilities.StandSummon,
        Remove =  ReplicatedStorage.Audio.Abilities.StandSummon,
    }
}

function GoldExperienceRequiem.EquipStand(params)
    params = require(Knit.Abilities.ManageStand)[params.SystemStage](params, GoldExperienceRequiem.Defs.Abilities.EquipStand)
end

--------------------------------------------------------------------------------------------------
--// BARRAGE - E //----------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
GoldExperienceRequiem.Defs.Abilities.Barrage = {
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

function GoldExperienceRequiem.Barrage(params)
    params = require(Knit.Abilities.Barrage)[params.SystemStage](params, GoldExperienceRequiem.Defs.Abilities.Barrage)
end

--------------------------------------------------------------------------------------------------
--// DestabilizingPunch - R//------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

--defs
GoldExperienceRequiem.Defs.Abilities.DestabilizingPunch = {
    Name = "Destabilizing Punch",
    Id = "DestabilizingPunch",
    Cooldown = 10,
    RequireToggle_On = {"Q"},
    HitEffects = {Damage = {Damage = 30}, PinCharacter = {Duration = 5.5}, AngeloRock = {Duration = 5}},
    Sounds = {
        Punch = ReplicatedStorage.Audio.StandSpecific.TheWorld.HeavyPunch,
    }
}

function GoldExperienceRequiem.DestabilizingPunch(params)
    --params = require(Knit.Abilities.HeavyPunch)[params.SystemStage](params, GoldExperienceRequiem.Defs.Abilities.StonePunch)
end

--------------------------------------------------------------------------------------------------
--// TreeCage - T //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
GoldExperienceRequiem.Defs.Abilities.TreeCage = {
    Name = "Tree Cage",
    Id = "TreeCage",
    Cooldown = 6,
    RequireToggle_On = {"Q"},
    HitEffects = {Damage = {Damage = 8}},
}

function GoldExperienceRequiem.TreeCage(params)
    --params = require(Knit.Abilities.BulletBarrage)[params.SystemStage](params, GoldExperienceRequiem.Defs.Abilities.BulletBarrage)
end


--------------------------------------------------------------------------------------------------
--// SevenPageMuda - F //---------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
GoldExperienceRequiem.Defs.Abilities.SevenPageMuda = {
    Name = " 7 Page Muda",
    Id = "SevenPageMuda",
    RequireToggle_On = {"Q"},
    Cooldown = 6,
    Duration = 5,
    HitEffects = {Damage = {Damage = 20}, Blast = {}, KnockBack = {Force = 70, ForceY = 50}},
}

function GoldExperienceRequiem.SevenPageMuda(params)
    --params = require(Knit.Abilities.WallBlast)[params.SystemStage](params, GoldExperienceRequiem.Defs.Abilities.WallBlast)
end

--------------------------------------------------------------------------------------------------
--// LifeHeal - X //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
GoldExperienceRequiem.Defs.Abilities.LifeHeal = {
    Name = "Life Heal",
    Id = "LifeHeal",
    RequireToggle_On = {"Q"},
    Cooldown = 90,
    Duration = 20,
    Multiplier = 2
}

function GoldExperienceRequiem.LifeHeal(params)
    --params = require(Knit.Abilities.RageBoost)[params.SystemStage](params, GoldExperienceRequiem.Defs.Abilities.RageBoost)
end

--------------------------------------------------------------------------------------------------
--// STAND JUMP - Z //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
GoldExperienceRequiem.Defs.Abilities.StandJump = {
    Name = "Stand Jump",
    Id = "StandJump",
    Cooldown = 3,
    RequireToggle_On = {"Q"},
}

function GoldExperienceRequiem.StandJump(params)
    params = require(Knit.Abilities.StandJump)[params.SystemStage](params, GoldExperienceRequiem.Defs.Abilities.StandJump)
end

--------------------------------------------------------------------------------------------------
--// BugBarrage - C //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
GoldExperienceRequiem.Defs.Abilities.BugBarrage = {
    Name = "Bug Barrage",
    Id = "BugBarrage",
    Cooldown = 3,
    RequireToggle_On = {"Q"},
}

function GoldExperienceRequiem.BugBarrage(params)
    --params = require(Knit.Abilities.StandJump)[params.SystemStage](params, GoldExperienceRequiem.Defs.Abilities.StandJump)
end

--------------------------------------------------------------------------------------------------
--// PUNCH - Mouse1 //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
GoldExperienceRequiem.Defs.Abilities.Punch = {
    Name = "Punch",
    Id = "Punch",
    HitEffects = {Damage = {Damage = 5}}
}

function GoldExperienceRequiem.Punch(params)
    params = require(Knit.Abilities.Punch)[params.SystemStage](params, GoldExperienceRequiem.Defs.Abilities.Punch)
end

return GoldExperienceRequiem