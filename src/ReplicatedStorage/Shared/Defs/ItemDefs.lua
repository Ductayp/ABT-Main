-- Item Defs

return {

    Arrow = {
        Name = "Arrow",
        Type = "Evolution",
        EvolutionPaths = {
            Standless = {
               GivePower = "GenerateStand",
               CutScene = "UseArrow",
            },
        },
        Description = "Evolve from STANDLESS into a new stand user.<br /><br />You will get a Rank 1 stand unless you have the Super Arrow pass.",
        LayoutOrder = 1,
    },

    GoldStar = {
        Name = "Gold Star",
        Type = "Special",
        Description = "Unlocks the potential of a stand/spec.<br /><br />Use this item when your XP bar is full to rank-up. Rank 3 is max.",
        LayoutOrder = 2,
    },

    StoneMask = {
        Name = "Stone Mask",
        Type = "Evolution",
        EvolutionPaths = {
            Standless = {
               GivePower = "Vampire",
               CutScene = "StoneMask",
            },
            TheWorld = {
                GivePower = "VampiricTheWorld",
            },
        },
        Description = "Can be crafted from Mask Fragments dropped by the Pillar Men on the Beach.<br/><br/><b>EVOLUTIONS:</b><br/>Standless = Vampire<br/>The World = Vampiric The World",
        LayoutOrder = 3
    },

    --[[
    HornedMask = {
        Name = "Horned Mask",
        Type = "Special",
        GivePower = "PillarMan",
        CutScene = "StoneMask",
        Description = "Use this item while you have Vampire Spec. to get Pillar Man Spec.<br/><br/>MORE TEXT HERE?",
        LayoutOrder = 3
    },
    ]]--

    Antidote = {
        Name = "Antidote",
        Type = "Collectable",
        Description = "Hidden inside the nose ring of Wham is an antidote. Infused with the power of the Pillar Men, it glows softly.<br/><br/>Can be used to craft powerful items.",
        LayoutOrder = 4
    },

    MaskFragment = {
        Name = "Mask Fragment",
        Type = "Collectable",
        Description = "A small piece of a stone mask. You can probably piece them together if you had enough.<br/><br/>Can be crafted into the Stone Mask.",
        LayoutOrder = 5,
    },

    DungeonKey = {
        Name = "Dungeon Key",
        Type = "Collectable",
        Description = "While these resemble real keys, they are imbued with the power to stabilize the Time Rift.<br/><br/>You will need a lot of these.",
        LayoutOrder = 6,
    },

    --[[
    VirusBulb = {
        Name = "Virus Bulb",
        Type = "Collectable",
        Description = "<b>BIOHAZARD!</b><br/>Please dispose of properly.<br/><br/>... or just sell them to the Six Shooter so he can deal with this mess.<br/>He's over on the ship somewhere.",
        LayoutOrder = 6
    },
    ]]--

    BrokenArrow = {
        Name = "Broken Arrow",
        Type = "Collectable",
        Description = "The head has been broken off of this arrow. I wonder why?<br /><br />Can be crafted into Arrows and Requiem Arrows.",
        LayoutOrder = 7
    },

    --[[
    BlankPage = {
        Name = "Blank Page",
        Type = "Collectable",
        Description = "It's just a blank page for a book. Maybe it's useful to someone?<br/><br/>Try selling these to the Mangaka, he's at his house by the park. Who knows who else might want these?",
        LayoutOrder = 8
    },
    ]]--

    Diamond = {
        Name = "Diamond",
        Type = "Collectable",
        Description = "Diamonds are unbreakable, or so they say...<br/><br/>Some are for selling to the Gang Member in the shop.",
        LayoutOrder = 9
    },

    GreenGoo = {
        Name = "Green Goo",
        Type = "Collectable",
        Description = "Its Gooey and its Green ...<br/><br/>Can be used in crafting things that are squishy!",
        LayoutOrder = 10
    },

    DiosBone = {
        Name = "Dio's Bone",
        Type = "Collectable",
        Description = "Straight up a BONE ... from Dio<br/><br/>Can be used in crafting STUFF.",
        LayoutOrder = 11
    },

   GreenBaby = {
        Name = "Green Baby",
        Type = "Evolution",
        EvolutionPaths = {
            WhiteSnake = {
                GivePower = "CMoon",
            },
        },
        Description = "A little green alien baby. Eat him to evolve White Snale into C-Moon",
        LayoutOrder = 12
    },


}

