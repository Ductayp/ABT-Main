return {
	Name = "giveCurrency";
	Aliases = {};
	Description = "Give currency to a player";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "player";
			Name = "Target Player";
			Description = "The player to give to";
		},
		{
			Type = "currency";
			Name = "Currency Key";
			Description = "The key must be: Cash or SoulOrbs"
		},
		{
			Type = "integer";
			Name = "Value";
			Description = "How much to give"
		}
	};
}