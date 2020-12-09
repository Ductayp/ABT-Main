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
local powerUtils = require(Knit.Shared.PowerUtils)


-- Ability modules
local ManageStand = require(Knit.Abilities.ManageStand)
local Barrage = require(Knit.Abilities.Barrage)
local TimeStop = require(Knit.Abilities.TimeStop)
local KnifeThrow = require(Knit.Abilities.KnifeThrow)
local HeavyPunch = require(Knit.Abilities.HeavyPunch)

-- Effect modules
local AbilityToggle = require(Knit.Effects.AbilityToggle)

-- variables
local playerStandFolder -- defined up here so all functions can use it
local thisStand -- defined up here so all functions can use it

local TheWorld = {}

TheWorld.Defs = {

    -- just some general defs here
    PowerName = "The World",
    StandModel = ReplicatedStorage.EffectParts.StandModels.TheWorld,

    -- only include true values of immunities, if they are not immune then dont have anything in here
    Immunities = {
        TimeStop = true
    },

    Abilities = {

        EquipStand = {
            Name = "Equip Stand",
            Cooldown = 5
            --EquipSound = ReplicatedStorage.Audio.SFX.StandSounds.TheWorld.Summon,
            --RemoveSound = ReplicatedStorage.Audio.SFX.GeneralStandSounds.StandSummon
        },

        Barrage = {
            Name = "Barrage",
            AbilityId = "Barrage",
            Duration = 5,
            Cooldown = 10,
            Damage = 5,
            loopTime = .25
        },

        TimeStop = {
            Name = "Time Stop",
            Duration = 5,
            Cooldown = 10,
            Range = 150,
        },

       KnifeThrow = {
            Name = "Knife Throw",
            Cooldown = 5,
            Range = 75,
            Speed = 40,
            Damage = 20
        },

        HeavyPunch = {
            Name = "Heavy Punch",
            Damage = 30,
            Cooldown = 1,
        },

        Ability_6 = {
            Name = "Ability 6",
            Duration = 0,
            Cooldown = 1,
        },

        Ability_7 = {
            Name = "Ability 7",
            Duration = 0,
            Cooldown = 1,
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
    print("Setup Power - The World for: ",initPlayer)
    Knit.Services.ModifierService:AddModifier(initPlayer, "WalkSpeed", "TheWorld_Setup", 2, nil)
end

--// REMOVE - run this once when the stand is un-equipped
function TheWorld.RemovePower(initPlayer,params)
    print("Removing Power - The World for: ",initPlayer)
    Knit.Services.ModifierService:RemoveModifier(initPlayer, "WalkSpeed", "TheWorld_Setup")
end

--// MANAGER - this is the single point of entry from PowersService and PowersController.
function TheWorld.Manager(initPlayer,params)

    -- check cooldowns but only on SystemStage "Activate"
    if params.SystemStage == "Activate" then
        local cooldown = powerUtils.GetCooldown(initPlayer,params)
        if os.time() < cooldown.Value  then
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
    end

    return params
end

--------------------------------------------------------------------------------------------------
--// EQUIP STAND //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

function TheWorld.EquipStand(initPlayer,params)

    -- get stand toggle, setup if it doesnt exist
    local standToggle = powerUtils.GetToggle(initPlayer,params.InputId)

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
            if standToggle.Value == true then
                standToggle.Value = false
            else
                standToggle.Value = true
            end
            powerUtils.SetCooldown(initPlayer,params,TheWorld.Defs.Abilities.EquipStand.Cooldown)
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
            if standToggle.Value == true then
                powerUtils.WeldSpeakerSound(initPlayer.Character.HumanoidRootPart,ReplicatedStorage.Audio.SFX.StandSounds.TheWorld.Summon)
                powerUtils.SetGUICooldown(initPlayer,params.InputId,TheWorld.Defs.Abilities.EquipStand.Cooldown)
                ManageStand.EquipStand(initPlayer,TheWorld.Defs.StandModel)
            else
                powerUtils.WeldSpeakerSound(initPlayer.Character.HumanoidRootPart,ReplicatedStorage.Audio.SFX.GeneralStandSounds.StandSummon)
                powerUtils.SetGUICooldown(initPlayer,params.InputId,TheWorld.Defs.Abilities.EquipStand.Cooldown)
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
      
                Barrage.Server_CreateHitbox(initPlayer, TheWorld.Defs.Abilities.Barrage)

                -- spawn a function to kill the barrage if the duration expires
                spawn(function()
                    wait(TheWorld.Defs.Abilities.Barrage.Duration)
                    params.KeyState = "InputEnded"
                    Knit.Services.PowersService:ActivatePower(initPlayer,params)
                end)
            end
        end

        -- BARRAGE/ACTIVATE/INPUT ENDED
        if params.KeyState == "InputEnded" then

            -- only operate if toggle is on
            if AbilityToggle.GetToggleValue(initPlayer,params.InputId) == true then
                AbilityToggle.SetToggle(initPlayer,params.InputId,false)
                params.CanRun = true

                -- set the cooldown
                powerUtils.SetCooldown(initPlayer,params,TheWorld.Defs.Abilities.Barrage.Cooldown)

                -- destroy hitbox
                Barrage.Server_DestroyHitbox(initPlayer, TheWorld.Defs.Abilities.Barrage)
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
                powerUtils.WeldSpeakerSound(thisStand.HumanoidRootPart,ReplicatedStorage.Audio.SFX.StandSounds.TheWorld.Barrage,soundParams)
            end
        end

        -- BARRAGE/EXECUTE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            if AbilityToggle.GetToggleValue(initPlayer,params.InputId) == false then
                powerUtils.SetGUICooldown(initPlayer,params.InputId,TheWorld.Defs.Abilities.Barrage.Cooldown)
                Barrage.EndEffect(initPlayer,params)
                powerUtils.StopSpeakerSound(thisStand.HumanoidRootPart,ReplicatedStorage.Audio.SFX.StandSounds.TheWorld.Barrage.Name,.5)
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

            local timeStopParams = {}
            timeStopParams.Duration = TheWorld.Defs.Abilities.TimeStop.Duration
            timeStopParams.Range = TheWorld.Defs.Abilities.TimeStop.Range
            timeStopParams.Delay = 2

            params = TimeStop.Server_RunTimeStop(initPlayer,params,timeStopParams)
            powerUtils.SetCooldown(initPlayer,params,TheWorld.Defs.Abilities.TimeStop.Cooldown)
            
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
            powerUtils.WeldSpeakerSound(initPlayer.Character.HumanoidRootPart,ReplicatedStorage.Audio.SFX.StandSounds.TheWorld.TimeStop)

            -- wait here for the timestop audio
            wait(2)

            powerUtils.SetGUICooldown(initPlayer,params.InputId,TheWorld.Defs.Abilities.TimeStop.Cooldown)

            local timeStopParams = {}
            timeStopParams.Duration = TheWorld.Defs.Abilities.TimeStop.Duration
            timeStopParams.Range = TheWorld.Defs.Abilities.TimeStop.Range
            TimeStop.Client_RunTimeStop(initPlayer,params,timeStopParams)
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
            powerUtils.SetCooldown(initPlayer,params,TheWorld.Defs.Abilities.KnifeThrow.Cooldown)
            params.KnifeThrow = TheWorld.Defs.Abilities.KnifeThrow
            KnifeThrow.Server_ThrowKnife(initPlayer,params)
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
            powerUtils.SetGUICooldown(initPlayer,params.InputId,TheWorld.Defs.Abilities.KnifeThrow.Cooldown)
            powerUtils.WeldSpeakerSound(initPlayer.Character.HumanoidRootPart,ReplicatedStorage.Audio.SFX.GeneralStandSounds.GenericKnifeThrow)
            KnifeThrow.Client_KnifeThrow(initPlayer,params)
        end

        -- KNIFE THROW/EXECUTE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            -- no action here
        end
    end
end

--------------------------------------------------------------------------------------------------
--// HEAVY  PUNCH //------------------------------------------------------------------------------
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
            local heavyPunchParams = TheWorld.Defs.Abilities.HeavyPunch
            
            HeavyPunch.Activate(initPlayer,heavyPunchParams)
            powerUtils.SetCooldown(initPlayer,params,TheWorld.Defs.Abilities.HeavyPunch.Cooldown)

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

            local heavyPunchParams = TheWorld.Defs.Abilities.HeavyPunch
            --heavyPunchParams.Color = Color3.new(255/255, 253/255, 156/255) -- yellow for TheWorld 255, 176, 0
            powerUtils.SetGUICooldown(initPlayer,params.InputId,TheWorld.Defs.Abilities.HeavyPunch.Cooldown)
            HeavyPunch.Execute(initPlayer,heavyPunchParams)
        end

        -- HEAVY PUNCH/EXECUTE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            -- no action here
        end
    end
end

return TheWorld