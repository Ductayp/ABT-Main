return {
	Name = "setSpawn";
	Aliases = {};
	Description = "Set a players spawn location";
	Group = "Moderator";
	Args = {
		{
			Type = "player";
			Name = "Target Player";
			Description = "The player to set the spawn for";
		},
		{
			Type = "spawnGroup";
			Name = "Spawn Group Name";
			Description = "this must be a valid spawn area name"
		},
		{
			Type = "boolean";
			Name = "Respawn";
			Description = "choose to respawn the player or not"
		},

	};
}