-- DiosCryptSpawners

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DiosCryptSpawners = {}

DiosCryptSpawners.Spawners = Workspace:FindFirstChild("ItemSpawners_DiosCrypt", true)
DiosCryptSpawners.MapZone = "DiosCrypt"
DiosCryptSpawners.MaxSpawned = 6
DiosCryptSpawners.TotalSpawned = 0

-- ALWAYS SORT THESE FROM LOWEST TO HIGHEST OR IT WONT WORK RIGHT
DiosCryptSpawners.Items = {

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
        Model = ReplicatedStorage.SpawnItems.GreenGoo,
        Params = {
            DataKey = "GreenGoo",
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


return DiosCryptSpawners