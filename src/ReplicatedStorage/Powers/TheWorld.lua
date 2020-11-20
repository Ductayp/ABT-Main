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
local ManageStand = require(Knit.Effects.ManageStand)
local Barrage = require(Knit.Effects.Barrage)

local TheWorld = {}


TheWorld.Defs = {
    PowerName = "The World",


    StandModel = ReplicatedStorage.EffectParts.StandModels.TheWorld,


    Abilities = {

        EquipStand = {
            Name = "Equip Stand",
            Cooldown = 5,
            Override = false
        },

        Barrage = {
            Name = "Barrage",
            Duration = 5,
            Cooldown = 5,
            Override = true
        },

        Ability_3 = {
            Name = "Ability 3",
            Duration = 0,
            Cooldown = 1,
            Override = false
        },

        Ability_4 = {
            Name = "Ability 4",
            Duration = 0,
            Cooldown = 1,
            Override = false
        },

        Ability_5 = {
            Name = "Ability 5",
            Duration = 0,
            Cooldown = 1,
            Override = false
        },

        Ability_6 = {
            Name = "Ability 6",
            Duration = 0,
            Cooldown = 1,
            Override = false
        },

        Ability_7 = {
            Name = "Ability 7",
            Duration = 0,
            Cooldown = 1,
            Override = false
        },

        Ability_8 = {
            Name = "Ability 8",
            Duration = 0,
            Cooldown = 1,
            Override = false,
        },
    }
}

--// MANAGER - this is the single point of entry from PowerService.
function TheWorld.Manager(initPlayer,params)

    -- check cooldowns but only on SystemStage "Activate"
    if params.SystemStage == "Activate" then
        local params = powerUtils.CheckCooldown(initPlayer,params) -- returns params
        if params.CanRun == false then
            return params
        end
    end
    
    -- call the function
    if params.Key == "Q" then
        TheWorld.EquipStand(initPlayer,params)
    elseif params.Key == "E" then
        TheWorld.Barrage(initPlayer,params)
    end

    return params
end

--// ABILITY 1 - EQUIP STAND //---------------------------------------------------------------------------------
function TheWorld.EquipStand(initPlayer,params)
    
    -- get stand folder, setup if it doesnt exist
    local playerStandFolder = workspace.PlayerStands:FindFirstChild(initPlayer.UserId)

    -- get stand toggle, setup if it doesnt exist
    local standToggle = ReplicatedStorage.PowerStatus[initPlayer.UserId]:FindFirstChild("StandActive")
    if not standToggle and RunService:IsServer() then
        standToggle = utils.EasyInstance("BoolValue",{Name = "StandActive",Value = value,Parent = ReplicatedStorage.PowerStatus[initPlayer.UserId]})
    end

    -- INITIALIZE
    if params.SystemStage == "Intialize" then
    print("The World - Equip Stand - Initialize")

        -- INPUT BEGAN
        if params.KeyState == "InputBegan" then
            params.CanRun = true
        end

        -- INPUT ENDED
        if params.KeyState == "InputEnded" then
            params.CanRun = false
        end
    end

    -- ACTIVATE
    if params.SystemStage == "Activate" then
        print("The World - Equip Stand - Activate")

         -- INPUT BEGAN
         if params.KeyState == "InputBegan" then
            if standToggle.Value == true then
                standToggle.Value = false
            else
                standToggle.Value = true
            end
            powerUtils.SetCooldown(initPlayer,params,TheWorld.Defs.Abilities.EquipStand.Cooldown)
            params.CanRun = true
        end

        -- INPUT ENDED
        if params.KeyState == "InputEnded" then
            params.CanRun = false
        end
    end

    -- EXECUTE
    if params.SystemStage == "Execute" then
        print("The World - Equip Stand - Execute")

         -- INPUT BEGAN
         if params.KeyState == "InputBegan" then
            if standToggle.Value == true then
                print("equip stand - STAND ON")
                ManageStand.EquipStand(initPlayer,TheWorld.Defs.StandModel)
            else
                print("equip stand - STAND OFF")
                ManageStand.RemoveStand(initPlayer)
            end
        end

        -- INPUT ENDED
        if params.KeyState == "InputEnded" then
            -- no action here
        end
    end

    return params
end

--// BARRAGE //---------------------------------------------------------------------------------
function TheWorld.Barrage(initPlayer,params)

    -- get barrage toggle, setup if it doesnt exist
    local barrageToggle = ReplicatedStorage.PowerStatus[initPlayer.UserId]:FindFirstChild("BarrageActive")
    if not barrageToggle and RunService:IsServer() then
        barrageToggle = utils.EasyInstance("BoolValue",{Name = "BarrageActive",Value = value,Parent = ReplicatedStorage.PowerStatus[initPlayer.UserId]})
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
            if barrageToggle.Value == false then
                barrageToggle.Value = true
                params.CanRun = true

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
            if barrageToggle.Value == true then
                barrageToggle.Value = false
                params.CanRun = true
                powerUtils.SetCooldown(initPlayer,params,TheWorld.Defs.Abilities.Barrage.Cooldown)
            end

        end
    end

    -- BARRAGE/EXECUTE
    if params.SystemStage == "Execute" then
        -- BARRAGE/EXECUTE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
            if barrageToggle.Value == true then
                print("barrage is ON")
                Barrage.RunEffect(initPlayer,params)
            end
        end

        -- BARRAGE/EXECUTE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            if barrageToggle.Value == false then
                print("barrage is OFF")
                Barrage.EndEffect(initPlayer,params)
            end 
        end
    end
end

return TheWorld