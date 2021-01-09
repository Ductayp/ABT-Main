-- Crazy Diamond
-- PDab
-- 1/8/2020

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)

-- Effect modules
local AbilityToggle = require(Knit.Effects.AbilityToggle)
local Cooldown = require(Knit.Effects.Cooldown)
local SoundPlayer = require(Knit.Effects.SoundPlayer)


-- Ability modules
local ManageStand = require(Knit.Abilities.ManageStand)
local Barrage = require(Knit.Abilities.Barrage)
local HeavyPunch = require(Knit.Abilities.HeavyPunch)

local CrazyDiamond = {}


CrazyDiamond.Defs = {

    -- just some general defs here
    PowerName = "Crazy Diamond",
    SacrificeValue = {
        Common = 20,
        Rare = 25,
        Legendary = 30,
    },
    StandModels = {
        Common = ReplicatedStorage.EffectParts.StandModels.CrazyDiamond_Common,
        Rare = ReplicatedStorage.EffectParts.StandModels.CrazyDiamond_Rare,
        Legendary = ReplicatedStorage.EffectParts.StandModels.CrazyDiamond_Legendary,
    },
    Abilities = {
        EquipStand = {
            Name = "Equip Stand",
            Cooldown = 1,
            Override = false,
        },
        Barrage = {
            Name = "Barrage",
            AbilityId = "Barrage",
            Duration = 5,
            Cooldown = 10,
            Override = true,
            Damage = 5,
            loopTime = .25
        }
    }
}

--// SETUP - run this once when the stand is equipped
function CrazyDiamond.SetupPower(initPlayer,params)

end

--// REMOVE - run this once when the stand is un-equipped
function CrazyDiamond.RemovePower(initPlayer,params)

end

--// MANAGER - this is the single point of entry from PowersService and PowersController.
function CrazyDiamond.Manager(initPlayer,params)

    -- check cooldowns but only on SystemStage "Activate"
    if params.SystemStage == "Activate" then
        local cooldown = Cooldown.GetCooldownValue(initPlayer, params)
        print(os.time(), cooldown)
        if os.time() <= cooldown then
            params.CanRun = false
            return params
        end
    end

    -- call the function
    if params.InputId == "Q" then
        CrazyDiamond.EquipStand(initPlayer,params)
    elseif params.InputId == "E" then
        CrazyDiamond.Barrage(initPlayer,params)
    elseif params.InputId == "R" then
        print("No Ability for this Key")
    elseif params.InputId == "T" then
        print("No Ability for this Key")
    elseif params.InputId == "F" then
        print("No Ability for this Key")
    elseif params.InputId == "Z" then
        print("No Ability for this Key")
    elseif params.InputId == "X" then
        print("No Ability for this Key")
    elseif params.InputId == "C" then
        print("No Ability for this Key")
    end

    return params
end

--------------------------------------------------------------------------------------------------
--// EQUIP STAND //-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

function CrazyDiamond.EquipStand(initPlayer,params)
    

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
            Cooldown.SetCooldown(initPlayer,params.InputId,CrazyDiamond.Defs.Abilities.EquipStand.Cooldown)

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

         -- EQUIP STAND/EXECUTE/INPUT BEGAN
         if params.KeyState == "InputBegan" then
            if AbilityToggle.GetToggleObject(initPlayer,params.InputId).Value == true then
                SoundPlayer.WeldSound(initPlayer.Character.HumanoidRootPart, ReplicatedStorage.Audio.SFX.StandSounds.TheWorld.Summon)
                ManageStand.EquipStand(initPlayer,CrazyDiamond.Defs.StandModels[params.PowerRarity])
            else
                -- weld sound here
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

function CrazyDiamond.Barrage(initPlayer,params)

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
            if barrageToggle.Value == false then
                barrageToggle.Value = true
                params.CanRun = true
      
                Barrage.Server_CreateHitbox(initPlayer, barrageParams)

                -- spawn a function to kill the barrage if the duration expires
                spawn(function()
                    wait(CrazyDiamond.Defs.Abilities.Barrage.Duration)
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

                -- set the cooldown
                Cooldown.SetCooldown(initPlayer,params.InputId,CrazyDiamond.Defs.Abilities.EquipStand.Cooldown)

                -- destroy hitbox
                Barrage.Server_DestroyHitbox(initPlayer, barrageParams)
            end
        end
    end

    -- BARRAGE/EXECUTE
    if params.SystemStage == "Execute" then

        -- BARRAGE/EXECUTE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
            if barrageToggle.Value == true then
                Barrage.RunEffect(initPlayer,params)

                local soundParams = {}
                soundParams.SoundProperties = {}
                soundParams.SoundProperties.Looped = false
                -- weld sound here
            end
        end

        -- BARRAGE/EXECUTE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            if barrageToggle.Value == false then
                Barrage.EndEffect(initPlayer,params)
                -- weld sound here
            end 
        end
    end
end


return CrazyDiamond