-- SkeletonHeelStoneSpawners

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SkeletonHeelStone = {}

SkeletonHeelStone.Spawners = Workspace:FindFirstChild("ItemSpawners_SkeletonHeelStone", true)
SkeletonHeelStone.MapZone = "SkeletonHeelStone"
SkeletonHeelStone.MaxSpawned = 15
SkeletonHeelStone.TotalSpawned = 0

-- ALWAYS SORT THESE FROM LOWEST TO HIGHEST OR IT WONT WORK RIGHT
SkeletonHeelStone.Items = {

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
        Weight = 1,
        Model = ReplicatedStorage.SpawnItems.SoulOrbs,
        Params = {
            DataKey = "SoulOrbs",
            DataCategory = "Currency",
            MinValue = 2,
            MaxValue = 3,
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

}


return SkeletonHeelStone