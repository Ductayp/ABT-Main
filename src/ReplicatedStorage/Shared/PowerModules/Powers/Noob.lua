-- Noob - setup stand
-- PDab
-- 12/7/2020

--[[
        NOTES:
        use this stand template as a starting place when building a new stand
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)

-- Ability modules
local ManageStand = require(Knit.Abilities.ManageStand)
local Barrage = require(Knit.Abilities.Barrage)
local HeavyPunch = require(Knit.Abilities.HeavyPunch)

local Noob = {}

Noob.Defs = {

    -- just some general defs here
    PowerName = "Noob",
    StandModel = ReplicatedStorage.EffectParts.StandModels.Noob,
    BaseSacrificeValue = 10,

    -- only include true values of immunities, if they are not immune then dont have anything in here
    Immunities = {
        -- none now, name is exactly the same as the ability. Example below
        --TimeStop = true
    },

    Abilities = {

        EquipStand = {
            Name = "Equip Stand",
            Cooldown = 5,
        },

        Ability_E = {
            Name = "Ability_E",
        },

        Ability_R = {
            Name = "Ability_R",
        },

        Ability_T = {
            Name = "Ability_T",
        },

        Ability_F = {
            Name = "Ability_F",
        },

        Ability_Z = {
            Name = "Ability_Z",
        },

        Ability_X = {
            Name = "Ability_X",
        },
    }
}

--// SETUP - run this once when the stand is equipped
function Noob.SetupPower(initPlayer,params)
    print("Setup Power - The Hand for: ",initPlayer)
end

--// REMOVE - run this once when the stand is un-equipped
function Noob.RemovePower(initPlayer,params)
    print("Removing Power - The Hand for: ",initPlayer)
end

--// MANAGER - this is the single point of entry from PowersService and PowersController.
function Noob.Manager(initPlayer,params)

    -- check cooldowns but only on SystemStage "Activate"
    -- this cooldown check is optional but recommended to keep it here unless you know what your doing
    -- we have this here instead of in PowersService so that powers can have uniqiue logic if they need it
    if params.SystemStage == "Activate" then
        local cooldown = powerUtils.GetCooldown(initPlayer,params)
        if os.time() < cooldown.Value  then
            params.CanRun = false
            return params
        end
    end

    -- call the function
    if params.InputId == "Q" then
        Noob.EquipStand(initPlayer,params)
    elseif params.InputId == "E" then
        Noob.Ability_E(initPlayer,params)
    elseif params.InputId == "R" then
        Noob.Ability_R(initPlayer,params)
    elseif params.InputId == "T" then
        Noob.Ability_T(initPlayer,params)
    elseif params.InputId == "F" then
        Noob.Ability_F(initPlayer,params)
    elseif params.InputId == "Z" then
        Noob.Ability_Z(initPlayer,params)
    elseif params.InputId == "X" then
        Noob.Ability_X(initPlayer,params)
    end

    return params
end

--------------------------------------------------------------------------------------------------
--// EQUIP STAND //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

function Noob.EquipStand(initPlayer,params)
    
    -- get stand folder
    local playerStandFolder = workspace.PlayerStands:FindFirstChild(initPlayer.UserId)

    -- get stand toggle, setup if it doesnt exist
    local standToggle = powerUtils.GetToggle(initPlayer,params.InputId)

    -- EQUIP STAND/INITIALIZE
    if params.SystemStage == "Intialize" then
    print("Noob - Equip Stand - Initialize")

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
        print("Noob - Equip Stand - Activate")

         -- EQUIP STAND/ACTIVATE/INPUT BEGAN
         if params.KeyState == "InputBegan" then
            if standToggle.Value == true then
                standToggle.Value = false
            else
                standToggle.Value = true
            end
            powerUtils.SetCooldown(initPlayer,params,Noob.Defs.Abilities.EquipStand.Cooldown)
            params.CanRun = true
        end

        -- EQUIP STAND/ACTIVATE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            params.CanRun = false
        end
    end

    -- EQUIP STAND/EXECUTE
    if params.SystemStage == "Execute" then
        print("Noob - Equip Stand - Execute")

         -- EQUIP STAND/EXECUTE/INPUT BEGAN
         if params.KeyState == "InputBegan" then
            if standToggle.Value == true then

                --powerUtils.WeldSpeakerSound(initPlayer.Character.HumanoidRootPart,-SoundNameHere)
                powerUtils.SetGUICooldown(initPlayer,params.InputId,Noob.Defs.Abilities.EquipStand.Cooldown)
                ManageStand.EquipStand(initPlayer,Noob.Defs.StandModel)

            else
  
                --powerUtils.WeldSpeakerSound(initPlayer.Character.HumanoidRootPart,-SoundNameHere)
                powerUtils.SetGUICooldown(initPlayer,params.InputId,Noob.Defs.Abilities.EquipStand.Cooldown)
                ManageStand.RemoveStand(initPlayer)     

            end
        end

        -- EQUIP STAND/EXECUTE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            -- no action here
        end
    end
end

-------------------------------------------------------------------------------------------------
--// Ability_E //---------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

function Noob.Ability_E(initPlayer,params)


    -- Ability_E/INIALIZE  ----------------------------------------------------------------------------
    if params.SystemStage == "Intialize" then

        -- Ability_E/INIALIZE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
            params.CanRun = true
        end

        -- Ability_E/INIALIZE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            params.CanRun = false
        end
    end

    -- Ability_E/ACTIVATE  ----------------------------------------------------------------------------
    if params.SystemStage == "Activate" then

        -- Ability_E/ACTIVATE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
            params.CanRun = true
        end

        -- Ability_E/ACTIVATE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            params.CanRun = false
        end
    end

    -- Ability_E/EXECUTE ----------------------------------------------------------------------------
    if params.SystemStage == "Execute" then

        -- Ability_E/EXECUTE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
 
        end

        -- Ability_E/EXECUTE/INPUT ENDED
        if params.KeyState == "InputEnded" then

        end

    end
end

-------------------------------------------------------------------------------------------------
--// Ability_R //---------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

function Noob.Ability_R(initPlayer,params)


    -- Ability_R/INIALIZE  ----------------------------------------------------------------------------
    if params.SystemStage == "Intialize" then

        -- Ability_R/INIALIZE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
            params.CanRun = true
        end

        -- Ability_R/INIALIZE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            params.CanRun = false
        end
    end

    -- Ability_R/ACTIVATE  ----------------------------------------------------------------------------
    if params.SystemStage == "Activate" then

        -- Ability_R/ACTIVATE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
            params.CanRun = true
        end

        -- Ability_R/ACTIVATE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            params.CanRun = false
        end
    end

    -- Ability_R/EXECUTE ----------------------------------------------------------------------------
    if params.SystemStage == "Execute" then

        -- Ability_R/EXECUTE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
 
        end

        -- Ability_R/EXECUTE/INPUT ENDED
        if params.KeyState == "InputEnded" then

        end

    end
end

-------------------------------------------------------------------------------------------------
--// Ability_T //---------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

function Noob.Ability_T(initPlayer,params)


    -- Ability_T/INIALIZE  ----------------------------------------------------------------------------
    if params.SystemStage == "Intialize" then

        -- Ability_T/INIALIZE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
            params.CanRun = true
        end

        -- Ability_T/INIALIZE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            params.CanRun = false
        end
    end

    -- Ability_T/ACTIVATE  ----------------------------------------------------------------------------
    if params.SystemStage == "Activate" then

        -- Ability_T/ACTIVATE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
            params.CanRun = true
        end

        -- Ability_T/ACTIVATE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            params.CanRun = false
        end
    end

    -- Ability_T/EXECUTE ----------------------------------------------------------------------------
    if params.SystemStage == "Execute" then

        -- Ability_T/EXECUTE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
 
        end

        -- Ability_T/EXECUTE/INPUT ENDED
        if params.KeyState == "InputEnded" then

        end

    end
end

-------------------------------------------------------------------------------------------------
--// Ability_F //---------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

function Noob.Ability_F(initPlayer,params)


    -- Ability_F/INIALIZE  ----------------------------------------------------------------------------
    if params.SystemStage == "Intialize" then

        -- Ability_F/INIALIZE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
            params.CanRun = true
        end

        -- Ability_F/INIALIZE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            params.CanRun = false
        end
    end

    -- Ability_F/ACTIVATE  ----------------------------------------------------------------------------
    if params.SystemStage == "Activate" then

        -- Ability_F/ACTIVATE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
            params.CanRun = true
        end

        -- Ability_F/ACTIVATE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            params.CanRun = false
        end
    end

    -- Ability_F/EXECUTE ----------------------------------------------------------------------------
    if params.SystemStage == "Execute" then

        -- Ability_F/EXECUTE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
 
        end

        -- Ability_F/EXECUTE/INPUT ENDED
        if params.KeyState == "InputEnded" then

        end

    end
end

-------------------------------------------------------------------------------------------------
--// Ability_Z //---------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

function Noob.Ability_Z(initPlayer,params)


    -- Ability_Z/INIALIZE  ----------------------------------------------------------------------------
    if params.SystemStage == "Intialize" then

        -- Ability_Z/INIALIZE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
            params.CanRun = true
        end

        -- Ability_Z/INIALIZE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            params.CanRun = false
        end
    end

    -- Ability_Z/ACTIVATE  ----------------------------------------------------------------------------
    if params.SystemStage == "Activate" then

        -- Ability_Z/ACTIVATE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
            params.CanRun = true
        end

        -- Ability_Z/ACTIVATE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            params.CanRun = false
        end
    end

    -- Ability_Z/EXECUTE ----------------------------------------------------------------------------
    if params.SystemStage == "Execute" then

        -- Ability_Z/EXECUTE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
 
        end

        -- Ability_Z/EXECUTE/INPUT ENDED
        if params.KeyState == "InputEnded" then

        end

    end
end

-------------------------------------------------------------------------------------------------
--// Ability_X //---------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

function Noob.Ability_X(initPlayer,params)


    -- Ability_X/INIALIZE  ----------------------------------------------------------------------------
    if params.SystemStage == "Intialize" then

        -- Ability_X/INIALIZE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
            params.CanRun = true
        end

        -- Ability_X/INIALIZE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            params.CanRun = false
        end
    end

    -- Ability_X/ACTIVATE  ----------------------------------------------------------------------------
    if params.SystemStage == "Activate" then

        -- Ability_X/ACTIVATE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
            params.CanRun = true
        end

        -- Ability_X/ACTIVATE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            params.CanRun = false
        end
    end

    -- Ability_X/EXECUTE ----------------------------------------------------------------------------
    if params.SystemStage == "Execute" then

        -- Ability_X/EXECUTE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
 
        end

        -- Ability_X/EXECUTE/INPUT ENDED
        if params.KeyState == "InputEnded" then

        end

    end
end