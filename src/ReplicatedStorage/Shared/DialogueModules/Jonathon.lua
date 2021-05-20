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
    StoneMask = {
        Input = {
            Key = "MaskFragment",
            Value = 100
        },
        Output = {
            Key = "StoneMask",
            Value = 1
        }
    },
}

module.Stage = {}

module.Stage.Start = {
    IconName = "Icon_Jonathon",
    Title = "Jonathan",
    Body = "I thought the STONE MASK was destroyed, shattered into thousands of pieces. But Dio is after it again, trying to gather them up!" ..
        "<br/><br/>If I can create a mask before Dio, maybe I can figure out a way to stop him this time around. These Pillar Men on the beach have <b>MASK FRAGMENTS</b>, get them for me!",
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
    Body = "I am collecting <b>MASK FRAGMENTS</b> to re-create the STONE MASK again. I am buying them or if you have 100 I can craft the mask." ..
        "<br/><br/><b>100 Mask Fragments for 8000 Cash<br/>100 Mask Fragments for STONE MASK</b>",
    Choice_1 = {
        Display = true,
        Text = "Sell 100 Fragments",
        CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "Shop",
            ModuleName = "Jonathon",
            TransactionKey = "HundredFragments"
        }
    },

    Choice_2 = {
        Display = true,
        --Text = "Craft Stone Mask",
        Text = "Craft STONE MASK",
        CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "Shop",
            ModuleName = "Jonathon",
            TransactionKey = "StoneMask"
        }
    },

    Choice_3 = {
        Display = false,
    },
}

return module