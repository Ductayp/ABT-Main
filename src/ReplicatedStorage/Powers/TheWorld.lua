-- TheWorld
-- PDab
-- 11/12/2020
--[[
Handles all thing related to the power and is triggered by BOTH PowersController AND PowerService
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)
local ManageStand = require(Knit.Effects.ManageStand)
local Barrage = require(Knit.Effects.Barrage)
local RaycastHitbox = require(Knit.Shared.RaycastHitboxV3)

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
            AbilityId = "Barrage",
            Duration = 20,
            Cooldown = 1,
            Override = true,
            Damage = 5,
            loopTime = .25
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
        local cooldown = powerUtils.GetCooldown(initPlayer,params)
        if os.time() < cooldown.Value  then
            params.CanRun = false
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

--// EQUIP STAND //---------------------------------------------------------------------------------
function TheWorld.EquipStand(initPlayer,params)
    
    -- get stand folder, setup if it doesnt exist
    local playerStandFolder = workspace.PlayerStands:FindFirstChild(initPlayer.UserId)

    -- get stand toggle, setup if it doesnt exist
    local standToggle = powerUtils.GetToggle(initPlayer,params.Key)

    -- EQUIP STAND/INITIALIZE
    if params.SystemStage == "Intialize" then
    print("The World - Equip Stand - Initialize")

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
        print("The World - Equip Stand - Activate")

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
                print("equip stand - STAND ON")
                powerUtils.SetGUICooldown(params.Key,TheWorld.Defs.Abilities.EquipStand.Cooldown)
                ManageStand.EquipStand(initPlayer,TheWorld.Defs.StandModel)
            else
                print("equip stand - STAND OFF")
                powerUtils.SetGUICooldown(params.Key,TheWorld.Defs.Abilities.EquipStand.Cooldown)
                ManageStand.RemoveStand(initPlayer)
            end
        end

        -- EQUIP STAND/EXECUTE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            -- no action here
        end
    end
end

--// BARRAGE //---------------------------------------------------------------------------------
function TheWorld.Barrage(initPlayer,params)

    -- get barrage toggle, setup if it doesnt exist
    local barrageToggle = powerUtils.GetToggle(initPlayer,params.Key)

    -- requires Stand to be active via "Q" toggle
    local standToggle  = powerUtils.GetToggle(initPlayer,"Q")
    if RunService:IsServer() and standToggle.Value == false then
        print("Stand not active, cannot run this ability")
        params.CanRun = false
        return
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
      
                -- spawn a hitbox in
                local hitbox = utils.EasyInstance("Part",{Name = "Barrage",Parent = workspace.PlayerHitboxes[initPlayer.UserId],CanCollide = false,Transparency = .5, Size = Vector3.new(4,2,2)})
                hitbox.CFrame = initPlayer.Character.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,1,-6.75))
                local hitboxWeld = utils.EasyWeld(hitbox,initPlayer.Character.HumanoidRootPart,hitbox)
                
                local isCoolingDown = false
                hitbox.Touched:Connect(function(hit)
                    if hit.Parent:FindFirstChild("Humanoid") and not isCoolingDown then

                        isCoolingDown = true
                        local character = hit.Parent

                        local hitParams = {
                            damage = TheWorld.Defs.Abilities.Barrage.Damage,
                            hitReceiver = character, -- is the character, can be a player or an NPC
                            hitDealer = initPlayer,
                            powerId = params.powerId,
                            abilityId = TheWorld.Defs.Abilities.Barrage.AbilityId
                        }
                        Knit.Services.PowersService:RegisterHit(hitParams)
                        --character.Humanoid:TakeDamage(TheWorld.Defs.Abilities.Barrage.Damage)
                        wait(TheWorld.Defs.Abilities.Barrage.loopTime)
                        isCoolingDown = false
                    end
                end)

                

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

                -- set the cooldown
                powerUtils.SetCooldown(initPlayer,params,TheWorld.Defs.Abilities.Barrage.Cooldown)

                -- destroy hitbox
                local destroyHitbox = workspace.PlayerHitboxes[initPlayer.UserId]:FindFirstChild("Barrage")
                if destroyHitbox then
                    destroyHitbox:Destroy()
                end
            end

        end
    end

    -- BARRAGE/EXECUTE
    if params.SystemStage == "Execute" then
        -- BARRAGE/EXECUTE/INPUT BEGAN
        if params.KeyState == "InputBegan" then
            if barrageToggle.Value == true then
                Barrage.RunEffect(initPlayer,params)
            end
        end

        -- BARRAGE/EXECUTE/INPUT ENDED
        if params.KeyState == "InputEnded" then
            if barrageToggle.Value == false then
                powerUtils.SetGUICooldown(params.Key,TheWorld.Defs.Abilities.Barrage.Cooldown)
                Barrage.EndEffect(initPlayer,params)
            end 
        end
    end
end

return TheWorld