-- TheWorld
-- PDab
-- 11/12/2020
--[[
Handles all thing related to the power and is triggered by BOTH PowersController AND PowerService
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

--[[
-- Ability modules
local ManageStand = require(Knit.Abilities.ManageStand)
local Barrage = require(Knit.Abilities.Barrage)
local TimeStop = require(Knit.Abilities.TimeStop)
local KnifeThrow = require(Knit.Abilities.KnifeThrow)
local HeavyPunch = require(Knit.Abilities.HeavyPunch)
local BulletKick = require(Knit.Abilities.BulletKick)
local StandJump = require(Knit.Abilities.StandJump)
local Punch = require(Knit.Abilities.Punch)
]]--

-- Effect modules
local AbilityToggle = require(Knit.PowerUtils.AbilityToggle)
local SoundPlayer = require(Knit.PowerUtils.SoundPlayer)
local Cooldown = require(Knit.PowerUtils.Cooldown)


local TheWorld = {}

TheWorld.Defs = {

    -- just some general defs here
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
    print("setup", params)
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

    -- check cooldowns
    if params.SystemStage == "Initialize" or params.SystemStage == "Activate" then
        if not Cooldown.Client_IsCooled(params) then
            params.CanRun = false
            return
        end
    end

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
        --Equip = sound here,
        --Remove = sound here
    }
}

function TheWorld.EquipStand(params)

    print("stand params 1", params)
    params = require(Knit.Abilities.ManageStand)[params.SystemStage](params, TheWorld.Defs.Abilities.EquipStand)
    print("stand params 2", params)
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
    RequireToggle_On = {"Q"},
    RequireToggle_Off = {"C","R","T","F","Z","X"},
    HitEffects = {Damage = {Damage = 5}},
    Sounds = {
        --Sound = sound here,
        --Sound2 = sound here
    }
}

function TheWorld.Barrage(params)

    print("barrage params 1", params)
    params = require(Knit.Abilities.Barrage)[params.SystemStage](params, TheWorld.Defs.Abilities.Barrage)
    print("barrage params 2", params)
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
    RequireToggle_On = {"Q"},
    RequireToggle_Off = {"C","R","T","E","Z","X"},
    HitEffects = {PinCharacter = {Duration = 8}, ColorShift = {Duration = 8}, BlockInput = {Name = "TimeStop", Duration = 8}},
    Sounds = {
        --Sound = sound here,
        --Sound2 = sound here
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
    Cooldown = 2,
    Range = 75,
    Speed = 90,
    Projectile = ReplicatedStorage.EffectParts.Abilities.BasicProjectile.KnifeThrow.Effect,
    HitBox = ReplicatedStorage.EffectParts.Abilities.BasicProjectile.KnifeThrow.Hitbox,
    RequireToggle_On = {"Q"},
    RequireToggle_Off = {"C","R","F","E","Z","X"},
    HitEffects = {Damage = {Damage = 20, HideEffects = true}},
    Sounds = {
        --Sound = sound here,
        --Sound2 = sound here
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
    Cooldown = 10,
    HitEffects = {Damage = {Damage = 10}, ColorShift = {Duration = 3}, PinCharacter = {Duration = 3}, BlockInput = {Name = "HeavyPunch", Duration = 3}, SphereFields = {Size = 7, Duration = 3,RandomColor = true, Repeat = 1}}
}

function TheWorld.HeavyPunch(params)

end

--------------------------------------------------------------------------------------------------
--// BULLET KICK //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
TheWorld.Defs.Abilities.BulletKick = {
    Name = "Bullet Kick",
    Cooldown = 5,
    HitEffects = {Damage = {Damage = 10}, KnockBack = {Force = 100, Duration = 0.2}}
}

function TheWorld.BulletKick(params)

  
end

--------------------------------------------------------------------------------------------------
--// STAND JUMP //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
TheWorld.Defs.Abilities.StandJump = {
    Name = "Stand Jump",
    Duration = .3,
    Cooldown = 5,
    Velocity_XZ = 2700,
    Velocity_Y = 500
}

function TheWorld.StandJump(params)

end

--------------------------------------------------------------------------------------------------
--// PUNCH //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
TheWorld.Defs.Abilities.Punch = {
    Name = "Punch",
    HitEffects = {Damage = {Damage = 5}}
}

function TheWorld.Punch(params)

end

return TheWorld