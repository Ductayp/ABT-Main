-- Morioh_A Spawn Table
-- PDab
-- 12/14/2020

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Morioh_A = {}

Morioh_A.Region = "Morioh"
Morioh_A.MaxSpawned = 6

-- ALWAYS SORT THESE FROM LOWEST TO HIGHEST OR IT WONT WORK RIGHT
Morioh_A.Items = {

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
        Weight = 1000,
        Model = ReplicatedStorage.SpawnItems.UniversalArrow,
        Params = {
            DataKey = "UniversalArrow",
            DataCategory = "ArrowInventory",
            Rarity = "Common",
            ArrowName = "Universal Arrow"
        }
    },
}




return Morioh_A