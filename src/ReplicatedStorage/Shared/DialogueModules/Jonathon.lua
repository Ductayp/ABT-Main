-- PlanetWagon Dialogue

local module = {}

-- Initialize is run fresh every time this NPC Dialogue is started
function module.Initialize()
    -- print("BEEEP BEEP!")
end

module.Shop = {
    TenFragments= {
        Input = {
            Key = "MaskFragment",
            Value = 10
        },
        Output = {
            Key = "Cash",
            Value = 750
        }
    },
    HundredFragments = {
        Input = {
            Key = "MaskFragment",
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
    IconName = "Icon_Jonathon",
    Title = "Jonathon",
    Body = "I thought the STONE MASK was destroyed, shattered into thousands of pieces. But Dio is after it again, trying to gether them up!" ..
        "<br/><br/>They say these guys on the beach are a time-copied Pillar Man, whatever that means, get me the <b>MASK FRAGMENTS</b> and I will give you cash.",
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
    IconName = "Icon_Jonathon",
    Title = "Jonathon",
    Body = "If you bring me <b>MASK FRAGMENTS</b> then I can be sure Dio cant make the STONE MASK again. That would be bad ..." ..
        "<br/><br/><b>10 Mask Fragments for 750 Cash<br/>100 Mask Fragments for 8,000 Cash</b>",
    Choice_1 = {
        Display = true,
        Text = "Sell 10 Mask Fragments",
        CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "Shop",
            ModuleName = "Jonathon",
            TransactionKey = "TenFragments"
        }
    },
    Choice_2 = {
        Display = true,
        Text = "Sell 100 Mask Fragments",
        CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "Shop",
            ModuleName = "Jonathon",
            TransactionKey = "HundredFragments"
        }
    },
    Choice_3 = {
        Display = false,
    },
}

return module