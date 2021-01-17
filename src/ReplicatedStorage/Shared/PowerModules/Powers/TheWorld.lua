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

-- Effect modules
local AbilityToggle = require(Knit.Effects.AbilityToggle)
local Cooldown = require(Knit.Effects.Cooldown)
local SoundPlayer = require(Knit.Effects.SoundPlayer)

-- variables
local playerStandFolder -- defined up here so all functions can use it
local thisStand -- defined up here so all functions can use it

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

    Abilities = {

        EquipStand = {
            Name = "Equip Stand",
            Cooldown = 1
        },

        Barrage = {
            Name = "Barrage",
            Duration = 5,
            Cooldown = 10,
            loopTime = .25,
            HitEffects = {Damage = {Damage = 5}}
        },

        TimeStop = {
            Name = "Time Stop",
            Duration = 8,
            Cooldown = 20,
            Range = 150,
            HitEffects = {PinCharacter = {Duration = 8}, ColorShift = {Duration = 8}, BlockInput = {Name = "TimeStop", Duration = 8}}
        },

       KnifeThrow = {
            Name = "Knife Throw",
            Cooldown = 8,
            Range = 75,
            Speed = 60,
            HitEffects = {Damage = {Damage = 20}}
        },

        HeavyPunch = {
            Name = "Heavy Punch",
            Cooldown = 10,
            HitEffects = {Damage = {Damage = 10}, ColorShift = {Duration = 1.5}, PinCharacter = {Duration = 1.5}, BlockInput = {Name = "HeavyPunch", Duration = 1.5}, SphereFields = {Size = 7, Duration = 1.5,RandomColor = true, Repeat = 3}}
        },

        BulletKick = {
            Name = "Bullet Kick",
            Cooldown = 1,
            HitEffects = {Damage = {Damage = 10}, KnockBack = {Force = 100, Duration = 0.2}}
        },

        StandJump = {
            Name = "Stand Jump",
            Duration = .3,
            Cooldown = 5,
            Velocity_XZ = 2700,
            Velocity_Y = 500
        },

        Ability_8 = {
            Name = "Ability 8",
            Duration = 0,
            Cooldown = 1,
        },
    }
}

--// SETUP - run this once when the stand is equipped
function TheWorld.SetupPower(initPlayer,params)
    Knit.Services.StateService:AddEntryToState(initPlayer, "WalkSpeed", "TheWorld_Setup", 2, nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Immunity", "TheWorld_Setup", 2, {TimeStop = true})
end

--// REMOVE - run this once when the stand is un-equipped
function TheWorld.RemovePower(initPlayer,params)
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "WalkSpeed", "TheWorld_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Immunity", "TheWorld_Setup")
end

--// MANAGER - this is the single point of entry from PowersService and PowersController.
function TheWorld.Manager(initPlayer,params)

    -- check cooldowns but only on SystemStage "Activate"
    if params.SystemStage == "Activate" then
        local cooldown = Cooldown.GetCooldownValue(initPlayer, params)
        if os.time() <= cooldown then
            params.CanRun = false
            return params
        end
    end

    -- get these here, they were decalred at the top but we set them here as the player enter the chain of functions
    playerStandFolder = workspace.PlayerStands:FindFirstChild(initPlayer.UserId)
    thisStand = playerStandFolder:FindFirstChildWhichIsA("Model")

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
    end

    return params
end

--------------------------------------------------------------------------------------------------
--// EQUIP STAND //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

function TheWorld.EquipStand(initPlayer,params)

 
    -- EQUIP STAND/INITIALIZE
    if params.SystemStage == "Intialize" then

        -- EQUIP STAND/INITIALIZE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
            params.CanRun = true
        end

        -- EQUIP STAND/INITIALIZE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            params.CanRun = false
        end
    end

    -- EQUIP STAND/ACTIVATE
    if params.SystemStage == "Activate" then

         -- EQUIP STAND/ACTIVATE/INPUT BEGAN
         if params.KeyState == "InputBegan" then

            -- set cooldown
            Cooldown.SetCooldown(initPlayer,params.InputId,TheWorld.Defs.Abilities.EquipStand.Cooldown)

            -- toggle the stand, effect runs off of this toggle
            if AbilityToggle.GetToggleObject(initPlayer,params.InputId).Value == true then
                AbilityToggle.SetToggle(initPlayer,params.InputId,false)
            else
                AbilityToggle.SetToggle(initPlayer,params.InputId,true)
            end
            
            params.CanRun = true
        end

        -- EQUIP STAND/ACTIVATE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            params.CanRun = false
        end
    end

    -- EQUIP STAND/EXECUTE
    if params.SystemStage == "Execute" then
        print("The World - Equip Stand - Execute")

         -- EQUIP STAND/EXECUTE/INPUT BEGAN
         if params.KeyState == "InputBegan" then
            if AbilityToggle.GetToggleObject(initPlayer,params.InputId).Value == true then
                SoundPlayer.WeldSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.SFX.StandSounds.TheWorld.Summon) -- specific stand sound
                ManageStand.EquipStand(initPlayer,TheWorld.Defs.StandModels[params.PowerRarity])
            else
                SoundPlayer.WeldSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.SFX.GeneralStandSounds.StandSummon) -- specific stand sound
                ManageStand.RemoveStand(initPlayer)            
            end
        end

        -- EQUIP STAND/EXECUTE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            -- no action here
        end
    end
end

--------------------------------------------------------------------------------------------------
--// BARRAGE //----------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

function TheWorld.Barrage(initPlayer,params)

    -- server actions
    if RunService:IsServer() then
        -- requires Stand to be active via "Q" toggle
        if not AbilityToggle.RequireTrue(initPlayer,{"Q"}) then
            print("Stand not active, cannot run this ability")
            params.CanRun = false
            return params
        end

        -- require toggles to be inactive, excluding "Q"
        if params.KeyState == "InputBegan" then -- we had to do this on InputBegan ONLY because of the funny way Barrage toggles
            if not AbilityToggle.RequireFalse(initPlayer,{"E","R","T","F","Z","X"}) then
                print("Cant fire ability, another ability is active")
                params.CanRun = false
                return params
            end
        end
    end

    -- BARRAGE/INIALIZE
    if params.SystemStage == "Intialize" then

        -- BARRAGE/INIALIZE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
            params.CanRun = true
        end

        -- BARRAGE/INIALIZE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            params.CanRun = true
        end
    end

    -- BARRAGE/ACTIVATE
    if params.SystemStage == "Activate" then

        -- BARRAGE/ACTIVATE/INPUT BEGAN
        if params.KeyState == "InputBegan" then

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
                    Knit.Services.PowersService:ActivatePower(initPlayer,params)
                end)
            end
            
            --[[
            -- this is for mobile toggles
            if AbilityToggle.GetToggleValue(initPlayer,params.InputId) == true then
                AbilityToggle.SetToggle(initPlayer,params.InputId,false)
                params.CanRun = true
                params.KeyState = "InputEnded"
                Knit.Services.PowersService:ActivatePower(initPlayer,params)
            end
            ]]--
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
end

--------------------------------------------------------------------------------------------------
--// TIME STOP //---------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

function TheWorld.TimeStop(initPlayer,params)

    -- server actions
    if RunService:IsServer() then
        -- requires Stand to be active via "Q" toggle
        if not AbilityToggle.RequireTrue(initPlayer,{"Q"}) then
            print("Stand not active, cannot run this ability")
            params.CanRun = false
            return params
        end

        -- require toggles to be inactive, excluding "Q"
        if params.KeyState == "InputBegan" then -- we had to do this on InputBegan ONLY because of the funny way Barrage toggles
            if not AbilityToggle.RequireFalse(initPlayer,{"E","R","T","F","Z","X"}) then
                print("Cant fire ability, another ability is active")
                params.CanRun = false
                return params
            end
        end
    end

    -- TIME STOP/INIALIZE
    if params.SystemStage == "Intialize" then

        -- TIME STOP/INIALIZE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
            params.CanRun = true
        end

        -- TIME STOP/INIALIZE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            params.CanRun = false
        end
    end

    -- TIME STOP/ACTIVATE
    if params.SystemStage == "Activate" then

        -- TIME STOP/ACTIVATE/INPUT BEGAN
        if params.KeyState == "InputBegan" then

            -- set cooldown
            Cooldown.SetCooldown(initPlayer,params.InputId,TheWorld.Defs.Abilities.TimeStop.Cooldown)

            -- set toggles
            spawn(function()
                AbilityToggle.SetToggle(initPlayer,params.InputId,true)
                wait(3)
                AbilityToggle.SetToggle(initPlayer,params.InputId,false)
            end)

            spawn(function()
                wait(2) -- this waits for the animations and audio before firing
                params.TimeStop = TheWorld.Defs.Abilities.TimeStop
                TimeStop.Activate(initPlayer,params)
            end)
            
            
            params.CanRun = true

        end

        -- TIME STOP/ACTIVATE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            params.CanRun = false
        end
    end

    -- TIME STOP/EXECUTE
    if params.SystemStage == "Execute" then

        -- TIME STOP/EXECUTE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
            print("CLIENT - Time Stop - Execute = InputBegan")

            ManageStand.PlayAnimation(initPlayer,params,"TimeStop")
            SoundPlayer.WeldSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.SFX.StandSounds.TheWorld.TimeStop)

            -- wait here for the timestop audio
            wait(2)

            local timeStopParams = TheWorld.Defs.Abilities.TimeStop
            TimeStop.Execute(initPlayer,timeStopParams)
        end

        -- TIME STOP/EXECUTE/INPUT ENDED
        if params.KeyState == "InputEnded" then

        end

    end
end

--------------------------------------------------------------------------------------------------
--// KNIFE THROW //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

function TheWorld.KnifeThrow(initPlayer,params)

    -- server actions
    if RunService:IsServer() then
        -- requires Stand to be active via "Q" toggle
        if not AbilityToggle.RequireTrue(initPlayer,{"Q"}) then
            print("Stand not active, cannot run this ability")
            params.CanRun = false
            return params
        end

        -- require toggles to be inactive, excluding "Q"
        if params.KeyState == "InputBegan" then -- we had to do this on InputBegan ONLY because of the funny way Barrage toggles
            if not AbilityToggle.RequireFalse(initPlayer,{"E","R","T","F","Z","X"}) then
                print("Cant fire ability, another ability is active")
                params.CanRun = false
                return params
            end
        end
    end
    
    -- KNIFE THROW/INITIALIZE
    if params.SystemStage == "Intialize" then

        -- KNIFE THROW/INITIALIZE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
            params.CanRun = true
        end

        -- KNIFE THROW/INITIALIZE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            params.CanRun = false
        end
    end

    -- KNIFE THROW/ACTIVATE
    if params.SystemStage == "Activate" then

         -- KNIFE THROW/ACTIVATE/INPUT BEGAN
         if params.KeyState == "InputBegan" then

            -- set cooldown
            Cooldown.SetCooldown(initPlayer,params.InputId,TheWorld.Defs.Abilities.KnifeThrow.Cooldown)

            -- set toggles
            spawn(function()
                AbilityToggle.SetToggle(initPlayer,params.InputId,true)
                wait(1)
                AbilityToggle.SetToggle(initPlayer,params.InputId,false)
            end)

            params.KnifeThrow = TheWorld.Defs.Abilities.KnifeThrow
            KnifeThrow.Server_Activate(initPlayer,params)
            params.CanRun = true
        end

        -- KNIFE THROW/ACTIVATE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            params.CanRun = false
        end
    end

    -- KNIFE THROW/EXECUTE
    if params.SystemStage == "Execute" then

         -- KNIFE THROW/EXECUTE/INPUT BEGAN
         if params.KeyState == "InputBegan" then
            SoundPlayer.WeldSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.SFX.GeneralStandSounds.GenericKnifeThrow)
            KnifeThrow.Client_Execute(initPlayer,params)
        end

        -- KNIFE THROW/EXECUTE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            -- no action here
        end
    end
end

--------------------------------------------------------------------------------------------------
--// HEAVY PUNCH //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

function TheWorld.HeavyPunch(initPlayer,params)

    -- server actions
    if RunService:IsServer() then
        -- requires Stand to be active via "Q" toggle
        if not AbilityToggle.RequireTrue(initPlayer,{"Q"}) then
            print("Stand not active, cannot run this ability")
            params.CanRun = false
            return params
        end

        -- require toggles to be inactive, excluding "Q"
        if params.KeyState == "InputBegan" then -- we had to do this on InputBegan ONLY because of the funny way Barrage toggles
            if not AbilityToggle.RequireFalse(initPlayer,{"E","R","T","F","Z","X"}) then
                print("Cant fire ability, another ability is active")
                params.CanRun = false
                return params
            end
        end
    end
    
    -- HEAVY PUNCH/INITIALIZE
    if params.SystemStage == "Intialize" then

        -- HEAVY PUNCH/INITIALIZE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
            params.CanRun = true
        end

        -- HEAVY PUNCH/INITIALIZE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            params.CanRun = false
        end
    end

    -- HEAVY PUNCH/ACTIVATE
    if params.SystemStage == "Activate" then

         -- HEAVY PUNCH/ACTIVATE/INPUT BEGAN
         if params.KeyState == "InputBegan" then
           
            -- set cooldown
            Cooldown.SetCooldown(initPlayer,params.InputId,TheWorld.Defs.Abilities.HeavyPunch.Cooldown)

            -- set toggles
            spawn(function()
                AbilityToggle.SetToggle(initPlayer,params.InputId,true)
                wait(2)
                AbilityToggle.SetToggle(initPlayer,params.InputId,false)
            end)

            -- activate ability
            params.HeavyPunch = TheWorld.Defs.Abilities.HeavyPunch
            HeavyPunch.Activate(initPlayer,params)
            
            

            params.CanRun = true
        end

        -- HEAVY PUNCH/ACTIVATE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            params.CanRun = false
        end
    end

    -- HEAVY PUNCH/EXECUTE
    if params.SystemStage == "Execute" then

         -- HEAVY PUNCH/EXECUTE/INPUT BEGAN
         if params.KeyState == "InputBegan" then

            spawn(function()
                wait(.3)
                SoundPlayer.WeldSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.SFX.StandSounds.TheWorld.HeavyPunch)
            end)
           
            local heavyPunchParams = TheWorld.Defs.Abilities.HeavyPunch
            HeavyPunch.Execute(initPlayer,heavyPunchParams)
        end

        -- HEAVY PUNCH/EXECUTE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            -- no action here
        end
    end
end

--------------------------------------------------------------------------------------------------
--// BULLET KICK //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

function TheWorld.BulletKick(initPlayer,params)

    -- server actions
    if RunService:IsServer() then
        -- requires Stand to be active via "Q" toggle
        if not AbilityToggle.RequireTrue(initPlayer,{"Q"}) then
            print("Stand not active, cannot run this ability")
            params.CanRun = false
            return params
        end

        -- require toggles to be inactive, excluding "Q"
        if params.KeyState == "InputBegan" then -- we had to do this on InputBegan ONLY because of the funny way Barrage toggles
            if not AbilityToggle.RequireFalse(initPlayer,{"E","R","T","F","Z","X"}) then
                print("Cant fire ability, another ability is active")
                params.CanRun = false
                return params
            end
        end
    end
    
    -- BULLET KICK/INITIALIZE
    if params.SystemStage == "Intialize" then

        -- BULLET KICK/INITIALIZE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
            params.CanRun = true
        end

        -- BULLET KICK/INITIALIZE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            params.CanRun = false
        end
    end

    -- BULLET KICK/ACTIVATE
    if params.SystemStage == "Activate" then

         -- BULLET KICK/ACTIVATE/INPUT BEGAN
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
            params.CanRun = true
        end

        -- BULLET KICK/ACTIVATE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            params.CanRun = false
        end
    end

    -- BULLET KICK/EXECUTE
    if params.SystemStage == "Execute" then

         -- BULLET KICK/EXECUTE/INPUT BEGAN
         if params.KeyState == "InputBegan" then
            BulletKick.Execute(initPlayer,params)
        end

        -- BULLET KICK/EXECUTE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            -- no action here
        end
    end
end

--------------------------------------------------------------------------------------------------
--// STAND JUMP //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

function TheWorld.StandJump(initPlayer,params)

    -- server actions
    if RunService:IsServer() then
        -- requires Stand to be active via "Q" toggle
        if not AbilityToggle.RequireTrue(initPlayer,{"Q"}) then
            print("Stand not active, cannot run this ability")
            params.CanRun = false
            return params
        end

        -- require toggles to be inactive, excluding "Q"
        if params.KeyState == "InputBegan" then -- we had to do this on InputBegan ONLY because of the funny way Barrage toggles
            if not AbilityToggle.RequireFalse(initPlayer,{"E","R","T","F","Z","X"}) then
                print("Cant fire ability, another ability is active")
                params.CanRun = false
                return params
            end
        end
    end
    
    -- STAND JUMP/INITIALIZE
    if params.SystemStage == "Intialize" then

        -- STAND JUMP/INITIALIZE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
            params.CanRun = true
        end

        -- STAND JUMP/INITIALIZE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            params.CanRun = false
        end
    end

    -- STAND JUMP/ACTIVATE
    if params.SystemStage == "Activate" then

         -- STAND JUMP/ACTIVATE/INPUT BEGAN
         if params.KeyState == "InputBegan" then

            --bulletKickParams = TheWorld.Defs.Abilities.BulletKick
            params.StandJump = TheWorld.Defs.Abilities.StandJump
            StandJump.Activate(initPlayer,params)

            -- if CanRun is true
            if params.CanRun == true then

                -- set cooldowns
                Cooldown.SetCooldown(initPlayer,params.InputId,TheWorld.Defs.Abilities.StandJump.Cooldown)

                -- set toggles
                spawn(function()
                    AbilityToggle.SetToggle(initPlayer,params.InputId,true)
                    wait(1)
                    AbilityToggle.SetToggle(initPlayer,params.InputId,false)
                end)

            end
        end

        -- STAND JUMP/ACTIVATE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            params.CanRun = false
        end
    end

    -- STAND JUMP/EXECUTE
    if params.SystemStage == "Execute" then

         -- STAND JUMP/EXECUTE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
            StandJump.Execute(initPlayer,params)
        end

        -- STAND JUMP/EXECUTE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            -- no action here
        end
    end
end

return TheWorld