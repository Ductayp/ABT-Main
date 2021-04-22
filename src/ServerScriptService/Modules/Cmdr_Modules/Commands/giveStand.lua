return {
	Name = "giveStand";
	Aliases = {};
	Description = "Give a Stand to a player";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "player";
			Name = "Target Player";
			Description = "The player to give to";
		},
		{
			Type = "standName";
			Name = "StandName";
			Description = "Stand Name must be the actual dataKey. Example: TheWorld"
		},
		{
			Type = "integer";
			Name = "Value";
			Description = "rank can be the numbers 1-3"
		} 
	};
}