-- Standless
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


local Standless = {}

Standless.Defs = {
    PowerName = "Standless",
    BaseSacrificeValue = 0,
    Abilities = {}, -- ability defs are inside each ability function area
    KeyMap = {
        [1] = {
            Q = {AbilityName = "-"},
            E = {AbilityName = "-"},
            F = {AbilityName = "-"},
            T = {AbilityName = "-"},
            R = {AbilityName = "-"},
            X = {AbilityName = "-"},
            Z = {AbilityName = "-"},
            C = {AbilityName = "-"}
        },
        [2] = {
            Q = {AbilityName = "-"},
            E = {AbilityName = "-"},
            F = {AbilityName = "-"},
            T = {AbilityName = "-"},
            R = {AbilityName = "-"},
            X = {AbilityName = "-"},
            Z = {AbilityName = "-"},
            C = {AbilityName = "-"}
        },
        [3] = {
            Q = {AbilityName = "-"},
            E = {AbilityName = "-"},
            F = {AbilityName = "-"},
            T = {AbilityName = "-"},
            R = {AbilityName = "-"},
            X = {AbilityName = "-"},
            Z = {AbilityName = "-"},
            C = {AbilityName = "-"}
        },
    }
}

--// SETUP - run this once when the stand is equipped
function Standless.SetupPower(initPlayer,params)

end

--// REMOVE - run this once when the stand is un-equipped
function Standless.RemovePower(initPlayer,params)

end


--// MANAGER - this is the single point of entry from PowerService.
function Standless.Manager(params)

    -- call the function
        if params.InputId == "Q" then
            --Standless.EquipStand(params)
        elseif params.InputId == "E" then
            --Standless.Barrage(params)
        elseif params.InputId == "F" then
            --Standless.TimeStop(params)
        elseif params.InputId == "T" then
            --Standless.KnifeThrow(params)
        elseif params.InputId == "R" then
            --Standless.HeavyPunch(params)
        elseif params.InputId == "X" then
            --Standless.BulletKick(params)
        elseif params.InputId == "Z" then
            --Standless.StandJump(params)
        elseif params.InputId == "Mouse1" then
            Standless.Punch(params)
        end
    
        return params
end

--------------------------------------------------------------------------------------------------
--// PUNCH //------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- defs
Standless.Defs.Abilities.Punch = {
    Name = "Punch",
    Id = "Punch",
    Cooldown = 0.5,
    HitEffects = {Damage = {Damage = 5}},
    --RequireToggle_On = {},
    --RequireToggle_Off = {"Mouse1"},
}

function Standless.Punch(params)
    params = require(Knit.Abilities.Punch)[params.SystemStage](params, Standless.Defs.Abilities.Punch)
end


return Standless