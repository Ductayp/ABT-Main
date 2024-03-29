-- Morioh_Speedwagon

local Workspace = game:GetService("Workspace")

local module = {}

module.ProximityPrompt = Workspace:FindFirstChild("Prompt_Morioh_Abbacchio", true)
module.IconName = "Icon_Abbacchio"
module.Title = "Gang Member"
module.Body = "You need stuff? We got stuff. It's that simple. Prices might not be great but what are your options really?"
module.ShopType = "BUY"
module.ShopType_TextColor = Color3.fromRGB(0, 170, 0)

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