-- WhiteSnake
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

local BulletKick = require(Knit.Abilities.BulletKick)
local StandJump = require(Knit.Abilities.StandJump)
local Punch = require(Knit.Abilities.Punch)

-- Effect modules
local AbilityToggle = require(Knit.PowerUtils.AbilityToggle)
local SoundPlayer = require(Knit.PowerUtils.SoundPlayer)
local Cooldown = require(Knit.PowerUtils.Cooldown)


local WhiteSnake = {}

WhiteSnake.Defs = {

    -- just some general defs here
    PowerName = "White Snake",
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
function WhiteSnake.SetupPower(initPlayer,params)
    print("setup", params)
    Knit.Services.StateService:AddEntryToState(initPlayer, "WalkSpeed", "WhiteSnake_Setup", 2, nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Health", "WhiteSnake_Setup", WhiteSnake.Defs.HealthModifier[params.Rarity], nil)
end

--// REMOVE - run this once when the stand is un-equipped
function WhiteSnake.RemovePower(initPlayer,params)
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "WalkSpeed", "WhiteSnake_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Health", "WhiteSnake_Setup")
end

--// MANAGER - this is the single point of entry from PowersService and PowersController.
function WhiteSnake.Manager(initPlayer,params)

    -- check cooldowns but only on SystemStage "Activate"
    if params.SystemStage == "Activate" then
        if Cooldown.IsCooled(initPlayer, params) then
            params.CanRun = true
        else
            params.CanRun = false
            return params
        end
    end

    -- call the function
    if params.InputId == "Q" then
        WhiteSnake.EquipStand(initPlayer,params)
    elseif params.InputId == "E" then
        WhiteSnake.Barrage(initPlayer,params)
    elseif params.InputId == "R" then
        WhiteSnake.BombPunch(initPlayer,params)
    elseif params.InputId == "T" then
        WhiteSnake.ExplosiveCoin(initPlayer,params)
    elseif params.InputId == "F" then
        WhiteSnake.BitesTheDust(initPlayer,params)
    elseif params.InputId == "X" then
        WhiteSnake.SheerHeartAttack(initPlayer,params)
    elseif params.InputId == "Z" then
        WhiteSnake.StandJump(initPlayer,params)
    elseif params.InputId == "Mouse1" then
        WhiteSnake.Punch(initPlayer,params)
    end

    return params
end

--------------------------------------------------------------------------------------------------
--// EQUIP STAND //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- ability module
local ManageStand = require(Knit.Abilities.ManageStand)

-- defs
WhiteSnake.Defs.Abilities.EquipStand = {
    Name = "Equip Stand",
    Cooldown = 5,
    StandModels = {
        Common = ReplicatedStorage.EffectParts.StandModels.WhiteSnake_Common,
        Rare = ReplicatedStorage.EffectParts.StandModels.WhiteSnake_Rare,
        Legendary = ReplicatedStorage.EffectParts.StandModels.WhiteSnake_Legendary,
    },
}

function WhiteSnake.EquipStand(initPlayer,params)

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
            Cooldown.SetCooldown(initPlayer, params.InputId, WhiteSnake.Defs.Abilities.EquipStand.Cooldown)

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
                SoundPlayer.WeldSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.SFX.StandSounds.WhiteSnake.Summon) -- specific stand sound
                ManageStand.EquipStand(initPlayer, WhiteSnake.Defs.Abilities.EquipStand.StandModels[params.PowerRarity])
            else
                SoundPlayer.WeldSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.SFX.GeneralStandSounds.StandSummon) -- specific stand sound
                ManageStand.RemoveStand(initPlayer)            
            end
        end
    end
end

--------------------------------------------------------------------------------------------------
--// BARRAGE //----------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- ability module
local Barrage = require(Knit.Abilities.Barrage)

-- defs
WhiteSnake.Defs.Abilities.Barrage = {
    Name = "Barrage",
    Duration = 4,
    Cooldown = 7,
    HitEffects = {Damage = {Damage = 3}}
}

function WhiteSnake.Barrage(initPlayer,params)

    -- BARRAGE/INIALIZE
    if params.SystemStage == "Initialize" then
        if params.KeyState == "InputBegan" then
            params.CanRun = true
        end
        if params.KeyState == "InputEnded" then
            params.CanRun = true
        end
    end

    -- BARRAGE/ACTIVATE
    if params.SystemStage == "Activate" then
        if params.KeyState == "InputBegan" then

            -- require toggles to be active
            if not AbilityToggle.RequireOn(initPlayer,{"Q"}) then
                params.CanRun = false
                return params
            end

            -- require toggles to be inactive, excluding "Q"
            if not AbilityToggle.RequireOff(initPlayer,{"C","R","T","F","Z","X"}) then
                params.CanRun = false
                return params
            end

            -- only operate if toggle is off
            if AbilityToggle.GetToggleValue(initPlayer,params.InputId) == false then
                AbilityToggle.SetToggle(initPlayer,params.InputId,true)
                params.CanRun = true
      
                params.Barrage = WhiteSnake.Defs.Abilities.Barrage
                Barrage.Activate(initPlayer, params)

                -- spawn a function to kill the barrage if the duration expires
                spawn(function()
                    wait(WhiteSnake.Defs.Abilities.Barrage.Duration)
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
                Cooldown.SetCooldown(initPlayer,params.InputId,WhiteSnake.Defs.Abilities.Barrage.Cooldown)

                -- set toggle
                AbilityToggle.SetToggle(initPlayer,params.InputId,false)
                params.CanRun = true

                -- destroy hitbox
                Barrage.DestroyHitbox(initPlayer, WhiteSnake.Defs.Abilities.Barrage)
            end
        end
    end

    -- BARRAGE/EXECUTE
    if params.SystemStage == "Execute" then

        -- BARRAGE/EXECUTE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
            if AbilityToggle.GetToggleValue(initPlayer,params.InputId) == true then
                Barrage.RunEffect(initPlayer,params)

                --local soundParams = {}
                --soundParams.SoundProperties = {}
                --soundParams.SoundProperties.Looped = false
                --SoundPlayer.WeldSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.SFX.StandSounds.WhiteSnake.Barrage, soundParams)
            end
        end

        -- BARRAGE/EXECUTE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            if AbilityToggle.GetToggleValue(initPlayer,params.InputId) == false then
                Barrage.EndEffect(initPlayer,params)
                --SoundPlayer.StopWeldedSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.SFX.StandSounds.WhiteSnake.Barrage.Name,.5)
            end 
        end
    end
end

--------------------------------------------------------------------------------------------------
--// BOMB PUNCH //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- ability module
local HeavyPunch = require(Knit.Abilities.HeavyPunch)

--defs
WhiteSnake.Defs.Abilities.HeavyPunch = {
    Name = "Bomb Punch",
    Cooldown = 10,
    HitEffects = {Damage = {Damage = 10}}
}

function WhiteSnake.BombPunch(initPlayer,params)

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
                Cooldown.SetCooldown(initPlayer,params.InputId,WhiteSnake.Defs.Abilities.HeavyPunch.Cooldown)
                AbilityToggle.SetToggle(initPlayer,params.InputId,true)
                wait(2)
                AbilityToggle.SetToggle(initPlayer,params.InputId,false)
            end)

            -- activate ability
            params.HeavyPunch = WhiteSnake.Defs.Abilities.HeavyPunch
            HeavyPunch.Activate(initPlayer,params)

            params.CanRun = true
        end
    end

    -- HEAVY PUNCH/EXECUTE
    if params.SystemStage == "Execute" then
         if params.KeyState == "InputBegan" then

            local heavyPunchParams = WhiteSnake.Defs.Abilities.HeavyPunch
            HeavyPunch.Execute(initPlayer,heavyPunchParams)
            --wait(.3)
            --SoundPlayer.WeldSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.SFX.StandSounds.WhiteSnake.HeavyPunch)
        end

    end
end

--------------------------------------------------------------------------------------------------
--// EXPLOSIVE COIN //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- ability module
local BasicGrenade = require(Knit.Abilities.BasicGrenade)

-- defs
WhiteSnake.Defs.Abilities.BasicProjectile = {
    Name = "Explosive Coin",
    Cooldown = 1,
    HitEffects = {}
}

function WhiteSnake.ExplosiveCoin(initPlayer,params)
    print("KILLER QUEEN: Bites The Dust")
end


--------------------------------------------------------------------------------------------------
--// BITES THE DUST //---------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
WhiteSnake.Defs.Abilities.BitesTheDust = {
    Name = "Bites The Dust",
    Cooldown = 1,
    HitEffects = {}
}

function WhiteSnake.BitesTheDust(initPlayer,params)
    print("KILLER QUEEN: Bites The Dust")
end


--------------------------------------------------------------------------------------------------
--// SHEER HEART ATTACK //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
WhiteSnake.Defs.Abilities.SheerHeartAttack = {
    Name = "Sheer Heart Attack",
    Cooldown = 1,
    HitEffects = {}
}

function WhiteSnake.SheerHeartAttack(initPlayer,params)
    print("KILLER QUEEN: Sheer Heart Attack")
end

--------------------------------------------------------------------------------------------------
--// STAND JUMP //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
WhiteSnake.Defs.Abilities.StandJump = {
    Name = "Stand Jump",
    Duration = .3,
    Cooldown = 5,
    Velocity_XZ = 2700,
    Velocity_Y = 500
}

function WhiteSnake.StandJump(initPlayer,params)


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

        --bulletKickParams = WhiteSnake.Defs.Abilities.BulletKick
        params.StandJump = WhiteSnake.Defs.Abilities.StandJump
        
            -- set toggles and cooldowns
            spawn(function()
                Cooldown.SetCooldown(initPlayer,params.InputId,WhiteSnake.Defs.Abilities.StandJump.Cooldown)
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
WhiteSnake.Defs.Abilities.Punch = {
    Name = "Punch",
    HitEffects = {Damage = {Damage = 5}}
}

function WhiteSnake.Punch(initPlayer,params)

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
                --Cooldown.SetCooldown(initPlayer, params.InputId, WhiteSnake.Defs.Abilities.Punch.Cooldown)
                AbilityToggle.SetToggle(initPlayer,params.InputId,true)
                wait(.75)
                AbilityToggle.SetToggle(initPlayer,params.InputId,false)
            end)

            params.Punch = WhiteSnake.Defs.Abilities.Punch
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

return WhiteSnake