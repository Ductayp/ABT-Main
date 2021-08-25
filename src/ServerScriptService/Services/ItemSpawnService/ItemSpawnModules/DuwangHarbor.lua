-- DuwangHarbor

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DuwangHarbor = {}

--DuwangHarbor.SpawnGroupId = "DuwangHarbor_Arrows" --
DuwangHarbor.Spawners = Workspace:FindFirstChild("ItemSpawners_DuwangHarbor", true)
DuwangHarbor.MapZone = "DuwangHarbor"
DuwangHarbor.MaxSpawned = 2
DuwangHarbor.TotalSpawned = 0

DuwangHarbor.Items = {

    -- WEIGHT 1

    {
        Weight = 1,
        Model = ReplicatedStorage.SpawnItems.BrokenArrow,
        Params = {
            DataKey = "BrokenArrow",
            DataCategory = "Item",
            Quantity = 1,
        }
    },

    {
        Weight = 25,
        Model = ReplicatedStorage.SpawnItems.SoulOrbs,
        Params = {
            DataKey = "SoulOrbs",
            DataCategory = "Currency",
            MinValue = 1,
            MaxValue = 3,
        },
    },

    {
        Weight = 25,
        Model = ReplicatedStorage.SpawnItems.Arrow,
        Params = {
            DataKey = "Arrow",
            Quantity = 1,
            DataCategory = "Item",
        }
    },

    {
        Weight = 50,
        Model = ReplicatedStorage.SpawnItems.Cash,
        Params = {
            DataKey = "Cash",
            DataCategory = "Currency",
            MinValue = 75,
            MaxValue = 150,
        }
    },


}

return DuwangHarbor