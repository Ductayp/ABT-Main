-- Morioh_B Spawn Table
-- PDab
-- 12/14/2020

local Morioh_B = {}

Morioh_B.Region = "Morioh"
Morioh_B.MaxSpawned = 6

-- ALWAYS SORT THESE FROM LOWEST TO HIGHEST OR IT WONT WORK RIGHT
Morioh_B.Items = {

    UniversalArrow = {}
    Arrow.Weight = 1
    Arrow.Tag = "Arrow"
    Arrow.Rarity = "Rare"

    UniversalArrow = {}
    Arrow.Weight = 3
    Arrow.Tag = "Arrow"
    Arrow.Rarity = "Common"

    TestArrow = {}
    Arrow.Weight = 3
    Arrow.Tag = "Arrow"
    Arrow.Rarity = "Common"

    TestArrow = {}
    Arrow.Weight = 3
    Arrow.Tag = "Arrow"
    Arrow.Rarity = "Legendary"

    Cash = {}
    Cash.Weight = 5
    Cash.Tag = "Cash"
    Cash.Min = 1
    Cash.Max = 10

}




return Morioh_B