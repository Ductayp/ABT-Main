-- Morioh_XP Spawn Table
-- PDab
-- 12/14/2020

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Morioh_XP = {}

Morioh_XP.SpawnGroupId = "Morioh_Special"
Morioh_XP.Region = "Morioh"
Morioh_XP.MaxSpawned = 0
Morioh_XP.TotalSpawned = 0

-- ALWAYS SORT THESE FROM LOWEST TO HIGHEST OR IT WONT WORK RIGHT
Morioh_XP.Items = {

    {
        Weight = 1,
        Model = ReplicatedStorage.SpawnItems.XpToken,
        Params = {
            --DataKey = "StandXP",
            DataCategory = "StandExperience",
            MinValue = 60,
            MaxValue = 120
        }
    },

    {
        Weight = 2,
        Model = ReplicatedStorage.SpawnItems.XpToken,
        Params = {
            --DataKey = "StandXP",
            DataCategory = "StandExperience",
            MinValue = 30,
            MaxValue = 60
        }
    },

    {
        Weight = 1,
        Model = ReplicatedStorage.SpawnItems.Boost,
        Params = {
            DataKey = "Boost",
            DataCategory = "Boost",
            Random = true,
            PickList = {
                {
                    Key = "ItemFinder",
                    Name = "Item Finder",
                    Duration = 300
                },
                {
                    Key = "DoubleCash",
                    Name = "Double Cash",
                    Duration = 120
                },
                {
                    Key = "DoubleSoulOrbs",
                    Name = "Double Soul Orbs",
                    Duration = 120
                },
                {
                    Key = "DoubleExperience",
                    Name = "Double XP",
                    Duration = 120
                },
            },
        }
    },
}


return Morioh_XP