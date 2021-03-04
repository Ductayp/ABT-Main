-- Morioh_XP Spawn Table
-- PDab
-- 12/14/2020

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Morioh_XP = {}

Morioh_XP.SpawnGroupId = "Morioh_XP"
Morioh_XP.Region = "Morioh"
Morioh_XP.MaxSpawned = 5
Morioh_XP.TotalSpawned = 0

-- ALWAYS SORT THESE FROM LOWEST TO HIGHEST OR IT WONT WORK RIGHT
Morioh_XP.Items = {

    {
        Weight = 1,
        Model = ReplicatedStorage.SpawnItems.XpToken,
        Params = {
            --DataKey = "StandXP",
            DataCategory = "StandExperience",
            MinValue = 100,
            MaxValue = 200
        }
    },

    {
        Weight = 10,
        Model = ReplicatedStorage.SpawnItems.XpToken,
        Params = {
            --DataKey = "StandXP",
            DataCategory = "StandExperience",
            MinValue = 50,
            MaxValue = 100
        }
    }
}


return Morioh_XP