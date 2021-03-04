-- Morioh_B Spawn Table
-- PDab
-- 12/14/2020

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Morioh_B = {}

Morioh_B.SpawnGroupId = "Morioh_Test"
Morioh_B.Region = "Morioh"
Morioh_B.MaxSpawned = 6
Morioh_B.TotalSpawned = 0

-- ALWAYS SORT THESE FROM LOWEST TO HIGHEST OR IT WONT WORK RIGHT. Dictionary key names muct be unique.
Morioh_B.Items = {

    {
        Weight = 10,
        Model = ReplicatedStorage.SpawnItems.Arrow,
        Params = {
            DataKey = "Arrow",
            DataCategory = "Item",
        }
    },

    {
        Weight = 1,
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