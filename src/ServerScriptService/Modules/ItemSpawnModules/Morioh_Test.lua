-- Morioh_B Spawn Table
-- PDab
-- 12/14/2020

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Morioh_B = {}

Morioh_B.Region = "Morioh"
Morioh_B.MaxSpawned = 6

-- ALWAYS SORT THESE FROM LOWEST TO HIGHEST OR IT WONT WORK RIGHT. Dictionary key names muct be unique.
Morioh_B.Items = {

    UniversalArrow_1 = {
        Weight = 1,
        Model = ReplicatedStorage.SpawnItems.UniversalArrow,
        Params = {
            DataKey = "UniversalArrow",
            DataCategory = "Arrow",
            Rarity = "Rare",
            ArrowName = "Universal Arrow"
        }
    },

    UniversalArrow_2 = {
        Weight = 5,
        Model = ReplicatedStorage.SpawnItems.UniversalArrow,
        Params = {
            DataKey = "UniversalArrow",
            DataCategory = "Arrow",
            Rarity = "Common",
            ArrowName = "Universal Arrow"
        }
    },

    UniversalArrow_3 = {
        Weight = 5,
        Model = ReplicatedStorage.SpawnItems.UniversalArrow,
        Params = {
            DataKey = "UniversalArrow",
            DataCategory = "Arrow",
            Rarity = "Legendary",
            ArrowName = "Universal Arrow"
        }
    },

    Cash = {
        Weight = 10,
        Model = ReplicatedStorage.SpawnItems.Cash,
        Params = {
            DataKey = "Cash",
            DataCategory = "Currency",
            MinValue = 1,
            MaxValue = 10
        }
    }
}

return Morioh_B