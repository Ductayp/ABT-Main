return {
	Name = "mutePlayer";
	Aliases = {};
	Description = "Give a Boost to a player";
	Group = "Moderator";
	Args = {
		{
			Type = "player";
			Name = "Target Player";
			Description = "The player to give to";
		},
		{
			Type = "boolean";
			Name = "true/false";
			Description = "Mute true or false";
		},
	};
}