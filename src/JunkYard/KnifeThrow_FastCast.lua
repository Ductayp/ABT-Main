-- Knife Throw Ability
-- PDab
-- 11-27-2020

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Knit and modules
local Knit = require(ReplicatedStorage:FindFirstChild("Knit",true))
local utils = require(Knit.Shared.Utils)
local powerUtils = require(Knit.Shared.PowerUtils)
local FastCast = require(Knit.Shared.FastCastRedux)

-- Constants
local DEBUG = false								-- Whether or not to use debugging features of FastCast, such as cast visualization.
local BULLET_SPEED = 100							-- Studs/second - the speed of the bullet
local BULLET_MAXDIST = 1000							-- The furthest distance the bullet can travel 
local BULLET_GRAVITY = Vector3.new(0, -workspace.Gravity, 0)		-- The amount of gravity applied to the bullet in world space (so yes, you can have sideways gravity)
local MIN_BULLET_SPREAD_ANGLE = 1					-- THIS VALUE IS VERY SENSITIVE. Try to keep changes to it small. The least accurate the bullet can be. This angle value is in degrees. A value of 0 means straight forward. Generally you want to keep this at 0 so there's at least some chance of a 100% accurate shot.
local MAX_BULLET_SPREAD_ANGLE = 4					-- THIS VALUE IS VERY SENSITIVE. Try to keep changes to it small. The most accurate the bullet can be. This angle value is in degrees. A value of 0 means straight forward. This cannot be less than the value above. A value of 90 will allow the gun to shoot sideways at most, and a value of 180 will allow the gun to shoot backwards at most. Exceeding 180 will not add any more angular varience.
local FIRE_DELAY = 0								-- The amount of time that must pass after firing the gun before we can fire again.
local BULLETS_PER_SHOT = 1							-- The amount of bullets to fire every shot. Make this greater than 1 for a shotgun effect.
local PIERCE_DEMO = true

-- setup FastCast casters
local serverCaster
local playerCasters = {} -- a table holding all the caster for each player, is removed when a player leaves by the event below to prevent memory leaks
Players.PlayerRemoving:Connect(function(player)
    playerCasters[player.UserId] = nil
end)

-- cast objects

-- Cosmetic bullet container
local CosmeticBulletsFolder = workspace:FindFirstChild("CosmeticBulletsFolder") or Instance.new("Folder", workspace)
CosmeticBulletsFolder.Name = "CosmeticBulletsFolder"

-- setup cosmetic bullet
local CosmeticBullet = Instance.new("Part")
CosmeticBullet.Material = Enum.Material.Neon
CosmeticBullet.Color = Color3.fromRGB(0, 196, 255)
CosmeticBullet.CanCollide = false
CosmeticBullet.Anchored = true
CosmeticBullet.Size = Vector3.new(0.2, 0.2, 2.4)

-- New raycast parameters.
local CastParams = RaycastParams.new()
CastParams.IgnoreWater = true
CastParams.FilterType = Enum.RaycastFilterType.Blacklist
CastParams.FilterDescendantsInstances = {}

-- cast behaviors
local CastBehavior = FastCast.newBehavior()
CastBehavior.RaycastParams = CastParams
CastBehavior.MaxDistance = BULLET_MAXDIST
CastBehavior.HighFidelityBehavior = FastCast.HighFidelityBehavior.Default

CastBehavior.CosmeticBulletTemplate = CosmeticBullet -- Uncomment if you just want a simple template part and aren't using PartCache
CastBehavior.CosmeticBulletProvider = CosmeticPartProvider -- Comment out if you aren't using PartCache.

CastBehavior.CosmeticBulletContainer = CosmeticBulletsFolder
CastBehavior.Acceleration = BULLET_GRAVITY
CastBehavior.AutoIgnoreContainer = false -- We already do this! We don't need the default value of true (see the bottom of this script)


local KnifeThrow = {}

function KnifeThrow.Server_ThrowKnife(initPlayer,params,knifThrowParams)
    print("hi lets throw a knife!")

    local knifeOrigin = initPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(2,1,2.5) -- this is the same CFrame offset we use in ManageStand
    
    --setup the serverCaster if it doesnt exist already
    if not serverCaster then
        serverCaster = FastCast.new()
    end

    -- get the players caster, do we need this in the server end of the module?
    if not playerCasters[initPlayer.UserId] then
       playerCasters[initPlayer.UserId] = FastCast.new()
    end
    local playerCaster = playerCasters[initPlayer.UserId]

    -- set the direction to the stands CFrame
    local direction = initPlayer.Character.HumanoidRootPart.CFrame.LookVector -- just use the players direction for now

    --[[
    -- modify the bullet speed according to player movement
    local humanoidRootPart = Tool.Parent:WaitForChild("HumanoidRootPart", 1)	-- Add a timeout to this.
	local myMovementSpeed = humanoidRootPart.Velocity							-- To do: It may be better to get this value on the clientside since the server will see this value differently due to ping and such.
	local modifiedBulletSpeed = (direction * BULLET_SPEED)-- + myMovementSpeed	-- We multiply our direction unit by the bullet speed. This creates a Vector3 version of the bullet's velocity at the given speed. We then add MyMovementSpeed to add our body's motion to the velocity.
    ]]--

    local CastBehavior = {}

    serverCaster:Fire(knifeOrigin.Position, direction, BULLET_SPEED, CastBehavior)

end

return KnifeThrow


