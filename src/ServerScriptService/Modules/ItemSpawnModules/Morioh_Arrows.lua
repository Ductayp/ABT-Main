-- Morioh_Items Spawn Table
-- PDab
-- 12/14/2020

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Morioh_Items = {}

Morioh_Items.SpawnGroupId = "Morioh_Arrows"
Morioh_Items.Region = "Morioh"
Morioh_Items.MaxSpawned = 3
Morioh_Items.TotalSpawned = 0

Morioh_Items.Items = {
    {
        Weight = 1,
        Model = ReplicatedStorage.SpawnItems.Arrow,
        Params = {
            DataKey = "Arrow",
            Quantity = 1,
            DataCategory = "Item",
        }
    },
}

return Morioh_Items