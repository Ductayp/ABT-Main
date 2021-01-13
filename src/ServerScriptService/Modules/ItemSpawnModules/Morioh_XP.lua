-- Morioh_XP Spawn Table
-- PDab
-- 12/14/2020

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Morioh_XP = {}

Morioh_XP.Region = "Morioh"
Morioh_XP.MaxSpawned = 5

-- ALWAYS SORT THESE FROM LOWEST TO HIGHEST OR IT WONT WORK RIGHT
Morioh_XP.Items = {

    XP_1 = {
        Weight = 1,
        Model = ReplicatedStorage.SpawnItems.XpToken,
        Params = {
            --DataKey = "StandXP",
            DataCategory = "StandExperience",
            MinValue = 10,
            MaxValue = 50
        }
    },

    XP_2 = {
        Weight = 10,
        Model = ReplicatedStorage.SpawnItems.XpToken,
        Params = {
            --DataKey = "StandXP",
            DataCategory = "StandExperience",
            MinValue = 1,
            MaxValue = 10
        }
    }
}


return Morioh_XP