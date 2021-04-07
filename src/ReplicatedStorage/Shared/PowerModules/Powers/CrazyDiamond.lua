-- CrazyDiamond

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
--local utils = require(Knit.Shared.Utils)

local CrazyDiamond = {}

CrazyDiamond.Defs = {
    PowerName = "Crazy Diamond",
    MaxXp = {
        Common = 10000,
        Rare = 15000,
        Legendary = 20000
    },
    DamageMultiplier = {
        Common = 1,
        Rare = 1.5,
        Legendary = 2,
    },
    HealthModifier = {
        Common = 10,
        Rare = 30,
        Legendary = 70
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
            AbilityName = "Wall Blast"
        },
        T = {
            AbilityName = "Bullet Launch"
        },
        R = {
            AbilityName = "Stone Punch"
        },
        X = {
            AbilityName = "Rage Boost"
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
function CrazyDiamond.SetupPower(initPlayer,params)
    Knit.Services.StateService:AddEntryToState(initPlayer, "WalkSpeed", "CrazyDiamond_Setup", 2, nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Health", "CrazyDiamond_Setup", CrazyDiamond.Defs.HealthModifier[params.Rarity], nil)
end

--// REMOVE - run this once when the stand is un-equipped
function CrazyDiamond.RemovePower(initPlayer,params)
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "WalkSpeed", "CrazyDiamond_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Health", "CrazyDiamond_Setup")
end

--// MANAGER - this is the single point of entry from PowersService and PowersController.
function CrazyDiamond.Manager(params)

    -- call the function
    if params.InputId == "Q" then
        CrazyDiamond.EquipStand(params)
    elseif params.InputId == "E" then
        CrazyDiamond.Barrage(params)
    elseif params.InputId == "R" then
        CrazyDiamond.StonePunch(params)
    elseif params.InputId == "T" then
        CrazyDiamond.BulletLaunch(params)
    elseif params.InputId == "F" then
        CrazyDiamond.WallBlast(params)
    elseif params.InputId == "X" then
        CrazyDiamond.RageBoost(params)
    elseif params.InputId == "Z" then
        CrazyDiamond.StandJump(params)
    elseif params.InputId == "Mouse1" then
        CrazyDiamond.Punch(params)
    end

    return params
end

--------------------------------------------------------------------------------------------------
--// EQUIP STAND - Q //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
CrazyDiamond.Defs.Abilities.EquipStand = {
    Name = "Equip Stand",
    Id = "EquipStand",
    Cooldown = 5,
    StandModels = {
        Common = ReplicatedStorage.EffectParts.StandModels.CrazyDiamond_Common,
        Rare = ReplicatedStorage.EffectParts.StandModels.CrazyDiamond_Rare,
        Legendary = ReplicatedStorage.EffectParts.StandModels.CrazyDiamond_Legendary,
    },
    Sounds = {
        Equip = ReplicatedStorage.Audio.Abilities.StandSummon,
        Remove =  ReplicatedStorage.Audio.Abilities.StandSummon,
    }
}

function CrazyDiamond.EquipStand(params)
    params = require(Knit.Abilities.ManageStand)[params.SystemStage](params, CrazyDiamond.Defs.Abilities.EquipStand)
end

--------------------------------------------------------------------------------------------------
--// BARRAGE - E //----------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
CrazyDiamond.Defs.Abilities.Barrage = {
    Name = "Barrage",
    Id = "Barrage",
    Duration = 4,
    Cooldown = 7,
    RequireToggle_On = {"StandEquipped"},
    HitEffects = {Damage = {Damage = 3}},
    Sounds = {
        Barrage = ReplicatedStorage.Audio.Abilities.GenericBarrage,
    }
}

function CrazyDiamond.Barrage(params)
    params = require(Knit.Abilities.Barrage)[params.SystemStage](params, CrazyDiamond.Defs.Abilities.Barrage)
end

--------------------------------------------------------------------------------------------------
--// Stone Punch - R//------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

--defs
CrazyDiamond.Defs.Abilities.StonePunch = {
    Name = "Stone Punch",
    Id = "StonePunch",
    Cooldown = 5,
    RequireToggle_On = {"StandEquipped"},
    HitEffects = {Damage = {Damage = 30}, PinCharacter = {Duration = 5.5}, AngeloRock = {Duration = 5}},
    Sounds = {
        Punch = ReplicatedStorage.Audio.StandSpecific.TheWorld.HeavyPunch,
    }
}

function CrazyDiamond.StonePunch(params)
    params = require(Knit.Abilities.HeavyPunch)[params.SystemStage](params, CrazyDiamond.Defs.Abilities.StonePunch)
end

--------------------------------------------------------------------------------------------------
--// Bullet Launch - T //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
CrazyDiamond.Defs.Abilities.BulletLaunch = {
    Name = "Bullet Launch",
    Id = "BulletLaunch",
    Cooldown = 8,
    RequireToggle_On = {"StandEquipped"},
    --AbilityMod = Knit.AbilityMods.BasicGrenade_BulletLaunch,
}

function CrazyDiamond.BulletLaunch(params)
    --params = require(Knit.Abilities.BasicGrenade)[params.SystemStage](params, CrazyDiamond.Defs.Abilities.BulletLaunch)
end


--------------------------------------------------------------------------------------------------
--// Wall Blast - F //---------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
CrazyDiamond.Defs.Abilities.WallBlast = {
    Name = "Wall Blast",
    Id = "WallBlast",
    Cooldown = 20,
    RequireToggle_On = {"StandEquipped"},
}

function CrazyDiamond.WallBlast(params)
    --params = require(Knit.Abilities.WallBlast)[params.SystemStage](params, CrazyDiamond.Defs.Abilities.WallBlast)
end


--------------------------------------------------------------------------------------------------
--// Rage Boost - X //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
CrazyDiamond.Defs.Abilities.RageBoost = {
    Name = "Rage Boost",
    Id = "RageBoost",
    Cooldown = 15,
}

function CrazyDiamond.RageBoost(params)
    --params = require(Knit.Abilities.BasicSeeker)[params.SystemStage](params, CrazyDiamond.Defs.Abilities.RageBoost)
end

--------------------------------------------------------------------------------------------------
--// STAND JUMP - Z //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
CrazyDiamond.Defs.Abilities.StandJump = {
    Name = "Stand Jump",
    Id = "StandJump",
    Cooldown = 3,
    RequireToggle_On = {"StandEquipped"},
}

function CrazyDiamond.StandJump(params)
    params = require(Knit.Abilities.StandJump)[params.SystemStage](params, CrazyDiamond.Defs.Abilities.StandJump)
end

--------------------------------------------------------------------------------------------------
--// PUNCH - Mouse1 //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
CrazyDiamond.Defs.Abilities.Punch = {
    Name = "Punch",
    Id = "Punch",
    HitEffects = {Damage = {Damage = 5}}
}

function CrazyDiamond.Punch(params)
    params = require(Knit.Abilities.Punch)[params.SystemStage](params, CrazyDiamond.Defs.Abilities.Punch)
end

return CrazyDiamond