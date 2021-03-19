return {
	Name = "giveExperience";
	Aliases = {};
	Description = "Give a Experience/Soul Power to a players equipped stand.";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "player";
			Name = "Target Player";
			Description = "The player to give to";
		},

		{
			Type = "integer";
			Name = "Value";
			Description = "How much Experience/Soul Power to give"
		}
	};
}