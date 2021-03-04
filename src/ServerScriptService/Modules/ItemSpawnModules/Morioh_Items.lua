-- Morioh_Items Spawn Table
-- PDab
-- 12/14/2020

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Morioh_Items = {}

Morioh_Items.SpawnGroupId = "Morioh_Items"
Morioh_Items.Region = "Morioh"
Morioh_Items.MaxSpawned = 4
Morioh_Items.TotalSpawned = 0

-- ALWAYS SORT THESE FROM LOWEST TO HIGHEST OR IT WONT WORK RIGHT
Morioh_Items.Items = {

    {
        Weight = 400,
        Model = ReplicatedStorage.SpawnItems.Arrow,
        Params = {
            DataKey = "Arrow",
            DataCategory = "Item",
        }
    },

    {
        Weight = 450,
        Model = ReplicatedStorage.SpawnItems.Cash,
        Params = {
            DataKey = "Cash",
            DataCategory = "Currency",
            MinValue = 5,
            MaxValue = 50
        }
    },

    {
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