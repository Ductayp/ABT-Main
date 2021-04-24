-- StandSteal

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StandSteal = {}

StandSteal.HitDelay = 0
StandSteal.Range = 15
StandSteal.HitEffects = {Damage = {Damage = 10}}


-- audio
StandSteal.FireSound = ReplicatedStorage.Audio.General.GenericWhoosh_Fast

return StandSteal