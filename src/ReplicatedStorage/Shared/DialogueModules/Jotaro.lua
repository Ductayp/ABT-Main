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
            Value = 500
        }
    },
    HundredArrows = {
        Input = {
            Key = "Arrow",
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
    IconName = "Icon_Jotaro",
    Title = "Funny Hat Guy",
    Body = "Seems like the whole island is stuck in a TIME RIFT and suddenly all these stands users show up.<br/><br/>If you have any of those arows, I will buy them.",
    
    Choice_1 = {
        Display = true,
        Text = "BUY/SELL",
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
    Body = "Did you notie the water looks CRAZY PINK?<br/><br/>If you go into it, you die. You might want to talk to the guy at the end of the dock.",
    Choice_1 = {
        Display = true,
        Text = "Aight thanks.",
        Action = {
            Type = "Close",
        }
    },

    Choice_2 = {
        Display = true,
        Text = "Sell Arrows",
        Action = {
            Type = "ChangeStage",
            Stage = "SellArrows"
        }
    },

    Choice_3 = {
        Display = false,
    },
}

module.Stage.SellArrows = {
    IconName = "Icon_Jotaro",
    Title = "Funny Hat Guy",
    Body = "If I can get rid of the arrows making people into Stand Users, maybe we can fix this.<br/><b><br/>10 Arrows for 500 Cash<br/>100 Arrows for 6000 Cash</b>",
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