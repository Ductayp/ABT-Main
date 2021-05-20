-- HiddenDio Dialogue

local module = {}

-- Initialize is run fresh every time this NPC Dialogue is started
function module.Initialize()
    -- print("BEEEP BEEP!")
end

module.Shop = {
    TenArrow = {
        Input = {
            Key = "Cash",
            Value = 1000
        },
        Output = {
            Key = "Arrow",
            Value = 10
        }
    },
    HundredArrow = {
        Input = {
            Key = "Cash",
            Value = 9000
        },
        Output = {
            Key = "Arrow",
            Value = 100
        }
    },
}

module.Stage = {}

module.Stage.Start = {
    IconName = "Icon_Dio",
    Title = "Dio",
    Body = "Wondering how all these arrows got here? Or why there are so many stand users from all timelines here at once?<br/><br/>" ..
    "<b>It Was Me, Dio!</b>",
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
        Text = "Why did you do it?",
        CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "Why"
        }
    },

    Choice_3 = {
        Display = false,
    },
}

module.Stage.Why = {
    IconName = "Icon_Dio",
    Title = "Dio",
    Body = "The more carefully you scheme, the more unexpected events come along!<br/><br/>" ..
    "By creating more stand users to build my army, I will burn Jonathan's family tree to the ground!",
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
        Text = "How did you do it?",
        CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "How"
        }
    },

    Choice_3 = {
        Display = false,
    },
}

module.Stage.How = {
    IconName = "Icon_Dio",
    Title = "Dio",
    Body = "The leader of the Pillar Men was banished into space ...<br/><br/>" ..
    "The arrow heads are made from a rare metal only found in a special metorite. Even a small brained loser like you can figure out the rest.",
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
    IconName = "Icon_Dio",
    Title = "Dio",
    Body = "If you want to be powerful like me, you will need a good stand. It's realy very simple.<br/><br/>" ..
        "<b>1,000 CASH for 10 ARROWS<br/>9,000 CASH for 100 ARROWS</b>",
    Choice_1 = {
        Display = true,
        Text = "Buy 10 ARROWS",
        CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "Shop",
            ModuleName = "HiddenDio",
            TransactionKey = "TenArrow"
        }
    },

    Choice_2 = {
        Display = true,
        Text = "Buy 100 ARROWS",
        CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "Shop",
            ModuleName = "HiddenDio",
            TransactionKey = "HundredArrow"
        }
    },

    Choice_3 = {
        Display = false,
    },
}




return module