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
        "<br/><br/>I wonder what else Dio is up to, this just doesnt seem right. I cant even catch a decent wave on this island!",
    Choice_1 = {
        Display = true,
        Text = "Hang loose brah!",
        CustomProperties = {Size = UDim2.new(0.4, 0, 0.9, 0)},
        Action = {
            Type = "Close",
        }
    },
    Choice_2 = {
        Display = false,
    },
    Choice_3 = {
        Display = false,
    },
}


return module