-- CraftingDefs

return {

    Arrow = {
        Name = "Arrow x10",
        LayoutOrder = 1,
        Description = "There's many ways to get arrows, crafting is just one.",
        InputItems = {
            [1] = {Key = "BrokenArrow", Value = 100, Name = "Broken Arrow"},
            [2] = {Key = "SoulOrbs", Value = 10, Name = "Soul Orbs"},
        },
        OutputItems = {
            [1] = {Key = "Arrow", Value = 10, Name = "Arrow x10"},
        },
    },

    Arrow100 = {
        Name = "Arrow x100",
        LayoutOrder = 2,
        Description = "There's many ways to get arrows, crafting is just one.",
        InputItems = {
            [1] = {Key = "BrokenArrow", Value = 900, Name = "Broken Arrow"},
            [2] = {Key = "SoulOrbs", Value = 100, Name = "Soul Orbs"},
        },
        OutputItems = {
            [1] = {Key = "Arrow", Value = 100, Name = "Arrow x100"},
        },
    },

    StoneMask = {
        Name = "Stone Mask",
        LayoutOrder = 3,
        Description = "The Stone Mask can be used ot get Vampire spec.",
        InputItems = {
            [1] = {Key = "MaskFragment", Value = 100, Name = "Mask Fragment"},
            [2] = {Key = "SoulOrbs", Value = 50, Name = "Soul Orbs"},
        },
        OutputItems = {
            [1] = {Key = "StoneMask", Value = 1, Name = "Stone Mask"}
        },
    },

    GoldStar = {
        Name = "Gold Star",
        LayoutOrder = 4,
        Description = "Gold Stars are used to rank up stands and specs.",
        InputItems = {
            [1] = {Key = "Antidote", Value = 100, Name = "Antidote"},
            [2] = {Key = "SoulOrbs", Value = 25, Name = "Soul Orbs"},
        },
        OutputItems = {
            [1] = {Key = "GoldStar", Value = 1, Name = "Gold Star"}
        },
    },

}

