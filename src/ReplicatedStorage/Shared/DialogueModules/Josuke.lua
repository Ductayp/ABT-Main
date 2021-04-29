-- PlanetWagon Dialogue

local module = {}

-- Initialize is run fresh every time this NPC Dialogue is started
function module.Initialize()
    -- print("BEEEP BEEP!")
end

module.Shop = {
    TenDiamonds= {
        Input = {
            Key = "Diamond",
            Value = 1
        },
        Output = {
            Key = "Cash",
            Value = 700
        }
    },
    HundredDiamonds = {
        Input = {
            Key = "Diamond",
            Value = 10
        },
        Output = {
            Key = "Cash",
            Value = 8000
        }
    },
}

module.Stage = {}

module.Stage.Start = {
    IconName = "Icon_Josuke",
    Title = "Guy With Nice Hair (don't make fun of it!)",
    Body = "You new here too!? Lately so many weird people been showing up, seems like everyone is a stand user these days.<br/><br/><b>If you need to get rid of your stand, visit STAND STORAGE down the street.</b>",
    Choice_1 = {
        Display = true,
        Text = "TRADE",
        CustomProperties = {Size = UDim2.new(0.15, 0, 0.9, 0)},
        CustomProperties = {BackgroundColor3 = Color3.fromRGB(0, 170, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "BuySell"
        }
    },
    Choice_2 = {
        Display = true,
        Text = "Why are stand users showing up?",
        CustomProperties = {Size = UDim2.new(0.6, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "Stage2"
        }
    },
    Choice_3 = {
        Display = false,
    },
}

module.Stage.Stage2 = {
    IconName = "Icon_Josuke",
    Title = "Guy With Nice Hair (don't make fun of it!)",
    Body = "No idea whats going on, but things are getting very strange. It seems the whole island might be stuck in a time rift.<br/><br/>Maybe my nephew knows more. He's by the hotel.",
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
        Text = "Cool, thanks!",
        Action = {
            Type = "Close",
        }
    },

    Choice_3 = {
        Display = false,
    },
}

module.Stage.BuySell = {
    IconName = "Icon_Josuke",
    Title = "Guy With Nice Hair (don't make fun of it!)",
    Body = "Me and Okuyasu dying to eat at Tonio's place again but bro wants Diamonds for the secret menu items! Bring me <b>DIAMONDS</b> and I can give you some <b>CASH</b>" ..
        "<br/><br/><b>1 Diamonds for 700 CASH<br/>10 Diamonds for 8,000 CASH</b>",
    Choice_1 = {
        Display = true,
        Text = "Sell 1 Diamonds",
        Action = {
            Type = "Shop",
            ModuleName = "Josuke",
            TransactionKey = "TenDiamonds"
        }
    },
    Choice_2 = {
        Display = true,
        Text = "Sell 10 Diamonds",
        Action = {
            Type = "Shop",
            ModuleName = "Josuke",
            TransactionKey = "HundredDiamonds"
        }
    },
    Choice_3 = {
        Display = false,
    },
}


return module