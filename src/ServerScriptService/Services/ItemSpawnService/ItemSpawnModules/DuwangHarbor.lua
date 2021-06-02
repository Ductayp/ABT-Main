-- DuwangHarbor

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DuwangHarbor = {}

--DuwangHarbor.SpawnGroupId = "DuwangHarbor_Arrows" --
DuwangHarbor.Spawners = Workspace:FindFirstChild("ItemSpawners_DuwangHarbor", true)
DuwangHarbor.MapZone = "DuwangHarbor"
DuwangHarbor.MaxSpawned = 15
DuwangHarbor.TotalSpawned = 0

DuwangHarbor.Items = {

    -- WEIGHT 1

    {
        Weight = 1,
        Model = ReplicatedStorage.SpawnItems.BrokenArrow,
        Params = {
            DataKey = "BrokenArrow",
            DataCategory = "Item",
            Quantity = 5,
        }
    },

    -- WEIGHT 5
    
    {
        Weight = 5,
        Model = ReplicatedStorage.SpawnItems.Cash,
        Params = {
            DataKey = "Cash",
            DataCategory = "Currency",
            MinValue = 50,
            MaxValue = 250,
        }
    },


    -- WEIGHT 10

    {
        Weight = 10,
        Model = ReplicatedStorage.SpawnItems.Cash,
        Params = {
            DataKey = "Cash",
            DataCategory = "Currency",
            MinValue = 20,
            MaxValue = 100,
        }
    },

    {
        Weight = 10,
        Model = ReplicatedStorage.SpawnItems.SoulOrbs,
        Params = {
            DataKey = "SoulOrbs",
            DataCategory = "Currency",
            MinValue = 1,
            MaxValue = 3,
        },
    },

    {
        Weight = 10,
        Model = ReplicatedStorage.SpawnItems.Arrow,
        Params = {
            DataKey = "Arrow",
            Quantity = 1,
            DataCategory = "Item",
        }
    },


}

return DuwangHarbor