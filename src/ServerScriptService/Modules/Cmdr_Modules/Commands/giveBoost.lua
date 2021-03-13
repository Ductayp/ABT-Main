return {
	Name = "giveBoost";
	Aliases = {};
	Description = "Give a Boost to a player";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "player";
			Name = "Target Player";
			Description = "The player to give to";
		},
		{
			Type = "boost";
			Name = "Boost Key";
			Description = "The key must exist in PlayerData"
		},
		{
			Type = "integer";
			Name = "Value";
			Description = "How much time to give in SECONDS"
		}
	};
}