-- TheWorld
-- PDab
-- 11/12/2020
--[[
Handles all thing related to the power and is triggered by BOTH PowersController AND PowerService
]]

-- roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
--local utils = require(Knit.Shared.Utils)

local TheWorld = {}

TheWorld.Defs = {
    PowerName = "The World",
    SacrificeValue = {
        Common = 10,
        Rare = 20,
        Legendary = 40,
    },
    DamageMultiplier = {
        Common = 1,
        Rare = 2,
        Legendary = 3,
    },
    HealthModifier = {
        Common = 10,
        Rare = 30,
        Legendary = 70
    },
    Abilities = {} -- ability defs are inside each ability function area
}

--// SETUP - run this once when the stand is equipped
function TheWorld.SetupPower(initPlayer,params)
    Knit.Services.StateService:AddEntryToState(initPlayer, "WalkSpeed", "TheWorld_Setup", 2, nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Immunity", "TheWorld_Setup", 2, {TimeStop = true})
    Knit.Services.StateService:AddEntryToState(initPlayer, "Health", "TheWorld_Setup", TheWorld.Defs.HealthModifier[params.Rarity], nil)
end

--// REMOVE - run this once when the stand is un-equipped
function TheWorld.RemovePower(initPlayer,params)
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "WalkSpeed", "TheWorld_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Immunity", "TheWorld_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Health", "TheWorld_Setup")
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
        TheWorld.TimeStop(params)
    elseif params.InputId == "T" then
        TheWorld.KnifeThrow(params)
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
        Common = ReplicatedStorage.EffectParts.StandModels.TheWorld_Common,
        Rare = ReplicatedStorage.EffectParts.StandModels.TheWorld_Rare,
        Legendary = ReplicatedStorage.EffectParts.StandModels.TheWorld_Legendary,
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
    Cooldown = 10,
    RequireToggle_On = {"StandEquipped"},
    HitEffects = {Damage = {Damage = 5}},
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
    Cooldown = 9,
    Range = 150,
    RequireToggle_On = {"StandEquipped"},
    HitEffects = {PinCharacter = {Duration = 8}, ColorShift = {Duration = 8}, BlockInput = {Name = "TimeStop", Duration = 8}},
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
    Name = "Knife Throw",
    Id = "KnifeThrow",
    Cooldown = 5,
    Range = 75,
    Speed = 90,
    Projectile = ReplicatedStorage.EffectParts.Abilities.BasicProjectile.KnifeThrow.Projectile,
    HitBox = ReplicatedStorage.EffectParts.Abilities.BasicProjectile.KnifeThrow.Hitbox,
    StandAnimation = "KnifeThrow",
    StandMove = {
        PositionName = "Front",
        ReturnDelay = 0.5,
    },
    RequireToggle_On = {"StandEquipped"},
    HitEffects = {Damage = {Damage = 20}},
    Sounds = {
        Shoot = ReplicatedStorage.Audio.General.GenericWhoosh_Slow
    }
}

function TheWorld.KnifeThrow(params)

    params = require(Knit.Abilities.BasicProjectile)[params.SystemStage](params, TheWorld.Defs.Abilities.KnifeThrow)
end

--------------------------------------------------------------------------------------------------
--// HEAVY PUNCH //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

--defs
TheWorld.Defs.Abilities.HeavyPunch = {
    Name = "Heavy Punch",
    Id = "HeavyPunch",
    Cooldown = 5,
    RequireToggle_On = {"StandEquipped"},
    HitEffects = {Damage = {Damage = 10}, ColorShift = {Duration = 3}, PinCharacter = {Duration = 3}, BlockInput = {Name = "HeavyPunch", Duration = 3}, SphereFields = {Size = 7, Duration = 3,RandomColor = true, Repeat = 1}},
    Sounds = {
        Punch = ReplicatedStorage.Audio.StandSpecific.TheWorld.HeavyPunch,
    }
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
    RequireToggle_On = {"StandEquipped"},
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
    Cooldown = 5,
    RequireToggle_On = {"StandEquipped"},
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
    HitEffects = {Damage = {Damage = 5}},
    --RequireToggle_On = {},
    --RequireToggle_Off = {"Mouse1"},
}

function TheWorld.Punch(params)

    params = require(Knit.Abilities.Punch)[params.SystemStage](params, TheWorld.Defs.Abilities.Punch)
end

return TheWorld