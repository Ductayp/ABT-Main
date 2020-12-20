--// Profile Tempalte for Player Data Service
-- this module returns a table fo the players data, the values here are default values
-- all keys MUST be unique, regardles of tables organization


local module = {
	General = {
		Visits = 0
	},
	
	Character = {
		XP = 0,
		Level = 1,
		CurrentPower = "Standless"
	},
	
	ItemInventory = {},

	ArrowInventory = {},
	
	StandInventory = {},
	
	Modifiers = {},
	
	ClientSettings = {}
}

return module
