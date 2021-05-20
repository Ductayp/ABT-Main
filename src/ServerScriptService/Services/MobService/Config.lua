local Config = {}

Config.MobCollide = false -- Great For Optimization, turn it off for NPC-NPC collision, if PlayerCollide is off it'll also remove collision with players;
Config.PlayerCollide = false -- Greate For Optimization, turn it off for Player-Player and Player-NPC collision;
Config.NetworkOwner_Server = true
Config.HumanoidStates = { -- | To optimize
	[Enum.HumanoidStateType.Climbing] = false,
	[Enum.HumanoidStateType.Dead] = false,
	[Enum.HumanoidStateType.FallingDown] = false,
	[Enum.HumanoidStateType.Freefall] = true,
	[Enum.HumanoidStateType.Flying] = false,
	[Enum.HumanoidStateType.GettingUp] = true,
	[Enum.HumanoidStateType.Jumping] = true,
	[Enum.HumanoidStateType.Landed] = true,
	[Enum.HumanoidStateType.Physics] = true,
	[Enum.HumanoidStateType.PlatformStanding] = true,
	[Enum.HumanoidStateType.Ragdoll] = false,
	[Enum.HumanoidStateType.Running] = true,
	[Enum.HumanoidStateType.RunningNoPhysics] = true,
	[Enum.HumanoidStateType.Seated] = false,
	[Enum.HumanoidStateType.StrafingNoPhysics] = true,
	[Enum.HumanoidStateType.Swimming] = false,	
};

return Config
