-- CraftingDefs

return {

    Arrow = {
        Name = "Arrow x10",
        LayoutOrder = 1,
        Description = "There's many ways to get arrows, crafting is just one.",
        InputItems = {
            [1] = {Key = "BrokenArrow", Value = 25, Name = "Broken Arrow"},
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
            [1] = {Key = "BrokenArrow", Value = 225, Name = "Broken Arrow"},
            [2] = {Key = "SoulOrbs", Value = 100, Name = "Soul Orbs"},
        },
        OutputItems = {
            [1] = {Key = "Arrow", Value = 100, Name = "Arrow x100"},
        },
    },

    StoneMask = {
        Name = "Stone Mask",
        LayoutOrder = 3,
        Description = "The Stone Mask can be used to get Vampire spec.",
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
            [1] = {Key = "SoulOrbs", Value = 100, Name = "Soul Orbs"},
        },
        OutputItems = {
            [1] = {Key = "GoldStar", Value = 1, Name = "Gold Star"}
        },
    },

    GreenBaby = {
        Name = "Green Baby",
        LayoutOrder = 5,
        Description = "Eat ths little guy to evolve White Snake into C-Moon",
        InputItems = {
            [1] = {Key = "DiosBone", Value = 1, Name = "Dio's Bone"},
            [2] = {Key = "GreenGoo", Value = 100, Name = "Green Goo"},
        },
        OutputItems = {
            [1] = {Key = "GreenBaby", Value = 1, Name = "Green Baby"}
        },
    },

}

