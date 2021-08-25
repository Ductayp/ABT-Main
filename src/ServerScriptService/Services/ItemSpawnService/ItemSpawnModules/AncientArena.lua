-- SkeletonHeelStoneSpawners

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SkeletonHeelStone = {}

SkeletonHeelStone.Spawners = Workspace:FindFirstChild("ItemSpawners_AncientArena", true)
SkeletonHeelStone.MapZone = "AncientArena"
SkeletonHeelStone.MaxSpawned = 5
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
        Weight = 25,
        Model = ReplicatedStorage.SpawnItems.SoulOrbs,
        Params = {
            DataKey = "SoulOrbs",
            DataCategory = "Currency",
            MinValue = 1,
            MaxValue = 3,
        }
    },

    {
        Weight = 25,
        Model = ReplicatedStorage.SpawnItems.MaskFragment,
        Params = {
            DataKey = "MaskFragment",
            DataCategory = "Item",
            Quantity = 1,
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


return SkeletonHeelStone