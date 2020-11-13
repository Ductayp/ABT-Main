-- TheWorld
-- PDab
-- 11/12/2020
--[[
Handles all thing related to the power and is triggered by BOTH PowersController AND PowerService
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

        Ability_1 = {
            Name = "Equip Stand",
            Duration = 0,
            CoolDown_InputBegan = 5,
            CoolDown_InputEnded = 5,
            AbilityPreReq = nil,
            Override = false
        },

        Ability_2 = {
            Name = "Barrage",
            Duration = 5,
            CoolDown_InputBegan = 0,
            CoolDown_InputEnded = 5,
            AbilityPreReq = {"Ability_1"},
            Override = true,
        },

        Ability_3 = {
            Name = "Ability 3",
            Duration = 0,
            Cooldown = 1,
            CoolDown_InputBegan = false,
            CoolDown_InputEnded = true,
            AbilityPreReq = nil,
            Override = false,
        },

        Ability_4 = {
            Name = "Ability 4",
            Duration = 0,
            Cooldown = 1,
            CoolDown_InputBegan = false,
            CoolDown_InputEnded = true,
            AbilityPreReq = nil,
            Override = false,
        },

        Ability_5 = {
            Name = "Ability 5",
            Duration = 0,
            Cooldown = 1,
            CoolDown_InputBegan = false,
            CoolDown_InputEnded = true,
            AbilityPreReq = nil,
            Override = false,
        },

        Ability_6 = {
            Name = "Ability 6",
            Duration = 0,
            Cooldown = 1,
            CoolDown_InputBegan = false,
            CoolDown_InputEnded = true,
            AbilityPreReq = nil,
            Override = false,
        },

        Ability_7 = {
            Name = "Ability 7",
            Duration = 0,
            Cooldown = 1,
            CoolDown_InputBegan = false,
            CoolDown_InputEnded = true,
            AbilityPreReq = nil,
            Override = false,
        },

        Ability_8 = {
            Name = "Ability 8",
            Duration = 0,
            Cooldown = 1,
            CoolDown_InputBegan = false,
            CoolDown_InputEnded = true,
            AbilityPreReq = nil,
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

--// ABILITY 1 - EQUIP STAND
function TheWorld.Ability_1(player,params)

    -- INIALIZE
    if params.SystemStage == "Intialize" then
    print("The World - Initialize")

        -- INPUT BEGAN
        if params.KeyState == "InputBegan" then
            params.CanRun = true
        end

        -- INPUT ENDED
        if params.KeyState == "InputEnded" then
            params.CanRun = false
        end
        
        return params
    end

    -- ACTIVATE
    if params.SystemStage == "Activate" then
        print("The World - Activate")

    end

    -- EXECUTE
    if params.SystemStage == "Execute" then
        print("The World - Execute")

    end
end

--// ABILITY 2 - BARRAGE
function TheWorld.Ability_2(player,params)

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