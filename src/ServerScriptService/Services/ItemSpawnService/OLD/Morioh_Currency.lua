-- Arena_A Spawn Table
-- PDab
-- 12/14/2020

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Arena_A = {}

Arena_A.SpawnGroupId = "Arena_A"
Arena_A.Region = "Arena"
Arena_A.MaxSpawned = 2
Arena_A.TotalSpawned = 0

-- ALWAYS SORT THESE FROM LOWEST TO HIGHEST OR IT WONT WORK RIGHT
Arena_A.Items = {

    {
        Weight = 1,
        Model = ReplicatedStorage.SpawnItems.Cash,
        Params = {
            DataKey = "Cash",
            DataCategory = "Currency",
            MinValue = 50,
            MaxValue = 250,
        }
    },

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
            MaxValue = 1,
        },
    }
}


return Arena_A