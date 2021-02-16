return {
	Name = "giveArrow";
	Aliases = {};
	Description = "Give Arrow to a player";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "player";
			Name = "Target Player";
			Description = "The player to give to";
		},
		{
			Type = "string";
			Name = "Arrow Key";
			Description = "Right now, it MUST be UniversalArrow"
		},
		{
			Type = "string";
			Name = "Rarity";
			Description = "must be: Common, Rare or Legendary"
		},
		{
			Type = "integer";
			Name = "Qauntity";
			Description = "How many to give"
		}
	};
}