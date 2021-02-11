-- KillerQueen
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

local KillerQueen = {}

KillerQueen.Defs = {
    PowerName = "Killer Queen",
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
function KillerQueen.SetupPower(initPlayer,params)
    Knit.Services.StateService:AddEntryToState(initPlayer, "WalkSpeed", "KillerQueen_Setup", 2, nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Health", "KillerQueen_Setup", KillerQueen.Defs.HealthModifier[params.Rarity], nil)
end

--// REMOVE - run this once when the stand is un-equipped
function KillerQueen.RemovePower(initPlayer,params)
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "WalkSpeed", "KillerQueen_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Health", "KillerQueen_Setup")
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
        Common = ReplicatedStorage.EffectParts.StandModels.KillerQueen_Common,
        Rare = ReplicatedStorage.EffectParts.StandModels.KillerQueen_Rare,
        Legendary = ReplicatedStorage.EffectParts.StandModels.KillerQueen_Legendary,
    },
    Sounds = {
        Equip = ReplicatedStorage.Audio.StandSpecific.KillerQueen.Summon,
        Remove =  ReplicatedStorage.Audio.Abilities.StandSummon,
    }
}

function KillerQueen.EquipStand(params)
    params.AbilityId = KillerQueen.Defs.Abilities.EquipStand.Id
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
    RequireToggle_On = {"StandEquipped"},
    HitEffects = {Damage = {Damage = 3}},
    Sounds = {
        Barrage = ReplicatedStorage.Audio.StandSpecific.KillerQueen.Barrage,
    }
}

function KillerQueen.Barrage(params)
    params.AbilityId = KillerQueen.Defs.Abilities.Barrage.Id
    params = require(Knit.Abilities.Barrage)[params.SystemStage](params, KillerQueen.Defs.Abilities.Barrage)
end

--------------------------------------------------------------------------------------------------
--// BOMB PUNCH - R//------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

--defs
KillerQueen.Defs.Abilities.BombPunch = {
    Name = "Bomb Punch",
    Id = "BombPunch",
    Cooldown = 1,
    RequireToggle_On = {"StandEquipped"},
    HitEffects = {Damage = {Damage = 10}, Blast = {}, KnockBack = {Force = 70, ForceY = 50}},
    Sounds = {
        Punch = ReplicatedStorage.Audio.StandSpecific.TheWorld.HeavyPunch,
    }
}

function KillerQueen.BombPunch(params)
    params.AbilityId = KillerQueen.Defs.Abilities.BombPunch.Id
    params = require(Knit.Abilities.HeavyPunch)[params.SystemStage](params, KillerQueen.Defs.Abilities.BombPunch)
end

--------------------------------------------------------------------------------------------------
--// EXPLOSIVE COIN - T //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
KillerQueen.Defs.Abilities.ExplosiveCoin = {
    Name = "Explosive Coin",
    Id = "ExplosiveCoin",
    Cooldown = 2,
    --RequireToggle_On = {"StandEquipped"},
    AbilityMod = Knit.AbilityMods.BasicGrenade_ExplosiveCoin,
}

function KillerQueen.ExplosiveCoin(params)
    params.AbilityId = KillerQueen.Defs.Abilities.ExplosiveCoin.Id
    params = require(Knit.Abilities.BasicGrenade)[params.SystemStage](params, KillerQueen.Defs.Abilities.ExplosiveCoin)
end


--------------------------------------------------------------------------------------------------
--// BITES THE DUST - F //---------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
KillerQueen.Defs.Abilities.BitesTheDust = {
    Name = "Bites The Dust",
    Id = "BitesTheDust",
    Cooldown = 1,
    RequireToggle_On = {"StandEquipped"},
}

function KillerQueen.BitesTheDust(params)
    params.AbilityId = KillerQueen.Defs.Abilities.BitesTheDust.Id
    params = require(Knit.Abilities.BitesTheDust)[params.SystemStage](params, KillerQueen.Defs.Abilities.BitesTheDust)
end


--------------------------------------------------------------------------------------------------
--// SHEER HEART ATTACK - X //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
KillerQueen.Defs.Abilities.SheerHeartAttack = {
    Name = "Sheer Heart Attack",
    Id = "SheerHeartAttack",
    Cooldown = 1,
    --RequireToggle_On = {"StandEquipped"},
    AbilityMod = Knit.AbilityMods.BasicSeeker_SheerHeartAttack,
}

function KillerQueen.SheerHeartAttack(params)
    params.AbilityId = KillerQueen.Defs.Abilities.SheerHeartAttack.Id
    params = require(Knit.Abilities.BasicSeeker)[params.SystemStage](params, KillerQueen.Defs.Abilities.SheerHeartAttack)
end

--------------------------------------------------------------------------------------------------
--// STAND JUMP - Z //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
KillerQueen.Defs.Abilities.StandJump = {
    Name = "Stand Jump",
    Id = "StandJump",
    Cooldown = 5,
    RequireToggle_On = {"StandEquipped"},
}

function KillerQueen.StandJump(params)
    params.AbilityId = KillerQueen.Defs.Abilities.StandJump.Id
    params = require(Knit.Abilities.StandJump)[params.SystemStage](params, KillerQueen.Defs.Abilities.StandJump)
end

--------------------------------------------------------------------------------------------------
--// PUNCH - Mouse1 //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
KillerQueen.Defs.Abilities.Punch = {
    Name = "Punch",
    Id = "Punch",
    HitEffects = {Damage = {Damage = 5}}
}

function KillerQueen.Punch(params)
    params.AbilityId = KillerQueen.Defs.Abilities.Punch.Id
    params = require(Knit.Abilities.Punch)[params.SystemStage](params, KillerQueen.Defs.Abilities.Punch)
end

return KillerQueen