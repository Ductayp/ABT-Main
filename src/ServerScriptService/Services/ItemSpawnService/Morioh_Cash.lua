-- Morioh_Cash Spawn Table
-- PDab
-- 12/14/2020

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Morioh_Cash = {}

Morioh_Cash.Region = "Morioh"
Morioh_Cash.MaxSpawned = 10

-- ALWAYS SORT THESE FROM LOWEST TO HIGHEST OR IT WONT WORK RIGHT
Morioh_Cash.Items = {

    Cash_1 = {
        Weight = 1,
        Model = ReplicatedStorage.SpawnItems.Cash,
        Params = {
            DataKey = "Cash",
            DataCategory = "Currency",
            MinValue = 50,
            MaxValue = 250
        }
    },

    Cash_2 = {
        Weight = 10,
        Model = ReplicatedStorage.SpawnItems.Cash,
        Params = {
            DataKey = "Cash",
            DataCategory = "Currency",
            MinValue = 5,
            MaxValue = 50
        }
    }
}


return Morioh_Cash