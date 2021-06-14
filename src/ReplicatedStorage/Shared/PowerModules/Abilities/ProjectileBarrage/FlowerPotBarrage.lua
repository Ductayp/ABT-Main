-- FlowerPotBarrage

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local WeldedSound = require(Knit.PowerUtils.WeldedSound)
local ManageStand = require(Knit.Abilities.ManageStand)

local module = {}

-- MobilityLock params
module.PlayerAnchorTime = 1
module.ShiftLock_NoSpin = true
module.AnchorCharacter = true

-- shot pattern params
module.ShotDelay = 0.3
module.ShotCount = 3
module.Offset_X = 2.5
module.Offset_Y = 2
module.Offset_Z = -2

-- ray box params
module.Size_X = 1
module.Size_Y = 1
module.Velocity = 300
module.Lifetime = 2
module.Iterations = 1000

module.HitEffects = {Damage = {Damage = 10}}

--// CharacterAnimations - client
function module.CharacterAnimations()


end

--// GetProjectile - server
function module.GetProjectile()


end

--// ProjectileAnimations - client
function module.ProjectileAnimations()


end

--// ProjectileImpact - client
function module.ProjectileImpact()


end



return module