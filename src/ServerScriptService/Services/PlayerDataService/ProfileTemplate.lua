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

	-- StandStorage, just to hold the stands and data regarding storage
	StandStorage = {
		MaxSlots = 6,
		StoredStands = {}
	},
	
	-- Modifiers, not used yet. Will be used to keep track of boosts and other mads that carry over between play sessions
	Modifiers = {},

	-- ItemFinder, tracks which items a player has set to find
	ItemFinder = {
		FinderOn = false,
		ItemToggles = {}
	},
	
	-- ClientSettings, not used yet. To store how the playe has their settings beytween play sessions
	ClientSettings = {},

	-- DeveloperProductPurchase, track all pirchases to avoid duplicates
	DeveloperProductPurchases = {},

	-- RedeemedCodes, track all codes used
	RedeemedCodes = {},

	-- PlayerStats, not used yet, can track things like # of visits
	PlayerStats = {},

	-- Admin, not used yet. Will keep rack of things such as bans
	Admin = {
		Banned = false,
	}
}

return module
