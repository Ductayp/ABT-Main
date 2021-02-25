return {
	Name = "giveItem";
	Aliases = {};
	Description = "Give item to a player";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "player";
			Name = "Target Player";
			Description = "The player to give to";
		},
		{
			Type = "string";
			Name = "Item Key";
			Description = "Must be a VALID KEY"
		},
		{
			Type = "integer";
			Name = "Qauntity";
			Description = "How many to give"
		}
	};
}