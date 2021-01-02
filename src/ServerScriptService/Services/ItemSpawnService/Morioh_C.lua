-- Morioh_C Spawn Table
-- PDab
-- 12/14/2020

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Morioh_C = {}

Morioh_C.Region = "Morioh"
Morioh_C.MaxSpawned = 2

-- ALWAYS SORT THESE FROM LOWEST TO HIGHEST OR IT WONT WORK RIGHT
Morioh_C.Items = {

    UniversalArrow_1 = {
        Weight = 1,
        Model = ReplicatedStorage.SpawnItems.UniversalArrow,
        Params = {
            DataKey = "UniversalArrow",
            DataCategory = "ArrowInventory",
            Rarity = "Rare",
            ArrowName = "Universal Arrow"
        }
    },

    UniversalArrow_2 = {
        Weight = 5,
        Model = ReplicatedStorage.SpawnItems.UniversalArrow,
        Params = {
            DataKey = "UniversalArrow",
            DataCategory = "ArrowInventory",
            Rarity = "Common",
            ArrowName = "Universal Arrow"
        }
    },

    Cash = {
        Weight = 10,
        Model = ReplicatedStorage.SpawnItems.Cash,
        Params = {
            DataKey = "Cash",
            DataCategory = "ItemInventory",
            MinValue = 1,
            MaxValue = 10
        }
    }

}

return Morioh_C