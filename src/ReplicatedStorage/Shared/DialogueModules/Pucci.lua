-- PlanetWagon Dialogue

local module = {}

-- Initialize is run fresh every time this NPC Dialogue is started
function module.Initialize()
    -- print("BEEEP BEEP!")
end

module.Shop = {
    OneKey = {
        Input = {
            Key = "SoulOrbs",
            Value = 100
        },
        Output = {
            Key = "SoulKey",
            Value = 1
        }
    },
    TenKey = {
        Input = {
            Key = "SoulOrbs",
            Value = 950
        },
        Output = {
            Key = "SoulKey",
            Value = 10
        }
    },
}

module.Stage = {}

module.Stage.Start = {
    IconName = "Icon_Pucci",
    Title = "Enrico",
    Body = "Welcome to my shop, in here you can access your Stand Storage.<br/><br/>You don't need to talk to me, just use your MENU while inside this shop and it will work.",
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
        Display = true,
        Text = "Remove Stand?",
        --CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "RemoveStand"
        }
    },

    Choice_3 = {
        Display = true,
        Text = "Mobile Storage?",
        --CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "MobileStorage"
        }
    },
}

module.Stage.MobileStorage = {
    IconName = "Icon_Pucci",
    Title = "Enrico",
    Body = "If you want to be able to manage your stands outside the shop you will need to get the MOBILE STORAGE pass<br/><br/>Then your menu will work wherever you go!",
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
        Display = true,
        Text = "Remove Stand?",
        --CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "RemoveStand"
        }
    },

    Choice_3 = {
        Display = false,
    },
}

module.Stage.RemoveStand = {
    IconName = "Icon_Pucci",
    Title = "Enrico",
    Body = "You can remove your stand any time, no matter if you are in this shop or not.<br/><br/>Just open your stand storage menu, click the stand you want to remove, and click TRASH.",
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
        Display = true,
        Text = "Mobile Storage?",
        Action = {
            Type = "ChangeStage",
            Stage = "MobileStorage"
        }
    },

    Choice_3 = {
        Display = false,
    },
}

module.Stage.BuySell = {
    IconName = "Icon_Pucci",
    Title = "Enrico",
    Body = "To unlock the potential of your stand or spec, you wil need a SOUL KEY. You can increase its rank by using a SOUL KEY when the XP bar is full.<br/><br/>" ..
        "I can sell you 1 SOUL KEY for 100 Soul Orbs, or 10 SOUL KEYs for 950 Soul Orbs.",
    Choice_1 = {
        Display = true,
        Text = "Buy 1 SOUL KEY",
        CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "Shop",
            ModuleName = "Pucci",
            TransactionKey = "OneKey"
        }
    },

    Choice_2 = {
        Display = true,
        Text = "Buy 10 SOUL KEYs",
        CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "Shop",
            ModuleName = "Pucci",
            TransactionKey = "TenKey"
        }
    },

    Choice_3 = {
        Display = false,
    },
}




return module