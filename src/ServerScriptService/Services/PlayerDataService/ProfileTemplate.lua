--// Profile Tempalte for Player Data Service
-- this module returns a table fo the players data, the values here are default values


local module = {
	General = {
		Visits = 0
	},
	
	CurrentStand = {
		Power = "Standless",
	},

	
	ItemInventory = {},

	ArrowInventory = {},
	
	StandStorage = {
		MaxSlots = 6,
		StoredStands = {}
	},
	
	Modifiers = {},
	
	ClientSettings = {},

	DeveloperProductPurchases = {}
}

return module
