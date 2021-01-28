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

    --params.AbilityDefs = TheWorld.Defs.Abilities.EquipStand
    params = require(Knit.Abilities.ManageStand)[params.SystemStage](params, TheWorld.Defs.Abilities.EquipStand)
end

--------------------------------------------------------------------------------------------------
--// BARRAGE //----------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
TheWorld.Defs.Abilities.Barrage = {
    Name = "Barrage",
    Duration = 5,
    Cooldown = 10,
    HitEffects = {Damage = {Damage = 5}},
    Sounds = {
        --Sound = sound here,
        --Sound2 = sound here
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
    Duration = 8,
    Cooldown = 9,
    Range = 150,
    HitEffects = {PinCharacter = {Duration = 8}, ColorShift = {Duration = 8}, BlockInput = {Name = "TimeStop", Duration = 8}}
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
    Cooldown = 2,
    Range = 75,
    Speed = 90,
    HitEffects = {Damage = {Damage = 20, HideEffects = true}}
}

function TheWorld.KnifeThrow(initPlayer,params)

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

function TheWorld.HeavyPunch(initPlayer,params)

    -- HEAVY PUNCH/INITIALIZE
    if params.SystemStage == "Initialize" then
        if params.KeyState == "InputBegan" then
            params.CanRun = true
        end
    end

    -- HEAVY PUNCH/ACTIVATE
    if params.SystemStage == "Activate" then

        -- require toggles to be active
        if not AbilityToggle.RequireOn(initPlayer,{"Q"}) then
            params.CanRun = false
            return params
        end

        -- require toggles to be inactive, excluding "Q"
        if not AbilityToggle.RequireOff(initPlayer,{"C","T","F","E","Z","X"}) then
            params.CanRun = false
            return params
        end

         if params.KeyState == "InputBegan" then
           
            -- cooldowns and toggles
            spawn(function()
                Cooldown.SetCooldown(initPlayer,params.InputId,TheWorld.Defs.Abilities.HeavyPunch.Cooldown)
                AbilityToggle.SetToggle(initPlayer,params.InputId,true)
                wait(2)
                AbilityToggle.SetToggle(initPlayer,params.InputId,false)
            end)

            -- activate ability
            params.HeavyPunch = TheWorld.Defs.Abilities.HeavyPunch
            HeavyPunch.Activate(initPlayer,params)

            params.CanRun = true
        end
    end

    -- HEAVY PUNCH/EXECUTE
    if params.SystemStage == "Execute" then
         if params.KeyState == "InputBegan" then

            local heavyPunchParams = TheWorld.Defs.Abilities.HeavyPunch
            HeavyPunch.Execute(initPlayer,heavyPunchParams)
            wait(.3)
            SoundPlayer.WeldSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.SFX.StandSounds.TheWorld.HeavyPunch)
        end

    end
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

function TheWorld.BulletKick(initPlayer,params)

    -- BULLET KICK/INITIALIZE
    if params.SystemStage == "Initialize" then
        if params.KeyState == "InputBegan" then
            params.CanRun = true
        end
    end

    -- BULLET KICK/ACTIVATE
    if params.SystemStage == "Activate" then

        -- require toggles to be active
        if not AbilityToggle.RequireOn(initPlayer,{"Q"}) then
            params.CanRun = false
            return params
        end

        -- require toggles to be inactive, excluding "Q"
        if not AbilityToggle.RequireOff(initPlayer,{"C","T","F","E","Z","R"}) then
            params.CanRun = false
            return params
        end

        if params.KeyState == "InputBegan" then

            -- set cooldown
            Cooldown.SetCooldown(initPlayer,params.InputId,TheWorld.Defs.Abilities.BulletKick.Cooldown)

            -- set toggles
        spawn(function()
            AbilityToggle.SetToggle(initPlayer,params.InputId,true)
            wait(1)
            AbilityToggle.SetToggle(initPlayer,params.InputId,false)
        end)

        --bulletKickParams = TheWorld.Defs.Abilities.BulletKick
        params.BulletKick = TheWorld.Defs.Abilities.BulletKick
        BulletKick.Activate(initPlayer,params)
        -- params.CanRun = true
        end
    end

    -- BULLET KICK/EXECUTE
    if params.SystemStage == "Execute" then
         if params.KeyState == "InputBegan" then
            BulletKick.Execute(initPlayer,params)
        end
    end
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

function TheWorld.StandJump(initPlayer,params)


    -- STAND JUMP/INITIALIZE
    if params.SystemStage == "Initialize" then
        if params.KeyState == "InputBegan" then
            params.CanRun = true
        end
    end

    -- STAND JUMP/ACTIVATE
    if params.SystemStage == "Activate" then

        -- require toggles to be active
        if not AbilityToggle.RequireOn(initPlayer,{"Q"}) then
            params.CanRun = false
            return params
        end

        -- require toggles to be inactive, excluding "Q"
        if not AbilityToggle.RequireOff(initPlayer,{"C","T","F","E","Z","R"}) then
            params.CanRun = false
            return params
        end
        
        -- STAND JUMP/ACTIVATE/INPUT BEGAN
        if params.KeyState == "InputBegan" then

        --bulletKickParams = TheWorld.Defs.Abilities.BulletKick
        params.StandJump = TheWorld.Defs.Abilities.StandJump
        
            -- set toggles and cooldowns
            spawn(function()
                Cooldown.SetCooldown(initPlayer,params.InputId,TheWorld.Defs.Abilities.StandJump.Cooldown)
                AbilityToggle.SetToggle(initPlayer,params.InputId,true)
                wait(1)
                AbilityToggle.SetToggle(initPlayer,params.InputId,false)
            end)

            StandJump.Activate(initPlayer,params)
            params.CanRun = true

        end

    end

    -- STAND JUMP/EXECUTE
    if params.SystemStage == "Execute" then
        if params.KeyState == "InputBegan" then
            StandJump.Execute(initPlayer,params)
        end
    end
end

--------------------------------------------------------------------------------------------------
--// PUNCH //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
TheWorld.Defs.Abilities.Punch = {
    Name = "Punch",
    HitEffects = {Damage = {Damage = 5}}
}

function TheWorld.Punch(initPlayer,params)

    -- PUNCH/INITIALIZE
    if params.SystemStage == "Initialize" then
        if params.KeyState == "InputBegan" then
            params.CanRun = true
        end
    end

    -- PUNCH/ACTIVATE
    if params.SystemStage == "Activate" then

        -- require toggles to be inactive, excluding "Q"
        if not AbilityToggle.RequireOff(initPlayer,{"C","T","F","E","Z","R","X","Mouse1"}) then
            params.CanRun = false
            return params
        end

        print("test 1")

         -- PUNCH/ACTIVATE/INPUT BEGAN
         if params.KeyState == "InputBegan" then

            -- set toggles and cooldown
            spawn(function()
                --Cooldown.SetCooldown(initPlayer, params.InputId, TheWorld.Defs.Abilities.Punch.Cooldown)
                AbilityToggle.SetToggle(initPlayer,params.InputId,true)
                wait(.75)
                AbilityToggle.SetToggle(initPlayer,params.InputId,false)
            end)

            params.Punch = TheWorld.Defs.Abilities.Punch
            Punch.Activate(initPlayer, params)
            params.CanRun = true

        end
    end

    -- PUNCH/EXECUTE
    if params.SystemStage == "Execute" then
        if params.KeyState == "InputBegan" then
            Punch.Execute(initPlayer,params)
        end
    end
end

return TheWorld