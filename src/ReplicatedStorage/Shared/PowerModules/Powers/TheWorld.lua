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

-- Ability modules
local ManageStand = require(Knit.Abilities.ManageStand)
local Barrage = require(Knit.Abilities.Barrage)
local TimeStop = require(Knit.Abilities.TimeStop)
local KnifeThrow = require(Knit.Abilities.KnifeThrow)
local HeavyPunch = require(Knit.Abilities.HeavyPunch)
local BulletKick = require(Knit.Abilities.BulletKick)
local StandJump = require(Knit.Abilities.StandJump)
local Punch = require(Knit.Abilities.Punch)

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
    
    StandModels = {
        Common = ReplicatedStorage.EffectParts.StandModels.TheWorld_Common,
        Rare = ReplicatedStorage.EffectParts.StandModels.TheWorld_Rare,
        Legendary = ReplicatedStorage.EffectParts.StandModels.TheWorld_Legendary,
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
function TheWorld.Manager(initPlayer,params)

    -- check cooldowns but only on SystemStage "Activate"
    if params.SystemStage == "Activate" then
        if Cooldown.IsCooled(initPlayer, params) then
            params.CanRun = true
        else
            params.CanRun = false
            return params
        end
    end

    -- check cooldowns
    if params.SystemStage == "Initialize" or params.SystemStage == "Activate" then
        if not Cooldown.Client_IsCooled(params) then
            params.CanRun = false
            return
        end
    end

    -- call the function
    if params.InputId == "Q" then
        TheWorld.EquipStand(initPlayer,params)
    elseif params.InputId == "E" then
        TheWorld.Barrage(initPlayer,params)
    elseif params.InputId == "F" then
        TheWorld.TimeStop(initPlayer,params)
    elseif params.InputId == "T" then
        TheWorld.KnifeThrow(initPlayer,params)
    elseif params.InputId == "R" then
        TheWorld.HeavyPunch(initPlayer,params)
    elseif params.InputId == "X" then
        TheWorld.BulletKick(initPlayer,params)
    elseif params.InputId == "Z" then
        TheWorld.StandJump(initPlayer,params)
    elseif params.InputId == "Mouse1" then
        TheWorld.Punch(initPlayer,params)
    end

    return params
end

--------------------------------------------------------------------------------------------------
--// EQUIP STAND //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
TheWorld.Defs.Abilities.EquipStand = {
    Name = "Equip Stand",
<<<<<<< HEAD
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
=======
    Cooldown = 5
>>>>>>> parent of 63c32ff... do eeeeet
}

function TheWorld.EquipStand(initPlayer,params)

    -- EQUIP STAND/INITIALIZE
    if params.SystemStage == "Initialize" then
        if params.KeyState == "InputBegan" then
            params.CanRun = true
        end
    end

    -- EQUIP STAND/ACTIVATE
    if params.SystemStage == "Activate" then
         if params.KeyState == "InputBegan" then

            -- set cooldown
            Cooldown.SetCooldown(initPlayer,params.InputId,TheWorld.Defs.Abilities.EquipStand.Cooldown)

<<<<<<< HEAD
    print("stand params 1", params)
    params = require(Knit.Abilities.ManageStand)[params.SystemStage](params, TheWorld.Defs.Abilities.EquipStand)
    print("stand params 2", params)
=======
            -- toggle the stand, effect runs off of this toggle
            if AbilityToggle.GetToggleObject(initPlayer,params.InputId).Value == true then
                AbilityToggle.SetToggle(initPlayer,params.InputId,false)
            else
                AbilityToggle.SetToggle(initPlayer,params.InputId,true)
            end
        end
    end

    -- EQUIP STAND/EXECUTE
    if params.SystemStage == "Execute" then
         if params.KeyState == "InputBegan" then
            if AbilityToggle.GetToggleObject(initPlayer,params.InputId).Value == true then
                SoundPlayer.WeldSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.SFX.StandSounds.TheWorld.Summon) -- specific stand sound
                ManageStand.EquipStand(initPlayer,TheWorld.Defs.StandModels[params.PowerRarity])
            else
                SoundPlayer.WeldSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.SFX.GeneralStandSounds.StandSummon) -- specific stand sound
                ManageStand.RemoveStand(initPlayer)            
            end
        end
    end
>>>>>>> parent of 63c32ff... do eeeeet
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
<<<<<<< HEAD
    RequireToggle_On = {"Q"},
    RequireToggle_Off = {"C","R","T","F","Z","X"},
    HitEffects = {Damage = {Damage = 5}},
    Sounds = {
        --Sound = sound here,
        --Sound2 = sound here
    }
=======
    --loopTime = .25,
    HitEffects = {Damage = {Damage = 5}}
>>>>>>> parent of 63c32ff... do eeeeet
}

function TheWorld.Barrage(initPlayer,params)

    print("run barrage")

    -- BARRAGE/INIALIZE
    print("test 1")
    if params.SystemStage == "Initialize" then
        if params.KeyState == "InputBegan" then
            print("test 2")
            params.CanRun = true
        end
        if params.KeyState == "InputEnded" then
            print("test 3")
            params.CanRun = true
        end
    end

    -- BARRAGE/ACTIVATE
    if params.SystemStage == "Activate" then

        -- BARRAGE/ACTIVATE/INPUT BEGAN
        if params.KeyState == "InputBegan" then

            -- require toggles to be active
            if not AbilityToggle.RequireOn(initPlayer,{"Q"}) then
                params.CanRun = false
                return params
            end

<<<<<<< HEAD
    print("barrage params 1", params)
    params = require(Knit.Abilities.Barrage)[params.SystemStage](params, TheWorld.Defs.Abilities.Barrage)
    print("barrage params 2", params)
=======
            -- require toggles to be inactive, excluding "Q"
            if not AbilityToggle.RequireOff(initPlayer,{"C","R","T","F","Z","X"}) then
                params.CanRun = false
                return params
            end

            -- only operate if toggle is off
            if AbilityToggle.GetToggleValue(initPlayer,params.InputId) == false then
                AbilityToggle.SetToggle(initPlayer,params.InputId,true)
                params.CanRun = true
      
                params.Barrage = TheWorld.Defs.Abilities.Barrage
                Barrage.Activate(initPlayer, params)

                -- spawn a function to kill the barrage if the duration expires
                spawn(function()
                    wait(TheWorld.Defs.Abilities.Barrage.Duration)
                    params.KeyState = "InputEnded"
                    params.CanRun = true
                    Knit.Services.PowersService:ActivatePower(initPlayer,params)
                end)
            end
        end

        -- BARRAGE/ACTIVATE/INPUT ENDED
        if params.KeyState == "InputEnded" then

            -- only operate if toggle is on
            if AbilityToggle.GetToggleValue(initPlayer,params.InputId) == true then

                -- set the cooldown
                Cooldown.SetCooldown(initPlayer,params.InputId,TheWorld.Defs.Abilities.Barrage.Cooldown)

                -- set toggle
                AbilityToggle.SetToggle(initPlayer,params.InputId,false)
                params.CanRun = true

                -- destroy hitbox
                Barrage.DestroyHitbox(initPlayer, TheWorld.Defs.Abilities.Barrage)
            end
        end
    end

    -- BARRAGE/EXECUTE
    if params.SystemStage == "Execute" then

        -- BARRAGE/EXECUTE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
            if AbilityToggle.GetToggleValue(initPlayer,params.InputId) == true then
                Barrage.RunEffect(initPlayer,params)

                local soundParams = {}
                soundParams.SoundProperties = {}
                soundParams.SoundProperties.Looped = false
                SoundPlayer.WeldSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.SFX.StandSounds.TheWorld.Barrage, soundParams)
            end
        end

        -- BARRAGE/EXECUTE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            if AbilityToggle.GetToggleValue(initPlayer,params.InputId) == false then
                Barrage.EndEffect(initPlayer,params)
                SoundPlayer.StopWeldedSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.SFX.StandSounds.TheWorld.Barrage.Name,.5)
            end 
        end
    end
>>>>>>> parent of 63c32ff... do eeeeet
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

function TheWorld.TimeStop(initPlayer,params)

    -- TIME STOP/INIALIZE
    if params.SystemStage == "Initialize" then
        if params.KeyState == "InputBegan" then
            params.CanRun = true
        end
    end

    -- TIME STOP/ACTIVATE
    if params.SystemStage == "Activate" then

        -- require toggles to be active
        if not AbilityToggle.RequireOn(initPlayer,{"Q"}) then
            params.CanRun = false
            return params
        end

        -- require toggles to be inactive, excluding "Q"
        if not AbilityToggle.RequireOff(initPlayer,{"C","R","T","E","Z","X"}) then
            params.CanRun = false
            return params
        end

        -- TIME STOP/ACTIVATE/INPUT BEGAN
        if params.KeyState == "InputBegan" then

            spawn(function()
                Cooldown.SetCooldown(initPlayer, params.InputId, TheWorld.Defs.Abilities.TimeStop.Cooldown)
                AbilityToggle.SetToggle(initPlayer, params.InputId, true)
                wait(2) -- this waits for the animations and audio before firing
                params.TimeStop = TheWorld.Defs.Abilities.TimeStop
                TimeStop.Activate(initPlayer,params)
                wait(1)
                AbilityToggle.SetToggle(initPlayer, params.InputId, false)
            end)

            params.CanRun = true

<<<<<<< HEAD
    params = require(Knit.Abilities.TimeStop)[params.SystemStage](params, TheWorld.Defs.Abilities.TimeStop)
=======
        end
    end

    -- TIME STOP/EXECUTE
    if params.SystemStage == "Execute" then
        if params.KeyState == "InputBegan" then

            ManageStand.PlayAnimation(initPlayer,params,"TimeStop")
            SoundPlayer.WeldSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.SFX.StandSounds.TheWorld.TimeStop)
            wait(2) -- wait here for the timestop audio
            local timeStopParams = TheWorld.Defs.Abilities.TimeStop
            TimeStop.Execute(initPlayer,timeStopParams)
        end
    end
>>>>>>> parent of 63c32ff... do eeeeet
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

<<<<<<< HEAD
    params = require(Knit.Abilities.BasicProjectile)[params.SystemStage](params, TheWorld.Defs.Abilities.KnifeThrow)
=======
    -- KNIFE THROW/INITIALIZE
    if params.SystemStage == "Initialize" then
        if params.KeyState == "InputBegan" then
            params.CanRun = true
        end
    end

    -- KNIFE THROW/ACTIVATE
    if params.SystemStage == "Activate" then

        -- require toggles to be active
        if not AbilityToggle.RequireOn(initPlayer,{"Q"}) then
            params.CanRun = false
            return params
        end

        -- require toggles to be inactive, excluding "Q"
        if not AbilityToggle.RequireOff(initPlayer,{"C","R","F","E","Z","X"}) then
            params.CanRun = false
            return params
        end

         -- KNIFE THROW/ACTIVATE/INPUT BEGAN
         if params.KeyState == "InputBegan" then

            spawn(function()
                Cooldown.SetCooldown(initPlayer,params.InputId,TheWorld.Defs.Abilities.KnifeThrow.Cooldown)
                AbilityToggle.SetToggle(initPlayer,params.InputId,true)
                wait(1)
                AbilityToggle.SetToggle(initPlayer,params.InputId,false)
            end)

            params.KnifeThrow = TheWorld.Defs.Abilities.KnifeThrow
            KnifeThrow.Server_Activate(initPlayer,params)

            params.CanRun = true
        end
    end

    -- KNIFE THROW/EXECUTE
    if params.SystemStage == "Execute" then
         if params.KeyState == "InputBegan" then
            SoundPlayer.WeldSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.SFX.GeneralStandSounds.GenericKnifeThrow)
            KnifeThrow.Client_Execute(initPlayer,params)
        end
    end
>>>>>>> parent of 63c32ff... do eeeeet
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