-- CraftingDefs

return {

    Arrow = {
        Name = "Arrow x10",
        LayoutOrder = 1,
        Description = "All these broken arrows have to be good for something ...",
        InputItems = {
            [1] = {Key = "BrokenArrow", Value = 100, Name = "Broken Arrow"},
            [2] = {Key = "SoulOrbs", Value = 10, Name = "Soul Orbs"},
        },
        OutputItems = {
            [1] = {Key = "Arrow", Value = 10, Name = "Arrow x10"},
        },
    },

    StoneMask = {
        Name = "Stone Mask",
        LayoutOrder = 2,
        Description = "With a lot of glue, we might be able to make these into a Stone Mask.",
        InputItems = {
            [1] = {Key = "MaskFragment", Value = 100, Name = "Stone Mask"},
            [2] = {Key = "SoulOrbs", Value = 50, Name = "Soul Orbs"},
        },
        OutputItems = {
            [1] = {Key = "StoneMask", Value = 1, Name = "Stone Mask"}
        },
    },

}

