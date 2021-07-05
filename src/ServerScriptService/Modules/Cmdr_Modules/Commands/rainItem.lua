return {
	Name = "rainItem";
	Aliases = {};
	Description = "Give items to all player";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "items";
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