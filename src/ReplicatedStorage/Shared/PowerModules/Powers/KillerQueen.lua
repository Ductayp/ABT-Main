-- KillerQueen
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
local BasicGrenade = require(Knit.Abilities.BasicGrenade)

-- Effect modules
local AbilityToggle = require(Knit.PowerUtils.AbilityToggle)
local SoundPlayer = require(Knit.PowerUtils.SoundPlayer)
local Cooldown = require(Knit.PowerUtils.Cooldown)

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
    print("setup", params)
    Knit.Services.StateService:AddEntryToState(initPlayer, "WalkSpeed", "KillerQueen_Setup", 2, nil)
    Knit.Services.StateService:AddEntryToState(initPlayer, "Health", "KillerQueen_Setup", KillerQueen.Defs.HealthModifier[params.Rarity], nil)
end

--// REMOVE - run this once when the stand is un-equipped
function KillerQueen.RemovePower(initPlayer,params)
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "WalkSpeed", "KillerQueen_Setup")
    Knit.Services.StateService:RemoveEntryFromState(initPlayer, "Health", "KillerQueen_Setup")
end

--// MANAGER - this is the single point of entry from PowersService and PowersController.
function KillerQueen.Manager(initPlayer,params)

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
        KillerQueen.EquipStand(initPlayer,params)
    elseif params.InputId == "E" then
        KillerQueen.Barrage(initPlayer,params)
    elseif params.InputId == "R" then
        KillerQueen.BombPunch(initPlayer,params)
    elseif params.InputId == "T" then
        KillerQueen.ExplosiveCoin(initPlayer,params)
    elseif params.InputId == "F" then
        KillerQueen.BitesTheDust(initPlayer,params)
    elseif params.InputId == "X" then
        KillerQueen.SheerHeartAttack(initPlayer,params)
    elseif params.InputId == "Z" then
        KillerQueen.StandJump(initPlayer,params)
    elseif params.InputId == "Mouse1" then
        KillerQueen.Punch(initPlayer,params)
    end

    return params
end

--------------------------------------------------------------------------------------------------
--// EQUIP STAND //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- ability module
local ManageStand = require(Knit.Abilities.ManageStand)

-- defs
KillerQueen.Defs.Abilities.EquipStand = {
    Name = "Equip Stand",
    Cooldown = 5,
    StandModels = {
        Common = ReplicatedStorage.EffectParts.StandModels.KillerQueen_Common,
        Rare = ReplicatedStorage.EffectParts.StandModels.KillerQueen_Rare,
        Legendary = ReplicatedStorage.EffectParts.StandModels.KillerQueen_Legendary,
    },
}

function KillerQueen.EquipStand(initPlayer,params)

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
            Cooldown.SetCooldown(initPlayer, params.InputId, KillerQueen.Defs.Abilities.EquipStand.Cooldown)

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
                SoundPlayer.WeldSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.SFX.StandSounds.KillerQueen.Summon) -- specific stand sound
                ManageStand.EquipStand(initPlayer, KillerQueen.Defs.Abilities.EquipStand.StandModels[params.PowerRarity])
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
KillerQueen.Defs.Abilities.Barrage = {
    Name = "Barrage",
    Duration = 4,
    Cooldown = 7,
    HitEffects = {Damage = {Damage = 3}}
}

function KillerQueen.Barrage(initPlayer,params)

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
      
                params.Barrage = KillerQueen.Defs.Abilities.Barrage
                Barrage.Activate(initPlayer, params)

                -- spawn a function to kill the barrage if the duration expires
                spawn(function()
                    wait(KillerQueen.Defs.Abilities.Barrage.Duration)
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
                Cooldown.SetCooldown(initPlayer,params.InputId,KillerQueen.Defs.Abilities.Barrage.Cooldown)

                -- set toggle
                AbilityToggle.SetToggle(initPlayer,params.InputId,false)
                params.CanRun = true

                -- destroy hitbox
                Barrage.DestroyHitbox(initPlayer, KillerQueen.Defs.Abilities.Barrage)
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
                --SoundPlayer.WeldSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.SFX.StandSounds.KillerQueen.Barrage, soundParams)
            end
        end

        -- BARRAGE/EXECUTE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            if AbilityToggle.GetToggleValue(initPlayer,params.InputId) == false then
                Barrage.EndEffect(initPlayer,params)
                --SoundPlayer.StopWeldedSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.SFX.StandSounds.KillerQueen.Barrage.Name,.5)
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
KillerQueen.Defs.Abilities.HeavyPunch = {
    Name = "Bomb Punch",
    Cooldown = 1,
    HitEffects = {Damage = {Damage = 10}, Blast = {}, KnockBack = {Force = 70, ForceY = 50}}
}

function KillerQueen.BombPunch(initPlayer,params)

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
                Cooldown.SetCooldown(initPlayer,params.InputId,KillerQueen.Defs.Abilities.HeavyPunch.Cooldown)
                AbilityToggle.SetToggle(initPlayer,params.InputId,true)
                wait(2)
                AbilityToggle.SetToggle(initPlayer,params.InputId,false)
            end)

            -- activate ability
            params.HeavyPunch = KillerQueen.Defs.Abilities.HeavyPunch
            HeavyPunch.Activate(initPlayer,params)

            params.CanRun = true
        end
    end

    -- HEAVY PUNCH/EXECUTE
    if params.SystemStage == "Execute" then
         if params.KeyState == "InputBegan" then

            local heavyPunchParams = KillerQueen.Defs.Abilities.HeavyPunch
            HeavyPunch.Execute(initPlayer,heavyPunchParams)
            --wait(.3)
            --SoundPlayer.WeldSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.SFX.StandSounds.KillerQueen.HeavyPunch)
        end

    end
end

--------------------------------------------------------------------------------------------------
--// EXPLOSIVE COIN //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- ability module
local BasicGrenade = require(Knit.Abilities.BasicGrenade)

-- defs
KillerQueen.Defs.Abilities.ExplosiveCoin = {
    Name = "Explosive Coin",
    Cooldown = 2,
    AbilityMod = Knit.AbilityMods.BasicGrenade_ExplosiveCoin,
    --HitEffects = {} -- we are aplpyign hit effects through to abilitymod module
}

function KillerQueen.ExplosiveCoin(initPlayer,params)

    -- EXPLOSIVE COIN/INITIALIZE
    if params.SystemStage == "Initialize" then
        if params.KeyState == "InputBegan" then
            params.CanRun = true
        end
    end

    -- EXPLOSIVE COIN/ACTIVATE
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

        if params.KeyState == "InputBegan" then

            -- cooldowns and toggles
            spawn(function()
                Cooldown.SetCooldown(initPlayer,params.InputId,KillerQueen.Defs.Abilities.ExplosiveCoin.Cooldown)
                AbilityToggle.SetToggle(initPlayer,params.InputId, true)
                wait(2)
                AbilityToggle.SetToggle(initPlayer,params.InputId, false)
            end)

            -- activate ability
            params.BasicGrenade = KillerQueen.Defs.Abilities.ExplosiveCoin
            BasicGrenade.Server_Activate(initPlayer,params)

            params.CanRun = true

        end

    end

    
    -- EXPLOSIVE COIN/EXECUTE
    if params.SystemStage == "Execute" then
        if params.KeyState == "InputBegan" then

            BasicGrenade.Client_Execute(initPlayer,params)

       end

   end


end


--------------------------------------------------------------------------------------------------
--// BITES THE DUST //---------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
KillerQueen.Defs.Abilities.BitesTheDust = {
    Name = "Bites The Dust",
    Cooldown = 1,
    HitEffects = {}
}

function KillerQueen.BitesTheDust(initPlayer,params)
    print("KILLER QUEEN: Bites The Dust")
end


--------------------------------------------------------------------------------------------------
--// SHEER HEART ATTACK //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
KillerQueen.Defs.Abilities.SheerHeartAttack = {
    Name = "Sheer Heart Attack",
    Cooldown = 1,
    HitEffects = {}
}

function KillerQueen.SheerHeartAttack(initPlayer,params)
    print("KILLER QUEEN: Sheer Heart Attack")
end

--------------------------------------------------------------------------------------------------
--// STAND JUMP //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
KillerQueen.Defs.Abilities.StandJump = {
    Name = "Stand Jump",
    Duration = .3,
    Cooldown = 5,
    Velocity_XZ = 2700,
    Velocity_Y = 500
}

function KillerQueen.StandJump(initPlayer,params)


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

        --bulletKickParams = KillerQueen.Defs.Abilities.BulletKick
        params.StandJump = KillerQueen.Defs.Abilities.StandJump
        
            -- set toggles and cooldowns
            spawn(function()
                Cooldown.SetCooldown(initPlayer,params.InputId,KillerQueen.Defs.Abilities.StandJump.Cooldown)
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
KillerQueen.Defs.Abilities.Punch = {
    Name = "Punch",
    HitEffects = {Damage = {Damage = 5}}
}

function KillerQueen.Punch(initPlayer,params)

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
                --Cooldown.SetCooldown(initPlayer, params.InputId, KillerQueen.Defs.Abilities.Punch.Cooldown)
                AbilityToggle.SetToggle(initPlayer,params.InputId,true)
                wait(.75)
                AbilityToggle.SetToggle(initPlayer,params.InputId,false)
            end)

            params.Punch = KillerQueen.Defs.Abilities.Punch
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

return KillerQueen