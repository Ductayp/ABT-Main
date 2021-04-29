-- PlanetWagon Dialogue

local module = {}

-- Initialize is run fresh every time this NPC Dialogue is started
function module.Initialize()
    -- print("BEEEP BEEP!")
end

module.Shop = {
    TenArrows= {
        Input = {
            Key = "BrokenArrow",
            Value = 10
        },
        Output = {
            Key = "Cash",
            Value = 2250
        }
    },
    HundredArrows = {
        Input = {
            Key = "BrokenArrow",
            Value = 100
        },
        Output = {
            Key = "Cash",
            Value = 25000
        }
    },
}

module.Stage = {}

module.Stage.Start = {
    IconName = "Icon_Akira",
    Title = "Rock Star",
    Body = "My stand is a remote type and it seems the Time Rift we are in means I lost control, it's been shooting and breaking arrows left and right!" ..
        "<br/><br/>If I can get a bunch of those BROKEN ARROWS, Enrico promised me a Record Deal.",
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
        Text = "What's up with this PINK WATER?",
        CustomProperties = {Size = UDim2.new(0.6, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "PinkWater"
        }
    },
    Choice_3 = {
        Display = false,
    },
}

module.Stage.PinkWater = {
    IconName = "Icon_Akira",
    Title = "Rock Star",
    Body = "Weird isn't it? I don't think its actualy water at all!<br/><br/>When you fall in it's like your body is being torn apart, riped across the time continuum.",
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
    IconName = "Icon_Akira",
    Title = "Rock Star",
    Body = "Like I said, Enrico wants these <b>BROKEN ARROWS</b> for some reason. Who knows what hes gonna do and honestly I don't care!" ..
        "<br/><br/><b>10 Broken Arrows for 2,250 Cash<br/>100 Broken Arrows for 25,000 Cash</b>",
    Choice_1 = {
        Display = true,
        Text = "Sell 10 Broken Arrows",
        CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "Shop",
            ModuleName = "Akira",
            TransactionKey = "TenArrows"
        }
    },
    Choice_2 = {
        Display = true,
        Text = "Sell 100 Broken Arrows",
        CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "Shop",
            ModuleName = "Akira",
            TransactionKey = "HundredArrows"
        }
    },
    Choice_3 = {
        Display = false,
    },
}


return module