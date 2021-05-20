-- TheHand

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))

local TheHand = {}

TheHand.Defs = {
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
            AbilityName = "Flower Pot Barrage"
        },
        T = {
            AbilityName = "Black Hole"
        },
        R = {
            AbilityName = "Scrape Punch"
        },
        X = {
            AbilityName = "Scrape Away"
        },
        Z = {
            AbilityName = "Stand Jump"
        },
        C = {
            AbilityName = "Void Pull"
        }
    }
}

--// SETUP - run this once when the stand is equipped
function TheHand.SetupPower(initPlayer,params)
    Knit.Services.StateService:AddEntryToState(initPlayer, "WalkSpeed", "TheHand_Setup", 2, nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Health", "TheHand_Setup", TheHand.Defs.HealthModifier[params.Rank], nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Multiplier_Damage", "TheHand_Setup", TheHand.Defs.DamageMultiplier[params.Rank], nil)
end

--// REMOVE - run this once when the stand is un-equipped
function TheHand.RemovePower(initPlayer,params)
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "WalkSpeed", "TheHand_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Health", "TheHand_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Multiplier_Damage", "TheHand_Setup")
end

--// MANAGER - this is the single point of entry from PowersService and PowersController.
function TheHand.Manager(params)

    -- call the function
    if params.InputId == "Q" then
        TheHand.EquipStand(params)
    elseif params.InputId == "E" then
        TheHand.Barrage(params)
    elseif params.InputId == "R" then
        TheHand.ScrapePunch(params)
    elseif params.InputId == "T" then
        TheHand.FlowerPotBarrage(params)
    elseif params.InputId == "F" then
        TheHand.ScrapeBarrage(params)
    elseif params.InputId == "X" then
        TheHand.ScrapeAway(params)
    elseif params.InputId == "Z" then
        TheHand.StandJump(params)
    elseif params.InputId == "Mouse1" then
        TheHand.Punch(params)
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

function TheHand.EquipStand(params)
    params = require(Knit.Abilities.ManageStand)[params.SystemStage](params, TheHand.Defs.Abilities.Q)
end

--------------------------------------------------------------------------------------------------
--// BARRAGE - E //----------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
TheHand.Defs.Abilities.Barrage = {
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

function TheHand.Barrage(params)
    params = require(Knit.Abilities.Barrage)[params.SystemStage](params, TheHand.Defs.Abilities.Barrage)
end

--------------------------------------------------------------------------------------------------
--// ScrapePunch - R//------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

--defs
TheHand.Defs.Abilities.ScrapePunch = {
    Name = "ScrapePunch",
    Id = "ScrapePunchh",
    Cooldown = 10,
    RequireToggle_On = {"Q"},
    HitEffects = {Damage = {Damage = 30}, PinCharacter = {Duration = 5.5}, AngeloRock = {Duration = 5}},
    Sounds = {
        Punch = ReplicatedStorage.Audio.StandSpecific.TheWorld.HeavyPunch,
    }
}

function TheHand.ScrapePunch(params)
    --params = require(Knit.Abilities.HeavyPunch)[params.SystemStage](params, TheHand.Defs.Abilities.StonePunch)
end

--------------------------------------------------------------------------------------------------
--// FlowerPotBarrage - T //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
TheHand.Defs.Abilities.TreeCage = {
    Name = "FlowerPotBarrage",
    Id = "FlowerPotBarrage",
    Cooldown = 6,
    RequireToggle_On = {"Q"},
    HitEffects = {Damage = {Damage = 8}},
}

function TheHand.FlowerPotBarrage(params)
    --params = require(Knit.Abilities.BulletBarrage)[params.SystemStage](params, TheHand.Defs.Abilities.BulletBarrage)
end


--------------------------------------------------------------------------------------------------
--// ScrapeBarrage - F //---------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
TheHand.Defs.Abilities.ScrapeBarrage = {
    Name = "ScrapeBarrage",
    Id = "ScrapeBarrage",
    RequireToggle_On = {"Q"},
    Cooldown = 6,
    Duration = 5,
    HitEffects = {Damage = {Damage = 20}, Blast = {}, KnockBack = {Force = 70, ForceY = 50}},
}

function TheHand.ScrapeBarrage(params)
    --params = require(Knit.Abilities.WallBlast)[params.SystemStage](params, TheHand.Defs.Abilities.WallBlast)
end

--------------------------------------------------------------------------------------------------
--// ScrapeAway - X //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
TheHand.Defs.Abilities.ScrapeAway = {
    Name = "ScrapeAway",
    Id = "ScrapeAway",
    RequireToggle_On = {"Q"},
    Cooldown = 90,
    Duration = 20,
    Multiplier = 2
}

function TheHand.ScrapeAway(params)
    params = require(Knit.Abilities.RageBoost)[params.SystemStage](params, TheHand.Defs.Abilities.RageBoost)
end

--------------------------------------------------------------------------------------------------
--// STAND JUMP - Z //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
TheHand.Defs.Abilities.StandJump = {
    Name = "Stand Jump",
    Id = "StandJump",
    Cooldown = 3,
    RequireToggle_On = {"Q"},
}

function TheHand.StandJump(params)
    params = require(Knit.Abilities.StandJump)[params.SystemStage](params, TheHand.Defs.Abilities.StandJump)
end

--------------------------------------------------------------------------------------------------
--// Teleport - C //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
TheHand.Defs.Abilities.Teleport = {
    Name = "Teleport",
    Id = "Teleport",
    Cooldown = 3,
    RequireToggle_On = {"Q"},
}

function TheHand.Teleport(params)
    --params = require(Knit.Abilities.StandJump)[params.SystemStage](params, GoldExperience.Defs.Abilities.StandJump)
end

--------------------------------------------------------------------------------------------------
--// PUNCH - Mouse1 //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
TheHand.Defs.Abilities.Punch = {
    Name = "Punch",
    Id = "Punch",
    HitEffects = {Damage = {Damage = 5}}
}

function TheHand.Punch(params)
    params = require(Knit.Abilities.Punch)[params.SystemStage](params, TheHand.Defs.Abilities.Punch)
end

return TheHand