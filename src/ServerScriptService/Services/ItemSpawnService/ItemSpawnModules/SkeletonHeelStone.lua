-- SkeletonHeelStoneSpawners

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SkeletonHeelStone = {}

SkeletonHeelStone.Spawners = Workspace:FindFirstChild("ItemSpawners_SkeletonHeelStone", true)
SkeletonHeelStone.MapZone = "SkeletonHeelStone"
SkeletonHeelStone.MaxSpawned = 2
SkeletonHeelStone.TotalSpawned = 0

-- ALWAYS SORT THESE FROM LOWEST TO HIGHEST OR IT WONT WORK RIGHT
SkeletonHeelStone.Items = {

    {
        Weight = 1,
        Model = ReplicatedStorage.SpawnItems.GoldStar,
        Params = {
            DataKey = "GoldStar",
            DataCategory = "Item",
            Quantity = 1,
        }
    },

    {
        Weight = 100,
        Model = ReplicatedStorage.SpawnItems.SoulOrbs,
        Params = {
            DataKey = "SoulOrbs",
            DataCategory = "Currency",
            MinValue = 2,
            MaxValue = 3,
        }
    },

}


return SkeletonHeelStone