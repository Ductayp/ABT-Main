-- Morioh_Items Spawn Table
-- PDab
-- 12/14/2020

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Morioh_Items = {}

Morioh_Items.SpawnGroupId = "Morioh_Items"
Morioh_Items.Region = "Morioh"
Morioh_Items.MaxSpawned = 3
Morioh_Items.TotalSpawned = 0

-- ALWAYS SORT THESE FROM LOWEST TO HIGHEST OR IT WONT WORK RIGHT
Morioh_Items.Items = {

    {
        Weight = 1,
        Model = ReplicatedStorage.SpawnItems.VirusBulb,
        Params = {
            DataKey = "VirusBulb",
            DataCategory = "Item",
        }
    },

    {
        Weight = 1,
        Model = ReplicatedStorage.SpawnItems.MaskFragment,
        Params = {
            DataKey = "MaskFragment",
            DataCategory = "Item",
        }
    },

}




return Morioh_Items