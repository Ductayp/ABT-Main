-- Morioh

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Morioh = {}

--Morioh.SpawnGroupId = "Morioh_Arrows" --
Morioh.Spawners = Workspace:FindFirstChild("ItemSpawners_Morioh", true)
Morioh.MapZone = "Morioh"
Morioh.MaxSpawned = 20
Morioh.TotalSpawned = 0

Morioh.Items = {

    -- WEIGHT 1

    {
        Weight = 1,
        Model = ReplicatedStorage.SpawnItems.DungeonKey,
        Params = {
            DataKey = "DungeonKey",
            DataCategory = "Item",
            MinValue = 1,
            MaxValue = 1,
        },
    },

    {
        Weight = 1,
        Model = ReplicatedStorage.SpawnItems.GoldStar,
        Params = {
            DataKey = "GoldStar",
            DataCategory = "Item",
            Quantity = 1,
        },
    },

    {
        Weight = 1,
        Model = ReplicatedStorage.SpawnItems.Diamond,
        Params = {
            DataKey = "Diamond",
            DataCategory = "Item",
            Quantity = 1,
        }
    },

    -- WEIGHT 20

    {
        Weight = 20,
        Model = ReplicatedStorage.SpawnItems.SoulOrbs,
        Params = {
            DataKey = "SoulOrbs",
            DataCategory = "Currency",
            MinValue = 1,
            MaxValue = 1,
        },
    },


    -- WEIGHT 50

    {
        Weight = 50,
        Model = ReplicatedStorage.SpawnItems.Cash,
        Params = {
            DataKey = "Cash",
            DataCategory = "Currency",
            MinValue = 100,
            MaxValue = 350,
        }
    },

    {
        Weight = 50,
        Model = ReplicatedStorage.SpawnItems.Arrow,
        Params = {
            DataKey = "Arrow",
            Quantity = 1,
            DataCategory = "Item",
        }
    },

}

return Morioh