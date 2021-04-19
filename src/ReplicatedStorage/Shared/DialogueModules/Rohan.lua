-- Rohan Dialogue

local module = {}

-- Initialize is run fresh every time this NPC Dialogue is started
function module.Initialize()
    -- print("BEEEP BEEP!")
end

module.Shop = {
    TenPages= {
        Input = {
            Key = "BlankPage",
            Value = 10
        },
        Output = {
            Key = "Cash",
            Value = 500
        }
    },
    HundredPages = {
        Input = {
            Key = "BlankPage",
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
    IconName = "Icon_Rohan",
    Title = "Famous Mangaka",
    Body = "Please don't interrupt my work, I have another chapter to get out and I need more pages to fill.<br/><br/><b>Have you seen any pages floating around?</b>",
    Choice_1 = {
        Display = true,
        Text = "BUY/SELL",
        CustomProperties = {BackgroundColor3 = Color3.fromRGB(0, 170, 0), Size = UDim2.new(0.15, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "BuySell"
        }
    },
    Choice_2 = {
        Display = true,
        Text = "What's going on here?",
        CustomProperties = {Size = UDim2.new(0.45, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "WhatsGoinOn_1"
        }
    },
    Choice_3 = {
        Display = false,
    },
}

module.Stage.WhatsGoinOn_1 = {
    IconName = "Icon_Rohan",
    Title = "Famous Mangaka",
    Body = "Whatever is going on, it's going to make a great story if I can get my pages back.<br/><br/>Just yesterday some overly-muscular version of myself stole my blank pages, said something about not wanting Dio to find them.",
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
        Text = "A buff version of YOU?",
        CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "ChangeStage",
            Stage = "WhatsGoinOn_2"
        }
    },
    Choice_3 = {
        Display = false,
    },
}

module.Stage.WhatsGoinOn_2 = {
    IconName = "Icon_Rohan",
    Title = "Famous Mangaka",
    Body = "Thats right! It must have been me from another time, and theres more than one too! Must be some sort of time loop or rift hapenening.<br/><br/>Just not sure how I got so buff in the future ...",
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
        Text = "Whatever ...",
        Action = {
            Type = "Close",
        }
    },
    Choice_3 = {
        Display = false,
    },
}

module.Stage.BuySell = {
    IconName = "Icon_Rohan",
    Title = "Famous Mangaka",
    Body = "Help me get this chapter finished. Bring me <b>BLANK PAGES</b> and I can pay you in <b>CASH</b>. Besides, we don't want Dio to get any of these, I guess." ..
        "<br/><br/><b>10 Blank Pages for 500 CASH<br/>100 Blank Pages for 6,000 CASH</b>",
    Choice_1 = {
        Display = true,
        Text = "Sell 10 Blank Pages",
        Action = {
            Type = "Shop",
            ModuleName = "Rohan",
            TransactionKey = "TenPages"
        }
    },
    Choice_2 = {
        Display = true,
        Text = "Sell 100 Blank Pagess",
        CustomProperties = {Size = UDim2.new(0.35, 0, 0.9, 0)},
        Action = {
            Type = "Shop",
            ModuleName = "Rohan",
            TransactionKey = "HundredPages"
        }
    },
    Choice_3 = {
        Display = false,
    },
}


return module