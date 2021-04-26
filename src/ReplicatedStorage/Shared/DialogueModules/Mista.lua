-- PlanetWagon Dialogue

local module = {}

-- Initialize is run fresh every time this NPC Dialogue is started
function module.Initialize()
    -- print("BEEEP BEEP!")
end

module.Shop = {
    TenBulbs= {
        Input = {
            Key = "VirusBulb",
            Value = 10
        },
        Output = {
            Key = "Cash",
            Value = 750
        }
    },
    HundredBulbs = {
        Input = {
            Key = "VirusBulb",
            Value = 100
        },
        Output = {
            Key = "Cash",
            Value = 8000
        }
    },
}

module.Stage = {}

module.Stage.Start = {
    IconName = "Icon_Mista",
    Title = "Guido the Gunslinger",
    Body = "This Time Rift has made a bunch of copies of Pannacotta and now he's in a RAGE again! He's a good guy at heart but his stand has gone out of controll." ..
        "<br/><br/>This is REALLY BAD! His stand has been dropping <b>Virus Bulbs</b> all over town, find them and I will give you cash.",
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
        Display = false,
    },
    Choice_3 = {
        Display = false,
    },
}

module.Stage.BuySell = {
    IconName = "Icon_Mista",
    Title = "Guido the Gunslinger",
    Body = "Find those <b>VIRUS BULBS</b> but BE CAREFUL! Get them here and I know how to get rid of them safely." ..
        "<br/><br/><b>10 Virus Bulbs for 750 Cash<br/>100 Virus Bulbs for 8,000 Cash</b>",
    Choice_1 = {
        Display = true,
        Text = "Sell 10 Virus Bulbs",
        CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "Shop",
            ModuleName = "Mista",
            TransactionKey = "TenBulbs"
        }
    },
    Choice_2 = {
        Display = true,
        Text = "Sell 100 Virus Bulbs",
        CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "Shop",
            ModuleName = "Mista",
            TransactionKey = "HundredBulbs"
        }
    },
    Choice_3 = {
        Display = false,
    },
}

return module