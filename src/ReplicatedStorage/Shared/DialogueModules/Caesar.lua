-- HiddenCaesar Dialogue

local module = {}

-- Initialize is run fresh every time this NPC Dialogue is started
function module.Initialize()
    -- print("BEEEP BEEP!")
end

module.Shop = {
    OneKey = {
        Input = {
            Key = "Antidote",
            Value = 30
        },
        Output = {
            Key = "SoulKey",
            Value = 1
        }
    },
}

module.Stage = {}

module.Stage.Start = {
    IconName = "Icon_Caesar",
    Title = "Caesar",
    Body = "Wham down there has the antidotes for the venom inside Joseph. 1,000 versions of Joseph across all the timelines could die!<br/><br/>" ..
    "By using The Ripple, I am able to maintain my link back. Together we can save them.",
    Choice_1 = {
        Display = true,
        Text = "TRADE",
        CustomProperties = {BackgroundColor3 = Color3.fromRGB(0, 170, 0), Size = UDim2.new(0.25, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "BuySell"
        }
    },

    Choice_2 = {
        Display = false,
    },

    Choice_3 = {
        Display = false,
    },
}

module.Stage.BuySell = {
    IconName = "Icon_Caesar",
    Title = "Caesar",
    Body = "I need many antidotes for each timeline version of Joseph we save. In return, I can give you this Soul Key. It can be used to unlock the potential of your stand or spec.<br/><br/>" ..
        "<b>30 ANTIDOTE = 1 SOUL KEY</b>",
    Choice_1 = {
        Display = true,
        Text = "Buy 1 SOUL KEY",
        CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "Shop",
            ModuleName = "Caesar",
            TransactionKey = "OneKey"
        }
    },

    Choice_2 = {
        Display = false,
    },

    Choice_3 = {
        Display = false,
    },
}




return module