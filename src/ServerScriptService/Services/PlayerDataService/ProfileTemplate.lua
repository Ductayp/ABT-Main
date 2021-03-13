--// Profile Tempalte for Player Data Service
-- this module returns a table fo the players data, the values here are default values


local module = {

	-- Genral
	General = {
		Visits = 0
	},
	
	-- Current Stand
	CurrentStand = {
		Power = "Standless",
	},

	-- Currency, just for Cash and Soul Orbs for now
	Currency = {
		Cash = 0,
		SoulOrbs = 0,
	},
	
	-- ItemInventory, for all items inculding arrows and collectibles
	ItemInventory = {},

	-- boost timers, these datakeys are set here an are the only ones allowed in BoostService
	BoostTimeRemaining = {
		DoubleExperience = 0,
		DoubleCash = 0,
		DoubleSoulOrbs = 0,
		FastWalker = 0,
		ItemFinder = 0,
	},

	-- StandStorage, just to hold the stands and data regarding storage
	StandStorage = {
		MaxSlots = 6,
		StoredStands = {}
	},
	
	-- ItemFinder, tracks which items a player has set to find
	ItemFinder = {
		FinderOn = false,
		ItemToggles = {}
	},
	
	-- DeveloperProductPurchase, track all pirchases to avoid duplicates
	DeveloperProductPurchases = {},

	-- RedeemedCodes, track all codes used
	RedeemedCodes = {},

	-- Admin, not used yet. Will keep rack of things such as bans
	Admin = {
		Banned = false,
	}
}

return module
