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

local TheWorld = {}


TheWorld.Defs = {
    PowerName = "The World",
    StandModel = ReplicatedStorage.Effects.StandModels.TheWorld,

    Animations = {
        Idle = {
            Name = "Idle",
            Address = "http://www.roblox.com/asset/?id=5723101276"
        },

        Barrage = {
            Name = "Barrage",
            Address = "http://www.roblox.com/asset/?id=5736797194"
        }
    },

    Abilities = {

        EquipStand = {
            Name = "Equip Stand",
            Duration = 0,
            CoolDown = 5,
            Override = false
        },

        Barrage = {
            Name = "Barrage",
            Duration = 5,
            CoolDown = 0,
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

--[[
--// EFFECTS
module.Effects = {}

module.Effects.StandTrails = {
	Default = {
		MaxLength = 2,
		Lifetime = .5,
		Transparency = NumberSequence.new(.95)
	},
	Active = {
		MaxLength = 30,
		Lifetime = 4,
		Transparency = NumberSequence.new(.8)
	}
}
]]--

--// MANAGER - this is the single point of entry from PowerService.
function TheWorld.Manager(initPlayer,params)

    print(utils)
    print(powerUtils)
    for i,v in pairs(Knit.Shared) do
        print(i,v)
    end
    --powerUtils.Test("poop")

    --local params = powerUtils.CheckCooldown(initPlayer,params)
    --if params.CanRun == false then
        --return
    --end
    
    -- call the function
    if params.Key == "Q" then
        TheWorld.EquipStand(initPlayer,params)
    elseif params.Kay == "E" then
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
        standToggle = utils.EasyInstance("BoolValue",{Name = "StandActive",Value = false,Parent = ReplicatedStorage.PowerStatus[initPlayer.UserId]})
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
            if standToggle == true then
                standToggle = false
            else
                standToggle = true
            end
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
            if params.Toggle then
                print("equip stand - STAND ON")
            else
                print("equip stand - STAND OFF")
            end
        end

        -- INPUT ENDED
        if params.KeyState == "InputEnded" then
            -- no action here
        end

    end

    return params
end

--// ABILITY 2 - BARRAGE //---------------------------------------------------------------------------------
function TheWorld.Barrage(initPlayer,params)

    -- INIALIZE
    if params.SystemStage == "Intialize" then

    end

    -- ACTIVATE
    if params.SystemStage == "Activate" then

    end

    -- EXECUTE
    if params.SystemStage == "Execute" then

    end
end

return TheWorld