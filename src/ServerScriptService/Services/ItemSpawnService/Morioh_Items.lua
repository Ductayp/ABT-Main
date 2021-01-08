-- Morioh_Items Spawn Table
-- PDab
-- 12/14/2020

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Morioh_Items = {}

Morioh_Items.Region = "Morioh"
Morioh_Items.MaxSpawned = 4

-- ALWAYS SORT THESE FROM LOWEST TO HIGHEST OR IT WONT WORK RIGHT
Morioh_Items.Items = {

    UniversalArrow_1 = {
        Weight = 1,
        Model = ReplicatedStorage.SpawnItems.UniversalArrow,
        Params = {
            DataKey = "UniversalArrow",
            DataCategory = "ArrowInventory",
            Rarity = "Legendary",
            ArrowName = "Universal Arrow"
        }
    },

    UniversalArrow_2 = {
        Weight = 200,
        Model = ReplicatedStorage.SpawnItems.UniversalArrow,
        Params = {
            DataKey = "UniversalArrow",
            DataCategory = "ArrowInventory",
            Rarity = "Rare",
            ArrowName = "Universal Arrow"
        }
    },

    UniversalArrow_3 = {
        Weight = 450,
        Model = ReplicatedStorage.SpawnItems.UniversalArrow,
        Params = {
            DataKey = "UniversalArrow",
            DataCategory = "ArrowInventory",
            Rarity = "Common",
            ArrowName = "Universal Arrow"
        }
    },

    Cash_1 = {
        Weight = 450,
        Model = ReplicatedStorage.SpawnItems.Cash,
        Params = {
            DataKey = "Cash",
            DataCategory = "Currency",
            MinValue = 5,
            MaxValue = 50
        }
    },

    XP_1 = {
        Weight = 525,
        Model = ReplicatedStorage.SpawnItems.XpToken,
        Params = {
            DataKey = "StandXP",
            DataCategory = "StandXP",
            MinValue = 1,
            MaxValue = 10
        }
    }
}




return Morioh_Items