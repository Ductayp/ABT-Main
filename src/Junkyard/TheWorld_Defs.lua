--// THE WORLD - DEFINITIONS
replicatedStorage = game:GetService("ReplicatedStorage")

local module = {}

module.PowerName = "The World"
module.StandModel = replicatedStorage.Effects.StandModels.TheWorld

--// ANIMATIONS
module.Animations = {}

module.Animations.Idle = {}
module.Animations.Idle.Name = "Idle"
module.Animations.Idle.Address = "http://www.roblox.com/asset/?id=5723101276"

module.Animations.Barrage = {}
module.Animations.Barrage.Name = "Barrage"
module.Animations.Barrage.Address = "http://www.roblox.com/asset/?id=5736797194"

--// ABILITIES
module.Ability_1 = {
	Name = "Equip Stand",
	Duration = 0,
	Cooldown = 5,
	CoolDown_InputBegan = true,
	CoolDown_InputEnded = true,
	AbilityPreReq = nil,
	Override = false
}

module.Ability_2 = {
	Name = "Barrage",
	Duration = 5,
	Cooldown = 5,
	CoolDown_InputBegan = false,
	CoolDown_InputEnded = true,
	AbilityPreReq = {"Ability_1"},
	Override = true,
	--SFX = replicatedStorage.Audio.SFX.TheWorld.Barrage	
}

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



return module
