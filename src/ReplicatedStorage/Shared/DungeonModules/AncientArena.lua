-- Morioh_Speedwagon

local Workspace = game:GetService("Workspace")

local module = {}

module.ProximityPrompt = Workspace:FindFirstChild("Prompt_Morioh_Joseph", true)
module.IconName = "Icon_Joseph"
module.Title = "Plucky Runner"
module.Body = "You need stuff? We got stuff. It's that simple. Prices might not be great but what are your options really?"

module.ShopItems = {

    [1] = {

        OutputName = "Arrows x10",
        OutputKey = "Arrow",
        OutputValue = 10,

        InputName = "Cash",
        InputKey = "Cash",
        InputValue = 1000,

        Description = "Use an Arrow while standless to gain a new stand.",

    },

    [2] = {

        OutputName = "Arrows x100",
        OutputKey = "Arrow",
        OutputValue = 100,

        InputName = "Cash",
        InputKey = "Cash",
        InputValue = 9000,

        Description = "Use an Arrow while standless to gain a new stand.",

    },

    [3] = {

        OutputName = "Dungeon Key",
        OutputKey = "DungeonKey",
        OutputValue = 1,

        InputName = "Cash",
        InputKey = "Cash",
        InputValue = 1000,

        Description = "Opens up dungeons. What else do you need to know?",

    },

    [4] = {

        OutputName = "Dungeon Key x10",
        OutputKey = "DungeonKey",
        OutputValue = 10,

        InputName = "Cash",
        InputKey = "Cash",
        InputValue = 9000,

        Description = "Opens up dungeons. What else do you need to know?",

    },

}


return module