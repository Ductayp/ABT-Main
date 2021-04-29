-- Jotaro Dialogue

local module = {}

-- Initialize is run fresh every time this NPC Dialogue is started
function module.Initialize()
    -- print("BEEEP BEEP!")
end

module.Shop = {
    TenArrows = {
        Input = {
            Key = "Arrow",
            Value = 10
        },
        Output = {
            Key = "Cash",
            Value = 1000
        }
    },
    HundredArrows = {
        Input = {
            Key = "Arrow",
            Value = 100
        },
        Output = {
            Key = "Cash",
            Value = 11000
        }
    },
}

module.Stage = {}

module.Stage.Start = {
    IconName = "Icon_Jotaro",
    Title = "Funny Hat Guy",
    Body = "Seems like the whole island is stuck in a TIME RIFT and suddenly all these stands users show up.<br/><br/>Dio must be up to soemthign again, theres arrows all over the place! If you have any of those arows, I will buy them.",
    
    Choice_1 = {
        Display = true,
        Text = "TRADE",
        CustomProperties = {BackgroundColor3 = Color3.fromRGB(0, 170, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "SellArrows"
        }
    },

    Choice_2 = {
        Display = true,
        Text = "Time Rift??",
        Action = {
            Type = "ChangeStage",
            Stage = "TimeRift"
        }
    },

    Choice_3 = {
        Display = false,
    },
}

module.Stage.TimeRift = {
    IconName = "Icon_Jotaro",
    Title = "Funny Hat Guy",
    Body = "Did you notice the water looks CRAZY PINK? If you go into it, you die. <br/><br/>You might want to talk to the Gang Star at the end of the dock to see what he knows about it.",
    Choice_1 = {
        Display = true,
        Text = "TRADE",
        CustomProperties = {BackgroundColor3 = Color3.fromRGB(0, 170, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "SellArrows"
        },
    },
    Choice_2 = {
        Display = false,
    },
    Choice_3 = {
        Display = false,
    },
}

module.Stage.SellArrows = {
    IconName = "Icon_Jotaro",
    Title = "Funny Hat Guy",
    Body = "If I can get rid of the arrows making people into Stand Users, maybe we can fix this.<br/><b><br/>10 Arrows for 1000 Cash<br/>100 Arrows for 11000 Cash</b>",
    Choice_1 = {
        Display = true,
        Text = "Sell 10 Arrows",
        Action = {
            Type = "Shop",
            ModuleName = "Jotaro",
            TransactionKey = "TenArrows"
        }
    },

    Choice_2 = {
        Display = true,
        Text = "Sell 100 Arrows",
        Action = {
            Type = "Shop",
            ModuleName = "Jotaro",
            TransactionKey = "HundredArrows"
        }
    },

    Choice_3 = {
        Display = false,
    },
}



return module