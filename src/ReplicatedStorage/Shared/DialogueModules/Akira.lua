-- PlanetWagon Dialogue

local module = {}

-- Initialize is run fresh every time this NPC Dialogue is started
function module.Initialize()
    -- print("BEEEP BEEP!")
end

module.Shop = {
    TenDiamonds= {
        Input = {
            Key = "BrokenArrow",
            Value = 10
        },
        Output = {
            Key = "Cash",
            Value = 500
        }
    },
    HundredDiamonds = {
        Input = {
            Key = "BrokenArrow",
            Value = 100
        },
        Output = {
            Key = "Cash",
            Value = 6000
        }
    },
}

module.Stage = {}

module.Stage.Start = {
    IconName = "Icon_JAkira",
    Title = "Guy With Nice Hair (don't make fun of it!)",
    Body = "You new here too!? Lately so many weird people been showing up, seems like everyone is a stand user these days.<br/><br/><b>If you to get rid of your stand, visit Pucci's down the street.</b>",
    Choice_1 = {
        Display = true,
        Text = "BUY/SELL",
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
    IconName = "Icon_JAkira",
    Title = "Guy With Nice Hair (don't make fun of it!)",
    Body = "No idea whats going on, but things are getting very strange. It seems the whole island might be stuck in a time rift.<br/><br/>Maybe my nephew knows more. He's by the hotel.",
    Choice_1 = {
        Display = true,
        Text = "BUY/SELL",
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
    IconName = "Icon_JAkira",
    Title = "Guy With Nice Hair (don't make fun of it!)",
    Body = "Me and Okuyasu dying to eat at Tonio's place again but were BROKE! Bring me <b>DIAMONDS</b> and I can give you some of these <b>Soul Orbs</b>. Maybe you can use them." ..
        "<br/><br/><b>10 Diamonds for 1500 Soul Orbs<br/>100 Diamonds for 20000 Soul Orbs</b>",
    Choice_1 = {
        Display = true,
        Text = "Sell 10 Diamonds",
        Action = {
            Type = "Shop",
            ModuleName = "Josuke",
            TransactionKey = "TenDiamonds"
        }
    },
    Choice_2 = {
        Display = true,
        Text = "Sell 100 Diamonds",
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