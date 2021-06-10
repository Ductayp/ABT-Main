-- Morioh_Speedwagon

local Workspace = game:GetService("Workspace")

local module = {}

module.ProximityPrompt = Workspace:FindFirstChild("Prompt_Morioh_Speedwagon", true)
module.IconName = "Icon_Speedwagon"
module.Title = "Speedbuggy"
module.Body = "I only buy the finest things with which I shall build my empire."
module.ShopType = "SELL"
module.ShopType_TextColor = Color3.fromRGB(255, 0, 0)

module.ShopItems = {

    [1] = {

        OutputName = "Cash",
        OutputKey = "Cash",
        OutputValue = 100,

        InputName = "Arrow x10",
        InputKey = "Arrow",
        InputValue = 10,

        Description = "Use an Arrow while standless to gain a new stand.",

    },

    
    [2] = {

        OutputName = "Cash",
        OutputKey = "Cash",
        OutputValue = 1000,

        InputName = "Arrow x100",
        InputKey = "Arrow",
        InputValue = 100,

        Description = "Use an Arrow while standless to gain a new stand.",

    },

    [3] = {

        OutputName = "Cash",
        OutputKey = "Cash",
        OutputValue = 5000,

        InputName = "Diamond x1",
        InputKey = "Diamond",
        InputValue = 1,

        Description = "Dimaonds are unbreakable, and sellabe too!",

    },

    [4] = {

        OutputName = "Cash",
        OutputKey = "Cash",
        OutputValue = 55000,

        InputName = "Diamond x10",
        InputKey = "Diamond",
        InputValue = 10,

        Description = "Dimaonds are unbreakable, and sellabe too!",

    },

    [5] = {

        OutputName = "Cash",
        OutputKey = "Cash",
        OutputValue = 10000,

        InputName = "Stone Mask",
        InputKey = "StoneMask",
        InputValue = 1,

        Description = "Use while standless to gain the Vampire spec.",

    },


}


return module